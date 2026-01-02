// [INPUT] react-router-dom的useNavigate, constants中的DSStrings, 样式文件, ArrowLeftIcon图标
// [OUTPUT] TutorialView组件, 拍照教程页面UI, 导航至拍摄页面或返回主界面
// [POS] 特征层的教程组件, 引导用户了解拍摄要求, 连接主界面和拍摄功能
import { useNavigate } from 'react-router-dom';
import { DSStrings } from '../../constants/strings';
import { ArrowLeftIcon } from '../../components/icons/ArrowLeftIcon';
import styles from './TutorialView.module.css';

export function TutorialView() {
  const navigate = useNavigate();

  const handleBack = () => {
    navigate('/main');
  };

  const handleContinue = () => {
    navigate('/capture');
  };

  return (
    <div className={styles.container}>
      {/* 背景渐变 (Eclipse效果 - 淡蓝色) */}
      <div className={styles.backgroundGradient} />

      {/* 返回按钮 - Figma: left=17px, top=62px */}
      <button
        className={styles.backButton}
        onClick={handleBack}
        aria-label={DSStrings.Common.back}
      >
        <ArrowLeftIcon width={24} height={24} color="black" />
      </button>

      {/* 主要内容区域 */}
      <div className={styles.contentContainer}>
        {/* 教程插图 - Figma: left=89px, top=151px, 220x297px */}
        <div className={styles.illustrationContainer}>
          <img
            src="http://localhost:3845/assets/b4eb843683aafc4dd42a29a982a4295167ad755a.png"
            alt="拍摄教程示意图"
            className={styles.illustration}
            onError={(e) => {
              // 如果 Figma MCP 服务器不可用，使用占位符
              const target = e.target as HTMLImageElement;
              target.style.display = 'none';
            }}
          />
        </div>

        {/* 标题 - Figma: top=496px, center-x */}
        <h1 className={styles.title}>{DSStrings.Tutorial.title}</h1>

        {/* 说明文字列表 - Figma: top=564px, center-x */}
        <div className={styles.bulletList}>
          <p className={styles.bulletItem}>{DSStrings.Tutorial.bullet1}</p>
          <p className={styles.bulletItem}>{DSStrings.Tutorial.bullet2}</p>
          <p className={styles.bulletItem}>{DSStrings.Tutorial.bullet3}</p>
        </div>
      </div>

      {/* 继续按钮 - Figma: left=29px, top=743px, 340x58px */}
      <button className={styles.continueButton} onClick={handleContinue}>
        {DSStrings.Common.actionContinue}
      </button>
    </div>
  );
}

