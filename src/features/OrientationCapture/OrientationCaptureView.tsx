// [INPUT] react-router-dom的useNavigate, React hooks(useEffect), constants中的DSStrings, 样式文件
// [OUTPUT] OrientationCaptureView组件, 方向获取页面的UI和逻辑, 3秒后自动导航至加载页面
// [POS] 特征层的方向获取组件, 连接拍摄完成页面和加载页面, 提供方向获取功能和用户指导
// [NOTE] 当前版本为占位实现：页面加载后等待3秒自动跳转到加载页面。完整逻辑应该是：检测设备方向稳定3秒后记录方向数据，然后跳转。待后续实现完整的设备方向检测逻辑。
import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { DSStrings } from '../../constants/strings';
import styles from './OrientationCaptureView.module.css';

export function OrientationCaptureView() {
  const navigate = useNavigate();

  // TODO: 完整逻辑应该是：检测设备方向稳定3秒后记录方向数据，然后跳转
  // 当前版本为占位实现：页面加载后等待3秒自动跳转到加载页面
  useEffect(() => {
    const timer = setTimeout(() => {
      navigate('/loading');
    }, 3000);
    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div className={styles.container}>
      {/* 背景渐变 - 与 CaptureComplete 相同 */}
      <div className={styles.backgroundGradient} />
      
      {/* 毛玻璃覆盖层 - 与 CaptureComplete 相同 */}
      <div className={styles.glassOverlay} />

      {/* 内容区域 */}
      <div className={styles.content}>
        {/* 一个向上指向的箭头图标 - 使用 Bauhaus 15.svg */}
        <div className={styles.arrowContainer}>
          <svg
            className={styles.arrowIcon}
            width="137"
            height="137"
            viewBox="0 0 137 137"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M67.6284 86.3128L68.4995 85.2845L69.3716 86.3128L95.439 117.069L41.5601 117.069L67.6284 86.3128ZM67.6284 53.9095L68.4995 52.8811L69.3716 53.9095L95.439 84.6653H41.5601L67.6284 53.9095ZM68.4995 20.4798L95.439 52.263L41.5601 52.263L68.4995 20.4798Z"
              stroke="white"
              strokeWidth="2"
            />
          </svg>
        </div>

        {/* 文本内容 */}
        <div className={styles.textContainer}>
          <p className={styles.text}>{DSStrings.OrientationCapture.instruction1}</p>
          <p className={styles.text}>{DSStrings.OrientationCapture.instruction2}</p>
          <p className={styles.text}>{DSStrings.OrientationCapture.instruction3}</p>
        </div>
      </div>

      {/* Home Indicator */}
      <div className={styles.homeIndicator} />
    </div>
  );
}

