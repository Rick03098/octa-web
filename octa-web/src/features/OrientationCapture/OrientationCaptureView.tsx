// [INPUT] react-router-dom的useNavigate, React hooks(useState, useEffect, useCallback), constants中的DSStrings, 样式文件, useDeviceOrientation hook, onboardingStore, permissions工具函数
// [OUTPUT] OrientationCaptureView组件, 方向获取页面的UI和逻辑, 检测设备方向稳定3秒后记录方向数据并导航至加载页面
// [POS] 特征层的方向获取组件, 连接拍摄完成页面和加载页面, 提供陀螺仪权限请求和方向稳定检测功能
import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { DSStrings } from '../../constants/strings';
import { useDeviceOrientation } from '../../hooks/useDeviceOrientation';
import { useOnboardingStore } from '../../stores/onboardingStore';
import { requestOrientationPermission, needsOrientationPermission } from '../../utils/permissions';
import styles from './OrientationCaptureView.module.css';

// 检测阶段类型
type DetectionPhase = 'intro' | 'waiting' | 'requesting' | 'detecting' | 'error';

export function OrientationCaptureView() {
  const navigate = useNavigate();
  const setOrientationDegrees = useOnboardingStore((state) => state.setOrientationDegrees);
  
  // 检测阶段状态 - 初始显示纯指引文案（无按钮）
  const [phase, setPhase] = useState<DetectionPhase>('intro');
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  
  // 使用方向检测 Hook
  const {
    orientation,
    isStable,
    stableDuration,
    isSupported,
    isListening,
    startListening,
    stopListening,
    error: orientationError,
  } = useDeviceOrientation({
    stabilityThreshold: 5,   // 角度变化阈值 5 度
    stabilityDuration: 3,    // 稳定持续时间 3 秒
  });

  // 处理开始检测按钮点击
  const handleStartDetection = useCallback(async () => {
    setPhase('requesting');
    setErrorMessage(null);

    // 检查是否需要请求权限（iOS Safari）
    if (needsOrientationPermission()) {
      const permissionStatus = await requestOrientationPermission();
      
      if (permissionStatus === 'denied') {
        setPhase('error');
        setErrorMessage('需要授权设备方向权限才能继续');
        return;
      }
    }

    // 开始监听方向
    setPhase('detecting');
    startListening();
  }, [startListening]);

  // 监听稳定状态，自动完成
  useEffect(() => {
    if (phase === 'detecting' && isStable && orientation.alpha !== null) {
      // 记录方向到 store
      const alpha = Math.round(orientation.alpha);
      setOrientationDegrees(alpha);
      console.log('Orientation recorded:', alpha, '°', 
        '| 方位:', orientation.directionName || '?',
        '| 绝对罗盘:', orientation.absolute ? '是' : '否'
      );
      
      // 停止监听
      stopListening();

      // 直接进入 Loading（Loading 第1屏：准备就绪 / 开始演算）
      navigate('/loading');
    }
  }, [phase, isStable, orientation, setOrientationDegrees, stopListening, navigate]);

  // 处理方向检测错误
  useEffect(() => {
    if (orientationError) {
      setPhase('error');
      setErrorMessage(orientationError);
    }
  }, [orientationError]);

  // 检查设备支持
  useEffect(() => {
    if (!isSupported && phase === 'detecting') {
      setPhase('error');
      setErrorMessage('您的设备不支持方向检测');
    }
  }, [isSupported, phase]);

  // 初始状态：显示纯指引文案2秒后切换到带按钮的等待状态
  useEffect(() => {
    if (phase === 'intro') {
      const timer = setTimeout(() => {
        setPhase('waiting');
      }, 2000); // 2秒后切换到等待状态
      
      return () => clearTimeout(timer);
    }
  }, [phase]);

  // 组件卸载时停止监听
  useEffect(() => {
    return () => {
      stopListening();
    };
  }, [stopListening]);

  // 渲染检测状态文字
  const renderStatusText = () => {
    switch (phase) {
      case 'intro':
        // 初始状态：只显示前两行提示文案（无按钮）
        return (
          <>
            <p className={styles.text}>{DSStrings.OrientationCapture.instruction1}</p>
            <p className={styles.text}>{DSStrings.OrientationCapture.instruction2}</p>
          </>
        );
      case 'waiting':
        // 第二页：与第一页完全相同的文案，只是多了底部按钮
        return (
          <>
            <p className={styles.text}>{DSStrings.OrientationCapture.instruction1}</p>
            <p className={styles.text}>{DSStrings.OrientationCapture.instruction2}</p>
          </>
        );
      case 'requesting':
        return <p className={styles.text}>正在请求权限...</p>;
      case 'detecting':
        return (
          <>
            {/* 文案：正在感知 + 保持稳定，使用同一套字号样式 */}
            <p className={styles.text}>{DSStrings.OrientationCapture.recording}</p>
            <p className={styles.text}>保持稳定</p>
            {/* TODO: 正式版需删除 - 当前方向显示仅用于测试 */}
            {orientation.alpha !== null && (
              <p className={styles.textSmall}>
                {orientation.directionName || '?'} {Math.round(orientation.alpha)}°
                {orientation.absolute ? ' (罗盘)' : ' (相对)'}
              </p>
            )}
          </>
        );
      case 'error':
        return (
          <>
            <p className={styles.textError}>{errorMessage || '检测失败'}</p>
            <p className={styles.textSmall}>请刷新页面重试</p>
          </>
        );
    }
  };

  return (
    <div className={styles.container}>
      {/* 背景渐变 - 与 CaptureComplete 相同 */}
      <div className={styles.backgroundGradient} />
      
      {/* 毛玻璃覆盖层 - 与 CaptureComplete 相同 */}
      <div className={styles.glassOverlay} />

      {/* 内容区域：箭头 + 文案（居中） */}
      <div className={styles.content}>
        {/* 箭头图标 - 在检测中时添加脉冲动画，初始状态和等待状态都显示 */}
        <div className={`${styles.arrowContainer} ${phase === 'detecting' ? styles.detecting : ''}`}>
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
          {renderStatusText()}
        </div>

        {/* 进度指示器 - 在检测中显示 */}
        {phase === 'detecting' && (
          <div className={styles.progressContainer}>
            <div
              className={styles.progressBar}
              style={{ width: `${(stableDuration / 3) * 100}%` }}
            />
          </div>
        )}
      </div>

      {/* 底部按钮区域：Figma 底部大号圆角按钮布局 */}
      <div className={styles.buttonContainer}>
        {/* 继续按钮 - 等待阶段显示，取代原来的“开始检测方向” */}
        {phase === 'waiting' && (
          <button
            className={styles.startButton}
            onClick={handleStartDetection}
          >
            {DSStrings.Common.actionContinue}
          </button>
        )}

        {/* 重试按钮 - 错误阶段显示，复用同一布局 */}
        {phase === 'error' && (
          <button
            className={styles.startButton}
            onClick={handleStartDetection}
          >
            重试
          </button>
        )}
      </div>
    </div>
  );
}

export default OrientationCaptureView;
