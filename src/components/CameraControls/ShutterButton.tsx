// [INPUT] React, onClick事件, 样式文件, isCapturing状态
// [OUTPUT] ShutterButton组件, 快门按钮的UI和交互逻辑
// [POS] 组件层的相机控制组件, 提供可复用的快门按钮, 用于拍摄页面
import React from 'react';
import styles from './ShutterButton.module.css';

interface ShutterButtonProps {
  isCapturing?: boolean;
  onClick: () => void;
  disabled?: boolean;
  ariaLabel?: string;
}

export const ShutterButton: React.FC<ShutterButtonProps> = ({
  isCapturing = false,
  onClick,
  disabled = false,
  ariaLabel = '拍摄',
}) => {
  return (
    <button
      className={`${styles.shutterButton} ${isCapturing ? styles.shutterCapturing : ''}`}
      onClick={onClick}
      disabled={disabled}
      aria-label={ariaLabel}
    >
      {/* 外层圆环 */}
      <div className={styles.shutterOuter} />
      {/* 内层实心圆 */}
      <div className={styles.shutterInner} />
    </button>
  );
};

