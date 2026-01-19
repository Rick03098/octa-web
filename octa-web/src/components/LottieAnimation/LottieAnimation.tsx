// [INPUT] lottie-web库, React的useEffect和useRef, Lottie动画JSON文件路径
// [OUTPUT] LottieAnimation组件, 渲染Lottie动画的容器元素
// [POS] 组件层的动画渲染组件, 用于显示Lottie动画(如登录页背景动画)
import { useEffect, useRef } from 'react';
import lottie, { type AnimationItem } from 'lottie-web';
import styles from './LottieAnimation.module.css';

interface LottieAnimationProps {
  animationData: object | string; // JSON对象或文件路径
  className?: string;
  loop?: boolean;
  autoplay?: boolean;
}

export default function LottieAnimation({
  animationData,
  className,
  loop = true,
  autoplay = true,
}: LottieAnimationProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const animationRef = useRef<AnimationItem | null>(null);

  useEffect(() => {
    if (!containerRef.current) return;

    // 如果已有动画实例，先销毁
    if (animationRef.current) {
      animationRef.current.destroy();
    }

    // 创建新的动画实例
    const animation = lottie.loadAnimation({
      container: containerRef.current,
      renderer: 'svg',
      loop,
      autoplay,
      animationData: typeof animationData === 'string' ? undefined : animationData,
      path: typeof animationData === 'string' ? animationData : undefined,
      rendererSettings: {
        preserveAspectRatio: 'xMidYMin slice', // 填充整个容器，顶部对齐
      },
    });

    animationRef.current = animation;

    // 清理函数
    return () => {
      if (animationRef.current) {
        animationRef.current.destroy();
        animationRef.current = null;
      }
    };
  }, [animationData, loop, autoplay]);

  return (
    <div
      ref={containerRef}
      className={`${styles.container} ${className || ''}`}
    />
  );
}
