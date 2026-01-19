// [INPUT] window.DeviceOrientationEvent, React hooks(useState, useEffect, useRef, useCallback)
// [OUTPUT] useDeviceOrientation hook, 返回设备方向数据(真实罗盘方向)和稳定性状态, compassHeadingToDirection方位转换函数
// [POS] Hooks层的设备方向检测模块, 封装陀螺仪API, 优先使用webkitCompassHeading(iOS)或deviceorientationabsolute(Android)获取真实罗盘方向, 供OrientationCaptureView使用

import { useState, useEffect, useRef, useCallback } from 'react';

/**
 * 八个方位类型
 */
export type CompassDirection = 'N' | 'NE' | 'E' | 'SE' | 'S' | 'SW' | 'W' | 'NW';

/**
 * 方位中文名称映射
 */
export const DIRECTION_NAMES: Record<CompassDirection, string> = {
  N: '北',
  NE: '东北',
  E: '东',
  SE: '东南',
  S: '南',
  SW: '西南',
  W: '西',
  NW: '西北',
};

/**
 * 将罗盘角度转换为八个方位之一
 * @param heading 罗盘角度 (0-360)，0 = 北
 * @returns 方位代码
 */
export function compassHeadingToDirection(heading: number): CompassDirection {
  // 归一化到 0-360
  const normalized = ((heading % 360) + 360) % 360;
  
  // 每个方位占 45 度，中心偏移 22.5 度
  if (normalized >= 337.5 || normalized < 22.5) return 'N';
  if (normalized >= 22.5 && normalized < 67.5) return 'NE';
  if (normalized >= 67.5 && normalized < 112.5) return 'E';
  if (normalized >= 112.5 && normalized < 157.5) return 'SE';
  if (normalized >= 157.5 && normalized < 202.5) return 'S';
  if (normalized >= 202.5 && normalized < 247.5) return 'SW';
  if (normalized >= 247.5 && normalized < 292.5) return 'W';
  return 'NW'; // 292.5 - 337.5
}

/**
 * 设备方向数据接口
 */
export interface DeviceOrientationData {
  /** 罗盘方向角度 (0-360)，0 = 地磁北极 */
  alpha: number | null;
  /** 设备绕X轴旋转角度 (-180 to 180) */
  beta: number | null;
  /** 设备绕Y轴旋转角度 (-90 to 90) */
  gamma: number | null;
  /** 是否为绝对罗盘方向（相对于地磁北极） */
  absolute: boolean;
  /** 八方位（仅当 alpha 有值时） */
  direction: CompassDirection | null;
  /** 八方位中文名 */
  directionName: string | null;
}

/**
 * Hook 返回值接口
 */
export interface UseDeviceOrientationResult {
  /** 当前方向数据 */
  orientation: DeviceOrientationData;
  /** 方向是否稳定（3秒内变化小于阈值） */
  isStable: boolean;
  /** 稳定持续时间（秒） */
  stableDuration: number;
  /** 设备是否支持方向检测 */
  isSupported: boolean;
  /** 是否正在监听 */
  isListening: boolean;
  /** 开始监听 */
  startListening: () => void;
  /** 停止监听 */
  stopListening: () => void;
  /** 错误信息 */
  error: string | null;
}

/**
 * 配置选项
 */
interface UseDeviceOrientationOptions {
  /** 稳定判定的角度阈值（度），默认 5 */
  stabilityThreshold?: number;
  /** 稳定判定的时间阈值（秒），默认 3 */
  stabilityDuration?: number;
  /** 采样间隔（毫秒），默认 100 */
  sampleInterval?: number;
}

/**
 * 计算两个角度之间的最小差值（处理 359° → 1° 的情况）
 */
function angleDifference(angle1: number, angle2: number): number {
  const diff = Math.abs(angle1 - angle2);
  return Math.min(diff, 360 - diff);
}

/**
 * 设备方向检测 Hook
 * 
 * 功能：
 * 1. 监听 deviceorientation 事件获取设备方向
 * 2. 检测方向是否稳定（在指定时间内变化小于阈值）
 * 3. 返回当前方向和稳定状态
 * 
 * @param options 配置选项
 * @returns 方向数据和控制函数
 */
