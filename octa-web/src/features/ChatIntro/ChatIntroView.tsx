// [INPUT] react-router-dom的useNavigate hook, useOnboardingStore的name, constants中的DSStrings, 样式文件, ArrowLeftIcon和PlusIcon图标组件, imageUtils工具函数
// [OUTPUT] ChatIntroView组件, 对话开启页面的完整UI和交互逻辑, 导航至主界面/对话页面的操作
// [POS] 特征层的对话开启组件, 从主界面进入, 连接对话页面, 提供问候语、预设提示问题和输入功能
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useOnboardingStore } from '../../stores/onboardingStore';
import { DSStrings } from '../../constants/strings';
import { ArrowLeftIcon } from '../../components/icons/ArrowLeftIcon';
import { PlusIcon } from '../../components/icons/PlusIcon';
import { ArrowUpIcon } from '../../components/icons/ArrowUpIcon';
import styles from './ChatIntroView.module.css';

export function ChatIntroView() {
  const navigate = useNavigate();
  const { name } = useOnboardingStore();
  const [inputValue, setInputValue] = useState('');

  const displayName = name || '朋友';

  // 处理返回按钮点击 - 返回到主界面
  const handleBack = () => {
    navigate('/main');
  };

  // 处理提示气泡点击 - 只填充输入框，不跳转
  const handlePromptClick = (prompt: string) => {
    // 只填充输入框，让用户确认后再按回车发送
    setInputValue(prompt);
  };

  // 处理输入提交
  const handleSubmit = () => {
    if (inputValue.trim()) {
      // 跳转到对话页面，携带输入内容，并标记为自动发送
      navigate('/chat', { 
        state: { 
          initialMessage: inputValue.trim(),
          autoSend: true // 标记为自动发送
        } 
      });
    }
  };

  // 处理输入框回车
  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      e.preventDefault(); // 阻止默认行为
      handleSubmit();
    }
  };

  return (
    <div className={styles.container}>
      {/* 背景图片 */}
      <img
        src="/images/蓝绿浅.gif"
        alt="背景"
        className={styles.backgroundImage}
        onError={(e) => {
          // 容错处理：如果图片加载失败，显示背景色
          const target = e.target as HTMLImageElement;
          target.style.display = 'none';
        }}
      />

      {/* 返回按钮 - Figma: left=22px, top=68px */}
      <button
        className={styles.backButton}
        onClick={handleBack}
        aria-label={DSStrings.Common.back}
      >
        <ArrowLeftIcon width={24} height={24} color="white" />
      </button>

      {/* 主标题 - Figma: left=36px, top=116px */}
      <div className={styles.titleContainer}>
        {DSStrings.ChatIntro.greeting(displayName)
          .split('\n')
          .map((line, index) => (
            <p key={index} className={styles.title}>
              {line}
            </p>
          ))}
      </div>

      {/* 提示气泡容器 - Figma: bottom=145px, left=32px, 所有三个气泡都在这个容器内 */}
      <div className={styles.promptsContainer}>
        {/* 第一个提示气泡 - Figma: left=105.33px, top=-58.95px, 旋转 1.704deg */}
        {/* 使用包装div处理定位，内部div处理旋转（与Figma结构一致） */}
        <div className={styles.bubbleWrapper1}>
          <button
            className={`${styles.promptBubble} ${styles.promptBubble1}`}
            onClick={() => handlePromptClick(DSStrings.ChatIntro.prompt1)}
          >
            {DSStrings.ChatIntro.prompt1}
          </button>
        </div>

        {/* 第二个提示气泡 - Figma: left=-7.41px, top=-4.37px, 旋转 355.202deg */}
        <div className={styles.bubbleWrapper2}>
          <button
            className={`${styles.promptBubble} ${styles.promptBubble2}`}
            onClick={() => handlePromptClick(DSStrings.ChatIntro.prompt2)}
          >
            {DSStrings.ChatIntro.prompt2}
          </button>
        </div>

        {/* 第三个提示气泡 - Figma: left=150px, top=61px, 旋转 2.62deg */}
        <div className={styles.bubbleWrapper3}>
          <button
            className={`${styles.promptBubble} ${styles.promptBubble3}`}
            onClick={() => handlePromptClick(DSStrings.ChatIntro.prompt3)}
          >
            {DSStrings.ChatIntro.prompt3}
          </button>
        </div>
      </div>

      {/* 底部输入区域 - Figma: bottom=34px */}
      <div className={styles.inputContainer}>
        {/* 添加按钮 - 左侧圆形按钮 */}
        <button className={styles.addButton} aria-label="添加">
          <PlusIcon width={19.2} height={19.2} color="rgba(113, 96, 101, 1)" />
        </button>

        {/* Composer根容器 - 使用对话页的对话框样式 */}
        <div className={styles.composerRoot}>
          <div className={styles.composerInner}>
            <input
              type="text"
              className={styles.input}
              placeholder={DSStrings.ChatIntro.placeholder}
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              onKeyDown={handleKeyDown}
            />
            {/* 发送按钮 - 始终显示白色背景，无输入时禁用 */}
            <button 
              className={`${styles.sendButton} ${inputValue ? styles.sendButtonActive : ''}`}
              aria-label="发送"
              onClick={handleSubmit}
              disabled={!inputValue}
            >
              <ArrowUpIcon width={12} height={12} color="rgba(80, 80, 80, 1)" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

