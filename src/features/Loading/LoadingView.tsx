// [INPUT] react-router-dom的useNavigate, React hooks(useState, useEffect), constants中的DSStrings, 样式文件
// [OUTPUT] LoadingView组件, 加载页面的UI(支持多个加载状态), 自动循环切换加载页2-4, 两个循环后导航至预览页面
// [POS] 特征层的加载组件, 连接方向获取页面和报告预览页面, 提供加载状态展示, 加载页2-4循环切换(每3秒), 两个循环(18秒)后跳转到预览页
import { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { DSStrings } from '../../constants/strings';
import styles from './LoadingView.module.css';

export function LoadingView() {
  const navigate = useNavigate();
  const [loadingStage, setLoadingStage] = useState<'stage2' | 'stage3' | 'stage4'>('stage2');
  const cycleCountRef = useRef(0); // 记录循环次数
  const timerRef = useRef<NodeJS.Timeout | null>(null);

  // 加载页2-4循环切换，每隔3秒切换一次
  // 两个循环（6个阶段）后跳转到预览页面
  useEffect(() => {
    // 首次加载，立即显示 stage2
    setLoadingStage('stage2');
    cycleCountRef.current = 0;

    // 每3秒切换一次
    const switchStage = () => {
      setLoadingStage((prev) => {
        // 计算下一个阶段：stage2 -> stage3 -> stage4 -> stage2 (循环)
        if (prev === 'stage2') {
          return 'stage3';
        } else if (prev === 'stage3') {
          return 'stage4';
        } else {
          // stage4 -> stage2，完成一个循环
          cycleCountRef.current += 1;
          
          // 如果完成两个循环，清除定时器并在稍后跳转
          if (cycleCountRef.current >= 2) {
            if (timerRef.current) {
              clearInterval(timerRef.current);
              timerRef.current = null;
            }
            // 延迟一小段时间后跳转，确保用户能看到 stage2
            setTimeout(() => {
              navigate('/preview');
            }, 100);
          }
          
          return 'stage2';
        }
      });
    };

    // 启动定时器
    timerRef.current = setInterval(switchStage, 3000);

    // 清理函数
    return () => {
      if (timerRef.current) {
        clearInterval(timerRef.current);
      }
    };
  }, [navigate]);

  return (
    <div className={styles.container}>
      {/* 背景渐变 */}
      <div className={styles.backgroundGradient} />
      
      {/* 毛玻璃覆盖层 */}
      <div className={styles.glassOverlay} />

      {/* 加载页2：感知环境磁场 + 椭圆图标 */}
      {loadingStage === 'stage2' && (
        <>
          {/* 椭圆图标 - Figma: top=149px, left=95px, size=200px */}
          <div className={styles.ellipseContainer}>
            <img
              src="/ellipse.svg"
              alt="椭圆图标"
              className={styles.ellipseIcon}
            />
          </div>

          {/* 文本内容 - Figma: top=542px, left=99px, font-size=32px */}
          <div className={styles.contentStage2}>
            <p className={styles.textStage2}>{DSStrings.Loading.perceiving}</p>
          </div>

          {/* 进度条占位符 - Figma: top=443px, left=99px, width=191px, height=32px */}
          <div className={styles.progressPlaceholder} />
        </>
      )}

      {/* 加载页3：深入解析数据 + 轮子图标 */}
      {loadingStage === 'stage3' && (
        <>
          {/* 轮子图标 - Figma: top=149px, left=95px, size=200px */}
          <div className={styles.wheelContainer}>
            <img
              src="/wheel.svg"
              alt="轮子图标"
              className={styles.wheelIcon}
            />
          </div>

          {/* 文本内容 - Figma: top=542px, left=99px, font-size=32px */}
          <div className={styles.contentStage2}>
            <p className={styles.textStage2}>{DSStrings.Loading.analyzing}</p>
          </div>

          {/* 进度条占位符 - Figma: top=443px, left=99px, width=191px, height=32px */}
          <div className={styles.progressPlaceholder} />
        </>
      )}

      {/* 加载页4：汇聚分析结果 + Vector 图标 */}
      {loadingStage === 'stage4' && (
        <>
          {/* Vector 图标 - Figma: top=149px, left=95px, size=200px */}
          <div className={styles.vectorContainer}>
            <img
              src="/vector.svg"
              alt="Vector 图标"
              className={styles.vectorIcon}
            />
          </div>

          {/* 文本内容 - Figma: top=542px, left=99px, font-size=32px */}
          <div className={styles.contentStage2}>
            <p className={styles.textStage2}>{DSStrings.Loading.converging}</p>
          </div>

          {/* 进度条占位符 - Figma: top=443px, left=99px, width=191px, height=32px */}
          <div className={styles.progressPlaceholder} />
        </>
      )}

      {/* Home Indicator */}
      <div className={styles.homeIndicator} />
    </div>
  );
}

