// [INPUT] navigator.mediaDevices, navigator.geolocation, DeviceOrientationEvent
// [OUTPUT] 权限请求函数, 权限状态检查函数, 返回权限状态('granted'|'denied'|'prompt')
// [POS] 工具层的权限管理模块, 封装Web权限API, 供PermissionsView和其他组件使用

/**
 * 权限状态类型
 */
export type PermissionStatus = 'granted' | 'denied' | 'prompt' | 'not-supported';

/**
 * 请求相机权限
 * 通过 getUserMedia 触发系统权限弹窗
 */
export async function requestCameraPermission(): Promise<PermissionStatus> {
  try {
    // 检查是否支持 mediaDevices API
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      console.warn('Camera API not supported');
      return 'not-supported';
    }

    // 请求相机权限
    const stream = await navigator.mediaDevices.getUserMedia({ video: true });
    
    // 立即停止流，我们只是为了获取权限
    stream.getTracks().forEach(track => track.stop());
    
    return 'granted';
  } catch (error) {
    if (error instanceof Error) {
      if (error.name === 'NotAllowedError' || error.name === 'PermissionDeniedError') {
        return 'denied';
      }
      if (error.name === 'NotFoundError') {
        console.warn('No camera found');
        return 'not-supported';
      }
    }
    console.error('Camera permission error:', error);
    return 'denied';
  }
}

/**
 * 请求麦克风权限
 * 通过 getUserMedia 触发系统权限弹窗
 */
export async function requestMicrophonePermission(): Promise<PermissionStatus> {
  try {
    // 检查是否支持 mediaDevices API
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      console.warn('Microphone API not supported');
      return 'not-supported';
    }

    // 请求麦克风权限
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    
    // 立即停止流
    stream.getTracks().forEach(track => track.stop());
    
    return 'granted';
  } catch (error) {
    if (error instanceof Error) {
      if (error.name === 'NotAllowedError' || error.name === 'PermissionDeniedError') {
        return 'denied';
      }
      if (error.name === 'NotFoundError') {
        console.warn('No microphone found');
        return 'not-supported';
      }
    }
    console.error('Microphone permission error:', error);
    return 'denied';
  }
}

/**
 * 请求位置权限
 * 通过 getCurrentPosition 触发系统权限弹窗
 */
export async function requestLocationPermission(): Promise<PermissionStatus> {
  return new Promise((resolve) => {
    // 检查是否支持 Geolocation API
    if (!navigator.geolocation) {
      console.warn('Geolocation API not supported');
      resolve('not-supported');
      return;
    }

    navigator.geolocation.getCurrentPosition(
      () => {
        // 成功获取位置，说明已授权
        resolve('granted');
      },
      (error) => {
        if (error.code === error.PERMISSION_DENIED) {
          resolve('denied');
        } else {
          // 其他错误（如超时）也视为未授权
          resolve('denied');
        }
      },
      {
        timeout: 10000,
        maximumAge: 0,
      }
    );
  });
}

/**
 * 请求设备方向权限（陀螺仪）
 * iOS Safari 需要通过 requestPermission 显式请求
 * 必须由用户手势触发
 */
export async function requestOrientationPermission(): Promise<PermissionStatus> {
  // 检查是否支持 DeviceOrientationEvent
  if (typeof DeviceOrientationEvent === 'undefined') {
    console.warn('DeviceOrientationEvent not supported');
    return 'not-supported';
  }

  // iOS Safari 需要显式请求权限
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const DeviceOrientationEventWithPermission = DeviceOrientationEvent as any;
  
  if (typeof DeviceOrientationEventWithPermission.requestPermission === 'function') {
    try {
      const status = await DeviceOrientationEventWithPermission.requestPermission();
      if (status === 'granted') {
        return 'granted';
      }
      return 'denied';
    } catch (error) {
      console.error('Orientation permission error:', error);
      return 'denied';
    }
  }

  // 非iOS设备不需要请求权限，默认可用
  return 'granted';
}

/**
 * 检查相机权限状态（不触发弹窗）
 */
export async function checkCameraPermission(): Promise<PermissionStatus> {
  try {
    // 使用 Permissions API 查询状态（如果支持）
    if (navigator.permissions && navigator.permissions.query) {
      const result = await navigator.permissions.query({ name: 'camera' as PermissionName });
      return result.state as PermissionStatus;
    }
  } catch {
    // Permissions API 不支持 camera，返回 prompt
  }
  return 'prompt';
}

/**
 * 检查麦克风权限状态（不触发弹窗）
 */
export async function checkMicrophonePermission(): Promise<PermissionStatus> {
  try {
    if (navigator.permissions && navigator.permissions.query) {
      const result = await navigator.permissions.query({ name: 'microphone' as PermissionName });
      return result.state as PermissionStatus;
    }
  } catch {
    // Permissions API 不支持 microphone，返回 prompt
  }
  return 'prompt';
}

/**
 * 检查位置权限状态（不触发弹窗）
 */
export async function checkLocationPermission(): Promise<PermissionStatus> {
  try {
    if (navigator.permissions && navigator.permissions.query) {
      const result = await navigator.permissions.query({ name: 'geolocation' });
      return result.state as PermissionStatus;
    }
  } catch {
    // Permissions API 不支持，返回 prompt
  }
  return 'prompt';
}

/**
 * 检查是否需要请求设备方向权限
 * iOS Safari 返回 true，其他浏览器返回 false
 */
export function needsOrientationPermission(): boolean {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const DeviceOrientationEventWithPermission = DeviceOrientationEvent as any;
  return typeof DeviceOrientationEventWithPermission?.requestPermission === 'function';
}
