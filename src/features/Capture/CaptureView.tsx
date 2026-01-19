// [INPUT] react-router-dom的useNavigate, React hooks(useState, useRef, useEffect), constants中的DSStrings, 样式文件, ArrowLeftIcon和InfoIcon图标, imageUtils工具函数
// [OUTPUT] CaptureView组件, 实时相机预览UI, 拍摄照片功能, 导航至教程/主界面/完成页面
// [POS] 特征层的拍摄组件, 连接教程页面和拍摄完成页面, 提供核心的相机拍摄功能, 背景会被实际相机画面替换
import { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { DSStrings } from '../../constants/strings';
import { ArrowLeftIcon } from '../../components/icons/ArrowLeftIcon';
import { InfoIcon } from '../../components/icons/InfoIcon';
import { FlashButton, ShutterButton } from '../../components/CameraControls';
import styles from './CaptureView.module.css';

export function CaptureView() {
  const navigate = useNavigate();
  const videoRef = useRef<HTMLVideoElement>(null);
  const [stream, setStream] = useState<MediaStream | null>(null);
  const [flashEnabled, setFlashEnabled] = useState(false);
  const [isCapturing, setIsCapturing] = useState(false);

  // TODO: 之后会启用相机视频流，替换占位图片
  const useCameraStream = false; // 设置为 true 来启用相机

  // 初始化相机
  useEffect(() => {
    let mediaStream: MediaStream | null = null;

    const initCamera = async () => {
      try {
        const constraints = {
          video: {
            facingMode: 'environment', // 使用后置摄像头
            width: { ideal: 1920 },
            height: { ideal: 1080 },
          },
        };

        mediaStream = await navigator.mediaDevices.getUserMedia(constraints);
        setStream(mediaStream);

        if (videoRef.current) {
          videoRef.current.srcObject = mediaStream;
        }
      } catch (error) {
        console.error('Error accessing camera:', error);
        // TODO: 显示错误提示，引导用户授权相机权限
      }
    };

    initCamera();

    // 清理函数：关闭相机
    return () => {
      if (mediaStream) {
        mediaStream.getTracks().forEach((track) => track.stop());
      }
    };
  }, []);

  // 返回主界面
  const handleBack = () => {
    navigate('/main');
  };

  // 打开教程
  const handleTutorial = () => {
    navigate('/tutorial');
  };

  // 切换闪光灯
  const handleToggleFlash = () => {
    setFlashEnabled((prev) => !prev);
    // TODO: 实现闪光灯控制逻辑
  };

  // 拍摄照片
  const handleCapture = async () => {
    if (isCapturing) return;

    setIsCapturing(true);

    try {
      // 如果有视频流，则捕获照片
      if (videoRef.current && useCameraStream) {
        const canvas = document.createElement('canvas');
        canvas.width = videoRef.current.videoWidth;
        canvas.height = videoRef.current.videoHeight;

        const context = canvas.getContext('2d');
        if (context) {
          context.drawImage(videoRef.current, 0, 0);

          canvas.toBlob((blob) => {
            if (blob) {
              // TODO: 保存照片到 store
              console.log('Photo captured:', blob);
              navigate('/capture-complete');
            }
          }, 'image/jpeg', 0.95);
        }
      } else {
        // 当前使用占位图片模式，直接跳转到拍摄完成页面
        // TODO: 保存占位图片数据到 store
        console.log('Photo captured (placeholder mode)');
        navigate('/capture-complete');
      }
    } catch (error) {
      console.error('Error capturing photo:', error);
      // 即使出错也跳转到完成页面
      navigate('/capture-complete');
    } finally {
      setIsCapturing(false);
    }
  };

  return (
    <div className={styles.container}>
      {/* 背景占位图片 - 之后会替换为实时相机画面 */}
      {!useCameraStream && (
        <img
          src="/images/8c1d33aa44d06566d5842aed8fc0fd8a8ea89fd7.png"
          alt="拍摄背景占位图"
          className={styles.backgroundPlaceholder}
          onError={(e) => {
            // 如果图片加载失败，隐藏占位图，显示黑色背景
            const target = e.target as HTMLImageElement;
            target.style.display = 'none';
          }}
        />
      )}
      
      {/* 相机视频流 - 之后会启用 */}
      {useCameraStream && (
        <video
          ref={videoRef}
          autoPlay
          playsInline
          muted
          className={styles.videoStream}
        />
      )}

      {/* 取景框 - 四个角的白色 L 型边框 */}
      {/* 左上角 - Figma: left=29px, top=160px, size=67px */}
      <div className={styles.frameCorner} data-position="top-left" />

      {/* 右上角 - Figma: left=296px, top=160px, size=68x67px */}
      <div className={styles.frameCorner} data-position="top-right" />

      {/* 左下角 - Figma: left=29px, top=625px, size=67px */}
      <div className={styles.frameCorner} data-position="bottom-left" />

      {/* 右下角 - Figma: left=296px, top=625px, size=68x67px */}
      <div className={styles.frameCorner} data-position="bottom-right" />

      {/* 顶部控制栏 */}
      {/* 返回按钮 - Figma: left=27px, top=67px, 44x44px */}
      <button
        className={styles.glassButton}
        style={{ left: '27px', top: '67px' }}
        onClick={handleBack}
        aria-label={DSStrings.Capture.back}
      >
        <ArrowLeftIcon width={20} height={20} color="white" />
      </button>

      {/* 教程按钮 - Figma: left=324px, top=67px, 44x44px */}
      <button
        className={styles.glassButton}
        style={{ right: '29px', top: '67px' }}
        onClick={handleTutorial}
        aria-label={DSStrings.Capture.tutorial}
      >
        <InfoIcon width={20} height={20} color="white" />
      </button>

      {/* 底部控制栏 - 使用绝对定位精确匹配 Figma 设计 */}
      {/* 闪光灯按钮 - Figma: left=29px, top=746px, 44.445x44.445px */}
      <div className={styles.flashButtonContainer}>
        <FlashButton
          enabled={flashEnabled}
          onClick={handleToggleFlash}
          ariaLabel={DSStrings.Capture.flash}
        />
      </div>

      {/* 快门按钮 - Figma: left=160px, top=733px, 72x72px */}
      <div className={styles.shutterButtonContainer}>
        <ShutterButton
          isCapturing={isCapturing}
          onClick={handleCapture}
          disabled={isCapturing}
          ariaLabel={DSStrings.Capture.shutter}
        />
      </div>
    </div>
  );
}

