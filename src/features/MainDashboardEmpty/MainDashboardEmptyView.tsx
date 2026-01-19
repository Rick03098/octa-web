// [INPUT] React hooks, react-router-dom的useNavigate, stores中的useOnboardingStore(获取用户姓名name), constants中的DSStrings, components中的PlusIcon, Figma MCP服务器提供的渐变背景图资源
// [OUTPUT] MainDashboardEmptyView组件, 首次打开的主界面完整UI(问候语+渐变背景+空状态提示+添加按钮+底部副标题), 导航至拍摄教程页面(/tutorial)的操作
// [POS] 特征层的首次打开主界面组件, 是用户第一次完成引导流程后进入的空白主界面, 展示"添加你的第一个环境"界面, 引导用户添加第一个环境
import { useNavigate } from 'react-router-dom';
import { useOnboardingStore } from '../../stores/onboardingStore';
import { DSStrings } from '../../constants/strings';
import { PlusIcon } from '../../components/icons/PlusIcon';
import styles from './MainDashboardEmptyView.module.css';

export function MainDashboardEmptyView() {
  const navigate = useNavigate();
  const { name } = useOnboardingStore();

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

  return (
    <div className={styles.container}>
      {/* 背景渐变 - 第一个渐变层（浅色） */}
      <div className={styles.backgroundGradient} />
      {/* 背景渐变 - 第二个渐变层（浓烈） */}
      <div className={styles.backgroundGradientIntense} />

      {/* 问候区域 */}
      <div className={styles.greetingSection}>
        <h1 className={styles.greeting}>
          {period}好 <span className={styles.greetingName}>{displayName}</span>
        </h1>
      </div>

      {/* 问题文案 */}
      <p className={styles.greetingQuestion}>
        {DSStrings.Main.greetingQuestion}
      </p>

      {/* 空状态标题 - Figma: top=348.5px, left=197px (居中) */}
      <div className={styles.emptyStateTitle}>
        {DSStrings.Main.addEnvironmentTitle}
      </div>

      {/* 空状态副标题 - Figma: top=403.5px, left=197px (居中) */}
      <div className={styles.emptyStateSubtitle}>
        {DSStrings.Main.addEnvironmentSubtitle}
      </div>

      {/* 添加按钮 - 中间靠下位置 */}
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

      {/* 底部副标题 - Figma: top=892.5px, left=197px (居中) */}
      <p className={styles.bottomSubtitle}>
        {DSStrings.Main.addEnvironmentSubtitle}
      </p>
    </div>
  );
}

