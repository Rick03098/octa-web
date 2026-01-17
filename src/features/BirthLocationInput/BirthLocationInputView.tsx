// [INPUT] React hooks(useState), react-router-dom的useNavigate, stores中的useOnboardingStore, components中的ArrowLeftIcon, constants中的DSStrings, 样式文件
// [OUTPUT] BirthLocationInputView组件, 出生地输入页面的UI和交互逻辑, 用户输入出生地文字后保存到onboardingStore并跳转到性别选择页
// [POS] 特征层的出生地输入页面组件, 负责用户出生地输入界面渲染和状态管理, 是引导流程的第四步
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useOnboardingStore } from '../../stores/onboardingStore';
import { ArrowLeftIcon } from '../../components/icons/ArrowLeftIcon';
import { DSStrings } from '../../constants/strings';
import styles from './BirthLocationInputView.module.css';

export function BirthLocationInputView() {
  const navigate = useNavigate();
  const { birthLocation, setBirthLocation } = useOnboardingStore();
  const [inputValue, setInputValue] = useState(birthLocation || '');

  const handleContinue = () => {
    const trimmed = inputValue.trim();
    if (trimmed) {
      setBirthLocation(trimmed);
      navigate('/onboarding/gender');
    }
  };

  const handleBack = () => {
    navigate('/onboarding/birth-time');
  };

  const handleKeyPress = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && inputValue.trim()) {
      handleContinue();
    }
  };

  return (
    <div className={styles.container}>
      {/* 背景渐变 - Gradient（包含Eclipse和Planet） */}
      <div className={styles.backgroundGradient} />

      {/* 返回按钮 */}
      <button
        className={styles.backButton}
        onClick={handleBack}
        aria-label={DSStrings.Common.back}
      >
        <ArrowLeftIcon className={styles.backIcon} color="black" width={24} height={24} />
      </button>

      {/* 标题 */}
      <div className={styles.titleContainer}>
        <h1 className={styles.title}>
          你的出生地<br />在哪？
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
          autoFocus
          aria-label="出生地输入"
        />
      </div>

      {/* 底部区域（使用Auto Layout） */}
      <div className={styles.bottomSection}>
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
    </div>
  );
}
