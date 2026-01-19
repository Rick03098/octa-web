// [INPUT] react-router-dom的useNavigate, constants中的DSStrings, 样式文件
// [OUTPUT] CaptureCompleteView组件, 拍摄完成页面的UI, 自动导航至方向获取页面
// [POS] 特征层的拍摄完成组件, 连接拍摄页面和方向获取页面, 提供感谢信息和过渡效果
import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { DSStrings } from '../../constants/strings';
import styles from './CaptureCompleteView.module.css';

export function CaptureCompleteView() {
  const navigate = useNavigate();

  // 自动导航到方向获取页面（3秒后自动跳转）
  useEffect(() => {
    const timer = setTimeout(() => {
      navigate('/orientation');
    }, 3000);
    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div className={styles.container}>
      {/* 背景渐变 */}
      <div className={styles.backgroundGradient} />
      
      {/* 毛玻璃覆盖层 */}
      <div className={styles.glassOverlay} />

      {/* 文本内容 */}
      <div className={styles.content}>
        <p className={styles.text}>
          {DSStrings.CaptureComplete.title}
          {'\n'}
          {'\n'}
          {DSStrings.CaptureComplete.subtitle}
        </p>
      </div>
    </div>
  );
}

