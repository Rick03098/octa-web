// [INPUT] React hooks, react-router-dom的useNavigate, stores中的useOnboardingStore, constants中的DSStrings, PlusIcon图标组件, 环境数据(当前为占位数据)
// [OUTPUT] MainDashboardView组件, "输入后的主界面"完整UI(问候语+环境卡片+对话按钮+副标题+右下角添加按钮), 导航至拍摄教程/对话开启页面的操作
// [POS] 特征层的主界面组件, 是用户完成引导流程后的核心入口页面, 展示"输入后的主界面"设计, 协调所有子组件并处理导航逻辑
import { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { useOnboardingStore } from '../../stores/onboardingStore';
import { DSStrings } from '../../constants/strings';
import { PlusIcon } from '../../components/icons/PlusIcon';
import styles from './MainDashboardView.module.css';

export function MainDashboardView() {
  const navigate = useNavigate();
  const { name } = useOnboardingStore();

  // TODO: 从后端 API 获取用户的环境列表
  // 当前使用占位数据，模拟有环境的状态
  const [environments] = useState([
    {
      id: '1',
      imageUrl: 'http://localhost:3845/assets/e503f988099e962c10dd595d7fb80340d7487ce9.png',
      statusQuestions: [
        { text: '进展如何?', position: 'mid-left', left: -20, top: 340 },
        { text: '状态好些了么', position: 'top-right', left: 300, top: 289 },
        { text: '还要去继续约会?', position: 'mid-right', left: 100, top: 406 },
        { text: '发财树的状态还不错', position: 'lower-middle', left: 30, top: 494 },
      ],
    },
  ]);

  const currentEnvironment = environments.length > 0 ? environments[0] : null;

  // 词条动画状态管理
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [animationPhase, setAnimationPhase] = useState<'entering' | 'visible' | 'exiting' | 'hidden'>('hidden');
  const animationTimeoutRef = useRef<number | null>(null);

  // 词条动画循环逻辑
  useEffect(() => {
    if (!currentEnvironment?.statusQuestions || currentEnvironment.statusQuestions.length === 0) {
      return;
    }

    const questions = currentEnvironment.statusQuestions;
    const currentQuestion = questions[currentQuestionIndex];
    const charCount = currentQuestion.text.length;
    
    // 计算动画时间（整体速度更慢）
    const enterDuration = charCount * 0.05; // 每个字符0.05秒（从0.03秒增加到0.05秒）
    const visibleDuration = 3000; // 显示3秒（从2秒增加到3秒）
    const exitDuration = 1200; // 淡出1.2秒（从0.8秒增加到1.2秒）
    const totalDuration = (enterDuration * 1000) + visibleDuration + exitDuration;

    // 开始进入动画
    setAnimationPhase('entering');

    // 进入动画完成后，显示阶段
    const enterTimeout = setTimeout(() => {
      setAnimationPhase('visible');
    }, enterDuration * 1000);

    // 显示阶段完成后，开始退出动画
    const visibleTimeout = setTimeout(() => {
      setAnimationPhase('exiting');
    }, (enterDuration * 1000) + visibleDuration);

    // 退出动画完成后，切换到下一个词条
    animationTimeoutRef.current = window.setTimeout(() => {
      setAnimationPhase('hidden');
      // 切换到下一个词条（循环）
      setCurrentQuestionIndex((prev) => (prev + 1) % questions.length);
    }, totalDuration);

    // 清理函数
    return () => {
      clearTimeout(enterTimeout);
      clearTimeout(visibleTimeout);
      if (animationTimeoutRef.current) {
        clearTimeout(animationTimeoutRef.current);
      }
    };
  }, [currentQuestionIndex, currentEnvironment]);

  // 根据当前时间获取问候语时段
  const getGreetingPeriod = (): string => {
    const hour = new Date().getHours();
    if (hour < 12) return '早上';
    if (hour < 18) return '下午';
    return '晚上';
  };

  const period = getGreetingPeriod();
  const displayName = name || '朋友';

  // 处理添加环境按钮点击
  const handleAddEnvironment = () => {
    navigate('/tutorial');
  };

  // 处理对话按钮点击
  const handleChat = () => {
    navigate('/chat-intro');
  };

  // 处理环境卡片点击
  const handleEnvironmentClick = () => {
    // TODO: 跳转到环境详情或报告页面
    // navigate('/report');
    console.log('Environment card clicked');
  };

  // Ripple效果处理
  const handleCardClick = (e: React.MouseEvent<HTMLDivElement>) => {
    const card = e.currentTarget;
    const rect = card.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    
    // 创建ripple元素
    const ripple = document.createElement('span');
    const size = Math.max(rect.width, rect.height);
    const rippleSize = size * 2;
    
    ripple.style.cssText = `
      position: absolute;
      border-radius: 50%;
      background: rgba(255, 255, 255, 0.3);
      transform: scale(0);
      animation: ripple 0.6s ease-out;
      width: ${rippleSize}px;
      height: ${rippleSize}px;
      left: ${x - rippleSize / 2}px;
      top: ${y - rippleSize / 2}px;
      pointer-events: none;
    `;
    
    card.appendChild(ripple);
    
    // 动画结束后移除元素
    setTimeout(() => {
      ripple.remove();
    }, 600);
    
    // 执行点击处理
    handleEnvironmentClick();
  };

  return (
    <div className={styles.container}>
      {/* 问候区域 - Figma: left=29px, top=109.5px (center-y), Noto Serif SC Regular, 24px, #01031a (名字 #333333) */}
      <div className={styles.greetingSection}>
        <h1 className={styles.greeting}>
          {period}好 <span className={styles.greetingName}>{displayName}</span>
        </h1>
      </div>

      {/* 问题文案 - Figma: left=29px, top=164.5px (center-y), Noto Serif SC Regular, 16px, #333333 */}
      <p className={styles.greetingQuestion}>
        {DSStrings.Main.greetingQuestion}
      </p>

      {/* 环境卡片 - Figma: left=19px, top=221px, width=356px, height=410px, border-radius=60px */}
      {currentEnvironment && (
        <>
          <div className={styles.environmentCard} onClick={handleCardClick}>
            {/* 环境照片 */}
            <img
              src={currentEnvironment.imageUrl}
              alt="环境照片"
              className={styles.environmentImage}
              onError={(e) => {
                const target = e.target as HTMLImageElement;
                target.style.display = 'none';
              }}
            />

            {/* 状态问题文字 - 使用精确像素位置（基于Figma设计），带动画效果 */}
            {currentEnvironment.statusQuestions && currentEnvironment.statusQuestions.length > 0 && (() => {
              const question = currentEnvironment.statusQuestions[currentQuestionIndex];
              const isActive = animationPhase !== 'hidden';
              
              // 计算相对于卡片的位置（卡片位置：left=19px, top=221px, width=356px）
              const cardLeft = 19;
              const cardTop = 221;
              const cardWidth = 356;
              const cardCenterX = cardLeft + cardWidth / 2; // 197px
              const relativeLeft = question.left ? question.left - cardLeft : undefined;
              const relativeTop = question.top ? question.top - cardTop : undefined;
              
              // 确定对齐方式
              let transform = '';
              let textAlign: 'left' | 'center' | 'right' = 'left';
              let leftStyle: string | undefined;
              
              // 判断是否需要居中：left值较大的通常需要居中
              const isCentered = question.left >= 200;
              
              if (isCentered) {
                // 居中：计算相对于卡片中心的偏移
                const offsetFromCenter = question.left - cardCenterX;
                leftStyle = `calc(50% + ${offsetFromCenter}px)`;
                transform = 'translate(-50%, -50%)';
                textAlign = 'center';
              } else {
                // 左对齐，垂直居中
                leftStyle = relativeLeft ? `${relativeLeft}px` : undefined;
                transform = 'translateY(-50%)';
                textAlign = 'left';
              }
              
              return (
                <p
                  key={currentQuestionIndex}
                  className={`${styles.statusQuestion} ${isActive ? styles.statusQuestionActive : ''} ${
                    animationPhase === 'exiting' ? styles.statusQuestionExiting : ''
                  }`}
                  style={{
                    left: leftStyle,
                    top: relativeTop ? `${relativeTop}px` : undefined,
                    transform: transform || undefined,
                    textAlign: textAlign,
                  }}
                >
                  {question.text.split('').map((char: string, charIndex: number) => (
                    <span
                      key={charIndex}
                      className={styles.statusQuestionChar}
                      style={{
                        animationDelay: animationPhase === 'entering' 
                          ? `${charIndex * 0.05}s` 
                          : undefined,
                      }}
                    >
                      {char === ' ' ? '\u00A0' : char}
                    </span>
                  ))}
                </p>
              );
            })()}
          </div>

          {/* 对话按钮 - 卡片中间下方 */}
          <button className={styles.chatButton} onClick={handleChat}>
            对话
          </button>

          {/* 副标题 - Figma: left=197px (居中), top=892.5px (center-y), Noto Serif SC Regular, 16px, rgba(255,255,255,0.97) */}
          <p className={styles.subtitle}>开启天人合一之境</p>
        </>
      )}

      {/* 添加按钮 - 右下角 */}
      <button
        className={styles.addButton}
        onClick={handleAddEnvironment}
        aria-label="添加"
      >
        <PlusIcon 
          className={styles.addIcon} 
          color="#2B3340" 
          width={24} 
          height={24} 
        />
      </button>
    </div>
  );
}
