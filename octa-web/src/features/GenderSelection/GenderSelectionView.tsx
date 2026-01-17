// [INPUT] React hooks(useState), react-router-dom的useNavigate, stores中的useOnboardingStore, components中的ArrowLeftIcon, types中的UserGender, constants中的DSStrings, 样式文件
// [OUTPUT] GenderSelectionView组件, 性别选择页面的UI和交互逻辑, 用户选择性别后保存到onboardingStore并跳转到八字结果页
// [POS] 特征层的性别选择页面组件, 负责用户性别选择界面渲染和状态管理, 是引导流程的第五步
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useOnboardingStore } from '../../stores/onboardingStore';
import { ArrowLeftIcon } from '../../components/icons/ArrowLeftIcon';
import { UserGender } from '../../types/models';
import { DSStrings } from '../../constants/strings';
import styles from './GenderSelectionView.module.css';

export function GenderSelectionView() {
  const navigate = useNavigate();
  const { gender, setGender } = useOnboardingStore();
  const [selectedGender, setSelectedGender] = useState<UserGender | null>(gender || null);

  const handleSelect = (g: UserGender) => {
    setSelectedGender(g);
    setGender(g);
  };

  const handleContinue = () => {
    if (selectedGender) {
      // TODO: 跳转到八字结果页，目前暂时跳转到登录页
      navigate('/onboarding/bazi-result');
    }
  };

  const handleBack = () => {
    navigate('/onboarding/birth-location');
  };

  return (
    <div className={styles.container}>
      {/* 背景渐变 - Eclipse */}
      <div className={styles.backgroundEclipse} />
      {/* 背景渐变 - 棕色径向渐变 */}
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
          {DSStrings.Gender.title}
        </h1>
      </div>

      {/* 选项按钮容器 */}
      <div className={styles.optionsContainer}>
        {/* 男性选项 */}
        <button
          type="button"
          onClick={() => handleSelect(UserGender.MALE)}
          className={`${styles.optionButton} ${selectedGender === UserGender.MALE ? styles.optionButtonSelected : ''}`}
          aria-label="选择男性"
        >
          {UserGender.MALE}
        </button>

        {/* 女性选项 */}
        <button
          type="button"
          onClick={() => handleSelect(UserGender.FEMALE)}
          className={`${styles.optionButton} ${selectedGender === UserGender.FEMALE ? styles.optionButtonSelected : ''}`}
          aria-label="选择女性"
        >
          {UserGender.FEMALE}
        </button>
      </div>

      {/* 底部区域（使用Auto Layout） */}
      <div className={styles.bottomSection}>
        {/* 提示文字 */}
        <div className={styles.hintText}>
          {DSStrings.Gender.info}
        </div>

        {/* 继续按钮 */}
        <button
          className={styles.continueButton}
          onClick={handleContinue}
          disabled={!selectedGender}
          aria-label={DSStrings.Common.actionContinue}
        >
          {DSStrings.Common.actionContinue}
        </button>
      </div>
    </div>
  );
}
