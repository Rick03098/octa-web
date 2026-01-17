// [INPUT] React hooks, react-router-dom的useNavigate, stores中的useOnboardingStore, components中的ArrowLeftIcon, constants中的DSStrings, 样式文件
// [OUTPUT] NameEntryView组件, 姓名输入页面的UI和交互逻辑, 用户输入姓名后保存到onboardingStore并跳转到生日信息页
// [POS] 特征层的姓名输入页面组件, 负责用户姓名输入界面渲染和状态管理, 是引导流程的第一步
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useOnboardingStore } from '../../stores/onboardingStore';
import { ArrowLeftIcon } from '../../components/icons/ArrowLeftIcon';
import { DSStrings } from '../../constants/strings';
import styles from './NameEntryView.module.css';

export function NameEntryView() {
  const navigate = useNavigate();
  const { name, setName } = useOnboardingStore();
  const [inputValue, setInputValue] = useState(name || '');

  const handleContinue = () => {
    const trimmed = inputValue.trim();
    if (trimmed) {
      setName(trimmed);
      navigate('/onboarding/birthday');
    }
  };

  const handleBack = () => {
    navigate('/login');
  };

  const handleKeyPress = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && inputValue.trim()) {
      handleContinue();
    }
  };

  return (
    <div className={styles.container}>
      {/* 背景渐变（模糊的径向渐变） */}
      <div className={styles.backgroundGradient} />
      
      {/* Eclipse装饰图片（如果需要，可以添加图片资源） */}
      {/* <div className={styles.eclipse} /> */}

      {/* 返回按钮 */}
      <button
        className={styles.backButton}
        onClick={handleBack}
        aria-label="返回"
      >
        <ArrowLeftIcon className={styles.backIcon} color="black" width={24} height={24} />
      </button>

      {/* 标题 */}
      <div className={styles.titleContainer}>
        <h1 className={styles.title}>
          请问该<br />如何称呼你？
        </h1>
      </div>

      {/* 输入框 */}
      <div className={styles.inputContainer}>
        <input
          type="text"
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          onKeyDown={handleKeyPress}
          className={styles.input}
          placeholder=""
          autoFocus
          aria-label="请输入您的姓名"
        />
      </div>

      {/* 继续按钮 */}
      <button
        className={styles.continueButton}
        onClick={handleContinue}
        disabled={!inputValue.trim()}
        aria-label={DSStrings.Common.actionContinue}
      >
        {DSStrings.Common.actionContinue}
      </button>
    </div>
  );
}
