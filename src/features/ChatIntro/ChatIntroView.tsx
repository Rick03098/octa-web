// [INPUT] react-router-dom的useNavigate hook, useOnboardingStore的name, constants中的DSStrings, 样式文件, ArrowLeftIcon和PlusIcon图标组件
// [OUTPUT] ChatIntroView组件, 对话开启页面的完整UI和交互逻辑, 导航至主界面/对话页面的操作
// [POS] 特征层的对话开启组件, 从主界面进入, 连接对话页面, 提供问候语、预设提示问题和输入功能
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useOnboardingStore } from '../../stores/onboardingStore';
import { DSStrings } from '../../constants/strings';
import { ArrowLeftIcon } from '../../components/icons/ArrowLeftIcon';
import { PlusIcon } from '../../components/icons/PlusIcon';
import { ArrowUpIcon } from '../../components/icons/ArrowUpIcon';
import { SquareIcon } from '../../components/icons/SquareIcon';
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
        src="http://localhost:3845/assets/e503f988099e962c10dd595d7fb80340d7487ce9.png"
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

      {/* 第一个提示气泡 - Figma: left=137.34px, top=527.05px, 独立定位 */}
      <button
        className={`${styles.promptBubble} ${styles.promptBubble1}`}
        onClick={() => handlePromptClick(DSStrings.ChatIntro.prompt1)}
      >
        {DSStrings.ChatIntro.prompt1}
      </button>

      {/* 提示气泡容器 - Figma: bottom=145px, left=32px */}
      <div className={styles.promptsContainer}>
        {/* 第二个提示气泡 - 左上角，旋转 355.202deg */}
        <button
          className={`${styles.promptBubble} ${styles.promptBubble2}`}
          onClick={() => handlePromptClick(DSStrings.ChatIntro.prompt2)}
        >
          {DSStrings.ChatIntro.prompt2}
        </button>

        {/* 第三个提示气泡 - 右下角，旋转 2.62deg */}
        <button
          className={`${styles.promptBubble} ${styles.promptBubble3}`}
          onClick={() => handlePromptClick(DSStrings.ChatIntro.prompt3)}
        >
          {DSStrings.ChatIntro.prompt3}
        </button>
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
            {/* 动态按钮 - 根据状态显示不同图标 */}
            <div className={styles.actionButtonContainer}>
              {/* 声音波形图标 - 空状态时显示 */}
              <button 
                className={styles.actionButton}
                aria-label="语音输入"
                onClick={() => {
                  // TODO: 实现语音输入功能
                  console.log('Voice input');
                }}
                style={{ display: !inputValue ? 'flex' : 'none' }}
              >
                <img src="/icons/icons.svg" alt="语音输入" width={16.75} height={19.2} />
              </button>
              {/* 发送图标 - 有文本时显示 */}
              <button 
                className={styles.actionButton}
                aria-label="发送"
                onClick={handleSubmit}
                disabled={!inputValue}
                style={{ display: inputValue ? 'flex' : 'none' }}
              >
                <ArrowUpIcon width={16} height={16} color="rgba(151, 130, 130, 1)" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

