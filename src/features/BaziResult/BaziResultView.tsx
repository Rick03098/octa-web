// [INPUT] React hooks(useState, useEffect, useRef), react-router-dom的useNavigate, components中的ArrowLeftIcon, constants中的DSStrings, stores中的useOnboardingStore, api中的profilesApi, 样式文件
// [OUTPUT] BaziResultView组件, 八字结果展示页面的UI和交互逻辑, 显示八字四句话结果, 支持滑动切换4页, 最后一页跳转到权限开启页
// [POS] 特征层的八字结果页面组件, 负责八字结果展示界面渲染和滑动切换, 是引导流程的第六步
import { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeftIcon } from '../../components/icons/ArrowLeftIcon';
import { DSStrings } from '../../constants/strings';
import { useOnboardingStore } from '../../stores/onboardingStore';
import { profilesApi } from '../../api/profiles';
import type { BaziFourSentencesResponse } from '../../types/models';
import styles from './BaziResultView.module.css';

export function BaziResultView() {
  const navigate = useNavigate();
  const [currentPage, setCurrentPage] = useState(0);
  const [loading, setLoading] = useState(true);
  const [fourSentences, setFourSentences] = useState<BaziFourSentencesResponse | null>(null);
  const [error, setError] = useState<string | null>(null);
  
  // 滑动相关状态
  const [isSwiping, setIsSwiping] = useState(false);
  const [startX, setStartX] = useState(0);
  const swipeContainerRef = useRef<HTMLDivElement>(null);
  
  // 第四页圆点消失状态
  const [dotsVisible, setDotsVisible] = useState(true);

  // 根据产品文档，4页的key分别是："纳音", "舒适区", "能量来源", "相冲能量"
  const pageKeys = ['纳音', '舒适区', '能量来源', '相冲能量'];
  const isLastPage = currentPage === pageKeys.length - 1;

  useEffect(() => {
    // TODO: 需要从onboardingStore获取profileId，或者先创建profile
    // 当前先使用占位数据
    // 实际实现中应该：
    // 1. 从onboardingStore获取用户输入信息
    // 2. 创建或获取bazi profile
    // 3. 调用getFourSentences获取结果
    setLoading(false);
    // 临时使用占位数据
    setFourSentences({
      day_pillar: '',
      strength_label: '',
      sentences: {
        '纳音': DSStrings.BaziResult.placeholders[0],
        '舒适区': DSStrings.BaziResult.placeholders[1],
        '能量来源': DSStrings.BaziResult.placeholders[2],
        '相冲能量': DSStrings.BaziResult.placeholders[3],
      },
    });
  }, []);

  // 当切换到最后一页时，1.5s后隐藏圆点
  useEffect(() => {
    if (isLastPage) {
      setDotsVisible(true); // 先显示圆点
      const timer = setTimeout(() => {
        setDotsVisible(false); // 1.5s后隐藏
      }, 1500);
      return () => clearTimeout(timer);
    } else {
      setDotsVisible(true); // 非最后一页时显示圆点
    }
  }, [isLastPage]);

  const handleBack = () => {
    navigate('/onboarding/gender');
  };

  const handleContinue = () => {
    navigate('/main-empty');
  };

  // 触摸开始
  const handleTouchStart = (e: React.TouchEvent) => {
    setIsSwiping(true);
    setStartX(e.touches[0].clientX);
  };

  // 触摸移动
  const handleTouchMove = (e: React.TouchEvent) => {
    if (!isSwiping) return;
    // 阻止默认滚动行为
    e.preventDefault();
  };

  // 触摸结束 - 处理滑动切换
  const handleTouchEnd = (e: React.TouchEvent) => {
    if (!isSwiping) return;
    
    const endX = e.changedTouches[0].clientX;
    const diffX = startX - endX;
    const threshold = 50; // 滑动阈值：50px

    if (Math.abs(diffX) > threshold) {
      if (diffX > 0 && currentPage < pageKeys.length - 1) {
        // 向左滑动，下一页
        setCurrentPage(currentPage + 1);
      } else if (diffX < 0 && currentPage > 0) {
        // 向右滑动，上一页
        setCurrentPage(currentPage - 1);
      }
    }

    setIsSwiping(false);
  };

  // 鼠标事件（用于桌面端测试）
  const handleMouseDown = (e: React.MouseEvent) => {
    setIsSwiping(true);
    setStartX(e.clientX);
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!isSwiping) return;
    e.preventDefault();
  };

  const handleMouseUp = (e: React.MouseEvent) => {
    if (!isSwiping) return;
    
    const endX = e.clientX;
    const diffX = startX - endX;
    const threshold = 50;

    if (Math.abs(diffX) > threshold) {
      if (diffX > 0 && currentPage < pageKeys.length - 1) {
        setCurrentPage(currentPage + 1);
      } else if (diffX < 0 && currentPage > 0) {
        setCurrentPage(currentPage - 1);
      }
    }

    setIsSwiping(false);
  };

  // 获取当前页的文本内容
  const getCurrentPageText = (): string => {
    if (!fourSentences) return '';
    const key = pageKeys[currentPage];
    return fourSentences.sentences[key] || '';
  };

  if (loading) {
    return (
      <div className={styles.container}>
        <div className={styles.loadingText}>加载中...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className={styles.container}>
        <div className={styles.errorText}>{error}</div>
      </div>
    );
  }

  return (
    <div 
      className={styles.container}
      ref={swipeContainerRef}
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
      onMouseDown={handleMouseDown}
      onMouseMove={handleMouseMove}
      onMouseUp={handleMouseUp}
      onMouseLeave={handleMouseUp}
    >
      {/* 背景渐变 - Ellipse 18 */}
      <div className={styles.backgroundEllipse} />
      {/* 背景渐变 - Polygon 2 */}
      <div className={styles.backgroundPolygon} />

      {/* 返回按钮 */}
      <button
        className={styles.backButton}
        onClick={handleBack}
        aria-label={DSStrings.Common.back}
      >
        <ArrowLeftIcon className={styles.backIcon} color="black" width={24} height={24} />
      </button>

      {/* 主要内容文本（非卡片） */}
      <div className={styles.textContainer}>
        <p className={styles.text}>
          {getCurrentPageText()}
        </p>
      </div>

      {/* 圆点指示器（仅显示，不响应点击，最后一页1.5s后渐变消失） */}
      {dotsVisible && (
        <div className={`${styles.dotsContainer} ${isLastPage ? styles.dotsFading : ''}`}>
          {pageKeys.map((_, index) => (
            <div
              key={index}
              className={`${styles.dot} ${index === currentPage ? styles.dotActive : ''}`}
              aria-label={`第${index + 1}页`}
            />
          ))}
        </div>
      )}

      {/* 继续按钮（仅在最后一页显示） */}
      {isLastPage && (
        <button
          className={styles.continueButton}
          onClick={handleContinue}
          aria-label={DSStrings.Common.actionContinue}
        >
          {DSStrings.Common.actionContinue}
        </button>
      )}
    </div>
  );
}
