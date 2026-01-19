// [INPUT] React hooks, stores中的useAuthStore, react-router-dom的useNavigate, components中的LottieAnimation, constants中的DSStrings
// [OUTPUT] LoginView组件, 登录页面的UI和交互逻辑, 触发Google登录或账户创建操作, 登录成功后跳转到引导流程
// [POS] 特征层的登录页面组件, 负责用户认证入口, 是应用流程的起始页面
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../stores';
import LottieAnimation from '../../components/LottieAnimation';
import { DSStrings } from '../../constants/strings';
// Lottie动画文件路径（从public目录引用）
const LOGIN_BACKGROUND_VIDEO_PATH = '/login-background-video.json';
import styles from './LoginView.module.css';

export function LoginView() {
  const navigate = useNavigate();
  // const { loginOAuth } = useAuthStore(); // TODO: 实现OAuth登录

  const handleCreateAccount = async () => {
    // TODO: 实现账户创建流程
    // 当前先跳转到引导流程，后续可以添加注册表单
    navigate('/onboarding/name');
  };

  const handleGoogleLogin = async () => {
    try {
      // TODO: 实现Google OAuth登录
      // 这里需要集成Google OAuth SDK
      // await loginOAuth('google', idToken);
      
      // 临时：直接跳转到引导流程
      navigate('/onboarding/name');
    } catch (error) {
      console.error('Google login failed:', error);
    }
  };

  const handleMemberLogin = () => {
    // TODO: 实现会员登录（显示邮箱密码登录表单）
    // 当前设计中没有显示登录表单，可能需要弹窗或跳转
  };

  return (
    <div className={styles.container}>
      {/* 背景Lottie动画 */}
      <div className={styles.background}>
        <LottieAnimation
          animationData={LOGIN_BACKGROUND_VIDEO_PATH}
          loop={true}
          autoplay={true}
        />
      </div>

      {/* 底部卡片 */}
      <div className={styles.bottomCard}>
        <div className={styles.buttonsContainer}>
          {/* 创建账户按钮 */}
          <button
            type="button"
            onClick={handleCreateAccount}
            className={styles.primaryButton}
          >
            {DSStrings.Login.createAccount}
          </button>

          {/* 谷歌登录按钮 */}
          <button
            type="button"
            onClick={handleGoogleLogin}
            className={styles.secondaryButton}
          >
            {DSStrings.Login.loginGoogle}
          </button>
        </div>

        {/* 会员登录链接 */}
        <button
          type="button"
          onClick={handleMemberLogin}
          className={styles.memberLoginLink}
        >
          已有账户？<span className={styles.linkText}>会员登录</span>
        </button>
      </div>
    </div>
  );
}