export function useDeviceOrientation(
  options: UseDeviceOrientationOptions = {}
): UseDeviceOrientationResult {
  const {
    stabilityThreshold = 5, // 角度变化阈值（度）
    stabilityDuration = 3,  // 稳定持续时间（秒）
    sampleInterval = 100,   // 采样间隔（毫秒）
  } = options;

  // 状态
  const [orientation, setOrientation] = useState<DeviceOrientationData>({
    alpha: null,
    beta: null,
    gamma: null,
    absolute: false,
    direction: null,
    directionName: null,
  });
  
  // 是否使用绝对方向事件（Android Chrome 支持 deviceorientationabsolute）
  const useAbsoluteEventRef = useRef(false);
  const [isStable, setIsStable] = useState(false);
  const [stableDuration, setStableDuration] = useState(0);
  const [isSupported, setIsSupported] = useState(true);
  const [isListening, setIsListening] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // 引用
  const alphaHistoryRef = useRef<{ value: number; timestamp: number }[]>([]);
  const lastSampleTimeRef = useRef(0);
  const stableStartTimeRef = useRef<number | null>(null);
  const stabilityCheckIntervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  // 检查稳定性
  const checkStability = useCallback(() => {
    const history = alphaHistoryRef.current;
    const now = Date.now();
    const durationMs = stabilityDuration * 1000;

    // 过滤出最近 stabilityDuration 秒内的数据
    const recentHistory = history.filter(
      (item) => now - item.timestamp <= durationMs
    );

    // 更新历史记录，移除过期数据
    alphaHistoryRef.current = recentHistory;

    // 如果数据点不够，不算稳定
    if (recentHistory.length < 5) {
      setIsStable(false);
      setStableDuration(0);
      stableStartTimeRef.current = null;
      return;
    }

    // 计算最大角度差
    const alphaValues = recentHistory.map((item) => item.value);
    let maxDiff = 0;
    for (let i = 0; i < alphaValues.length; i++) {
      for (let j = i + 1; j < alphaValues.length; j++) {
        const diff = angleDifference(alphaValues[i], alphaValues[j]);
        if (diff > maxDiff) {
          maxDiff = diff;
        }
      }
    }

    // 判断是否稳定
    if (maxDiff <= stabilityThreshold) {
      if (stableStartTimeRef.current === null) {
        stableStartTimeRef.current = now;
      }
      const currentStableDuration = (now - stableStartTimeRef.current) / 1000;
      setStableDuration(currentStableDuration);
      setIsStable(currentStableDuration >= stabilityDuration);
    } else {
      setIsStable(false);
      setStableDuration(0);
      stableStartTimeRef.current = null;
    }
  }, [stabilityDuration, stabilityThreshold]);

  // 处理方向变化事件
  // 优先使用 webkitCompassHeading (iOS Safari)，其次使用 absolute alpha
  const handleOrientation = useCallback(
    (event: DeviceOrientationEvent) => {
      const now = Date.now();

      // 节流：限制采样频率
      if (now - lastSampleTimeRef.current < sampleInterval) {
        return;
      }
      lastSampleTimeRef.current = now;

      // 获取罗盘方向（真实地磁北极方向）
      // 优先级：webkitCompassHeading (iOS) > absolute alpha > 普通 alpha
      let compassHeading: number | null = null;
      let isAbsolute = false;

      // iOS Safari 提供 webkitCompassHeading（真正的罗盘方向，0-360，0=北）
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const eventWithWebkit = event as any;
      if (typeof eventWithWebkit.webkitCompassHeading === 'number') {
        compassHeading = eventWithWebkit.webkitCompassHeading;
        isAbsolute = true;
      } else if (event.absolute && event.alpha !== null) {
        // Android 设备在 deviceorientationabsolute 事件中 absolute=true
        // alpha 值是相对于地磁北极的方向
        compassHeading = event.alpha;
        isAbsolute = true;
      } else if (event.alpha !== null) {
        // 回退：普通 alpha（可能不是绝对方向，但聊胜于无）
        compassHeading = event.alpha;
        isAbsolute = event.absolute;
      }

      // 计算八方位
      const direction = compassHeading !== null ? compassHeadingToDirection(compassHeading) : null;
      const directionName = direction ? DIRECTION_NAMES[direction] : null;

      const newOrientation: DeviceOrientationData = {
        alpha: compassHeading,
        beta: event.beta,
        gamma: event.gamma,
        absolute: isAbsolute,
        direction,
        directionName,
      };

      setOrientation(newOrientation);

      // 记录 alpha 值用于稳定性检测
      if (compassHeading !== null) {
        alphaHistoryRef.current.push({
          value: compassHeading,
          timestamp: now,
        });
      }
    },
    [sampleInterval]
  );

  // 开始监听
  const startListening = useCallback(() => {
    if (typeof window === 'undefined') {
      setError('Not in browser environment');
      setIsSupported(false);
      return;
    }

    if (!('DeviceOrientationEvent' in window)) {
      setError('DeviceOrientationEvent not supported');
      setIsSupported(false);
      return;
    }

    // 重置状态
    alphaHistoryRef.current = [];
    stableStartTimeRef.current = null;
    setIsStable(false);
    setStableDuration(0);
    setError(null);

    // 尝试监听 deviceorientationabsolute 事件（Android Chrome 支持，提供绝对罗盘方向）
    // 如果不支持则回退到 deviceorientation
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const win = window as any;
    if ('ondeviceorientationabsolute' in win || win.DeviceOrientationAbsoluteEvent) {
      useAbsoluteEventRef.current = true;
      win.addEventListener('deviceorientationabsolute', handleOrientation as EventListener);
      console.log('[useDeviceOrientation] Using deviceorientationabsolute (absolute compass)');
    } else {
      useAbsoluteEventRef.current = false;
      win.addEventListener('deviceorientation', handleOrientation);
      console.log('[useDeviceOrientation] Using deviceorientation (may use webkitCompassHeading on iOS)');
    }
    
    setIsListening(true);

    // 启动稳定性检查定时器
    stabilityCheckIntervalRef.current = setInterval(checkStability, 200);
  }, [handleOrientation, checkStability]);

  // 停止监听
  const stopListening = useCallback(() => {
    // 移除对应的事件监听
    if (useAbsoluteEventRef.current) {
      window.removeEventListener('deviceorientationabsolute', handleOrientation as EventListener);
    } else {
      window.removeEventListener('deviceorientation', handleOrientation);
    }
    setIsListening(false);

    // 清除稳定性检查定时器
    if (stabilityCheckIntervalRef.current) {
      clearInterval(stabilityCheckIntervalRef.current);
      stabilityCheckIntervalRef.current = null;
    }
  }, [handleOrientation]);

  // 组件卸载时清理
  useEffect(() => {
    return () => {
      // 移除所有可能的事件监听
      window.removeEventListener('deviceorientation', handleOrientation);
      window.removeEventListener('deviceorientationabsolute', handleOrientation as EventListener);
      if (stabilityCheckIntervalRef.current) {
        clearInterval(stabilityCheckIntervalRef.current);
      }
    };
  }, [handleOrientation]);

  return {
    orientation,
    isStable,
    stableDuration,
    isSupported,
    isListening,
    startListening,
    stopListening,
    error,
  };
}

export default useDeviceOrientation;
