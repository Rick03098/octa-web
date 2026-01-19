// [INPUT] react-router-dom的useNavigate, React hooks(useState, useRef, useEffect), constants中的DSStrings, 样式文件, ArrowLeftIcon和InfoIcon图标, captureStore
// [OUTPUT] CaptureView组件, 实时相机预览UI, 拍摄照片功能, 闪光灯(torch)控制, 保存图片到store, 导航至教程/主界面/完成页面
// [POS] 特征层的拍摄组件, 连接教程页面和拍摄完成页面, 提供核心的相机拍摄功能, 优先使用超广角摄像头, 支持手电筒模式闪光灯
import { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { DSStrings } from '../../constants/strings';
import { ArrowLeftIcon } from '../../components/icons/ArrowLeftIcon';
import { InfoIcon } from '../../components/icons/InfoIcon';
import { FlashButton, ShutterButton } from '../../components/CameraControls';
import { useCaptureStore } from '../../stores/captureStore';
import styles from './CaptureView.module.css';

export function CaptureView() {
  const navigate = useNavigate();
  const videoRef = useRef<HTMLVideoElement>(null);
  const [stream, setStream] = useState<MediaStream | null>(null);
  const [flashEnabled, setFlashEnabled] = useState(false);
  const [flashSupported, setFlashSupported] = useState(false); // 设备是否支持闪光灯
  const [isCapturing, setIsCapturing] = useState(false);
  const [cameraError, setCameraError] = useState<string | null>(null);
  
  // 获取 store 的保存方法
  const setCapturedImage = useCaptureStore((state) => state.setCapturedImage);

  // 启用真实相机
  const useCameraStream = true;

  // 尝试获取超广角摄像头（0.5x）
  // 优先顺序：超广角 > 普通后置摄像头
  const findUltraWideCamera = async (): Promise<string | null> => {
    try {
      // 先请求一次权限，否则 enumerateDevices 可能不返回设备标签
      await navigator.mediaDevices.getUserMedia({ video: true });
      
      const devices = await navigator.mediaDevices.enumerateDevices();
      const videoDevices = devices.filter(d => d.kind === 'videoinput');
      
      console.log('[Camera] Available video devices:', videoDevices.map(d => ({
        deviceId: d.deviceId.slice(0, 8) + '...',
        label: d.label,
      })));
      
      // 查找超广角摄像头（不同设备标签不同）
      // 常见标签包含：ultra, wide, 0.5, 广角 等
      const ultraWideKeywords = ['ultra', 'wide', '0.5', '广角', 'back ultra', 'rear ultra'];
      
      for (const device of videoDevices) {
        const labelLower = device.label.toLowerCase();
        // 确保是后置摄像头的超广角
        const isBackCamera = labelLower.includes('back') || labelLower.includes('rear') || labelLower.includes('后');
        const isUltraWide = ultraWideKeywords.some(kw => labelLower.includes(kw));
        
        if (isUltraWide || (isBackCamera && labelLower.includes('0'))) {
          console.log('[Camera] Found ultra-wide camera:', device.label);
          return device.deviceId;
        }
      }
      
      // 如果没找到明确的超广角，尝试找第一个非主摄的后置摄像头
      // （某些设备上超广角是第二个后置摄像头）
      const backCameras = videoDevices.filter(d => {
        const label = d.label.toLowerCase();
        return label.includes('back') || label.includes('rear') || label.includes('后') || label.includes('environment');
      });
      
      if (backCameras.length > 1) {
        // 假设第二个后置摄像头可能是超广角
        console.log('[Camera] Multiple back cameras found, trying second one:', backCameras[1].label);
        return backCameras[1].deviceId;
      }
      
      console.log('[Camera] No ultra-wide camera found, will use default back camera');
      return null;
    } catch (error) {
      console.error('[Camera] Error finding ultra-wide camera:', error);
      return null;
    }
  };

  // 初始化相机
  useEffect(() => {
    let mediaStream: MediaStream | null = null;

    const initCamera = async () => {
      // 如果不使用相机流，跳过初始化
      if (!useCameraStream) return;
      
      try {
        // 检查是否支持 mediaDevices API
        if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
          setCameraError('您的浏览器不支持相机功能');
          return;
        }

        // 尝试获取超广角摄像头
        const ultraWideDeviceId = await findUltraWideCamera();
        
        // 构建约束条件
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const constraints: any = {
          video: {
            width: { ideal: 1920 },
            height: { ideal: 1080 },
          },
        };
        
        if (ultraWideDeviceId) {
          // 使用找到的超广角摄像头
          constraints.video.deviceId = { exact: ultraWideDeviceId };
          console.log('[Camera] Using ultra-wide camera');
        } else {
          // 回退到普通后置摄像头
          constraints.video.facingMode = 'environment';
          console.log('[Camera] Using default back camera (ultra-wide not found)');
        }

        mediaStream = await navigator.mediaDevices.getUserMedia(constraints);
        setStream(mediaStream);
        setCameraError(null);

        // 打印实际使用的摄像头信息
        const videoTrack = mediaStream.getVideoTracks()[0];
        if (videoTrack) {
          console.log('[Camera] Active camera:', videoTrack.label);
          // 尝试获取摄像头能力信息
          const capabilities = videoTrack.getCapabilities?.();
          if (capabilities) {
            console.log('[Camera] Capabilities:', {
              facingMode: capabilities.facingMode,
              // eslint-disable-next-line @typescript-eslint/no-explicit-any
              zoom: (capabilities as any).zoom,
              // eslint-disable-next-line @typescript-eslint/no-explicit-any
              torch: (capabilities as any).torch,
            });
            
            // 检查是否支持闪光灯（torch）
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            if ((capabilities as any).torch) {
              setFlashSupported(true);
              console.log('[Camera] Torch/Flash is supported');
            } else {
              setFlashSupported(false);
              console.log('[Camera] Torch/Flash is NOT supported');
            }
          }
        }

        if (videoRef.current) {
          videoRef.current.srcObject = mediaStream;
        }
      } catch (error) {
        console.error('Error accessing camera:', error);
        if (error instanceof Error) {
          if (error.name === 'NotAllowedError' || error.name === 'PermissionDeniedError') {
            setCameraError('相机权限被拒绝，请在设置中允许访问相机');
          } else if (error.name === 'NotFoundError') {
            setCameraError('未找到相机设备');
          } else if (error.name === 'OverconstrainedError') {
            // 如果超广角摄像头不可用，回退到普通后置摄像头
            console.log('[Camera] Ultra-wide camera not available, falling back to default');
            try {
              mediaStream = await navigator.mediaDevices.getUserMedia({
                video: {
                  facingMode: 'environment',
                  width: { ideal: 1920 },
                  height: { ideal: 1080 },
                },
              });
              setStream(mediaStream);
              setCameraError(null);
              if (videoRef.current) {
                videoRef.current.srcObject = mediaStream;
              }
            } catch (fallbackError) {
              console.error('Fallback camera error:', fallbackError);
              setCameraError('无法访问相机');
            }
          } else {
            setCameraError('无法访问相机: ' + error.message);
          }
        }
      }
    };

    initCamera();

    // 清理函数：关闭相机
    return () => {
      if (mediaStream) {
        mediaStream.getTracks().forEach((track) => track.stop());
      }
    };
  }, [useCameraStream]);

  // 返回主界面
  const handleBack = () => {
    navigate('/main');
  };

  // 打开教程
  const handleTutorial = () => {
    navigate('/tutorial');
  };

  // 切换闪光灯（手电筒模式）
  const handleToggleFlash = async () => {
    if (!stream) {
      console.log('[Flash] No stream available');
      return;
    }

    const videoTrack = stream.getVideoTracks()[0];
    if (!videoTrack) {
      console.log('[Flash] No video track available');
      return;
    }

    // 检查是否支持 torch
    const capabilities = videoTrack.getCapabilities?.();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    if (!capabilities || !(capabilities as any).torch) {
      console.log('[Flash] Torch not supported on this device');
      // 即使不支持也切换 UI 状态，让用户知道尝试过了
      setFlashEnabled((prev) => !prev);
      return;
    }

    const newFlashState = !flashEnabled;
    
    try {
      // 使用 applyConstraints 来控制闪光灯
      await videoTrack.applyConstraints({
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        advanced: [{ torch: newFlashState } as any],
      });
      
      setFlashEnabled(newFlashState);
      console.log('[Flash] Torch turned', newFlashState ? 'ON' : 'OFF');
    } catch (error) {
      console.error('[Flash] Error toggling torch:', error);
      // 如果失败，可能是设备不支持，更新支持状态
      setFlashSupported(false);
    }
  };

  // 拍摄照片
  const handleCapture = async () => {
    if (isCapturing) return;

    setIsCapturing(true);

    try {
      // 如果有视频流，则捕获照片
      if (videoRef.current && useCameraStream && stream) {
        const canvas = document.createElement('canvas');
        canvas.width = videoRef.current.videoWidth || 1920;
        canvas.height = videoRef.current.videoHeight || 1080;

        const context = canvas.getContext('2d');
        if (context) {
          context.drawImage(videoRef.current, 0, 0);

          // 转换为 Blob
          canvas.toBlob(
            (blob) => {
              if (blob) {
                // 转换为 Base64
                const reader = new FileReader();
                reader.onloadend = () => {
                  const base64 = reader.result as string;
                  // 保存到 store
                  setCapturedImage(base64, blob, 'image/jpeg');
                  console.log('Photo captured and saved to store');
                  navigate('/capture-complete');
                };
                reader.readAsDataURL(blob);
              } else {
                console.error('Failed to create blob from canvas');
                navigate('/capture-complete');
              }
            },
            'image/jpeg',
            0.95
          );
          return; // 等待 blob 回调完成后再导航
        }
      } else {
        // 占位图片模式，直接跳转到拍摄完成页面
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
      {/* 注意：只有后置摄像头才支持闪光灯（torch），前置摄像头不支持 */}
      <div className={styles.flashButtonContainer}>
        <FlashButton
          enabled={flashEnabled}
          onClick={handleToggleFlash}
          ariaLabel={DSStrings.Capture.flash}
          disabled={stream !== null && !flashSupported} // 相机初始化后且不支持闪光灯时禁用
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

