// [INPUT] React, onClick事件, 样式文件, flashEnabled状态
// [OUTPUT] FlashButton组件, 闪光灯控制按钮的UI和交互逻辑
// [POS] 组件层的相机控制组件, 提供可复用的闪光灯按钮, 用于拍摄页面
import React from 'react';
import styles from './FlashButton.module.css';

interface FlashButtonProps {
  enabled: boolean;
  onClick: () => void;
  ariaLabel?: string;
}

export const FlashButton: React.FC<FlashButtonProps> = ({
  enabled,
  onClick,
  ariaLabel = '闪光灯',
}) => {
  return (
    <button
      className={`${styles.flashButton} ${enabled ? styles.flashEnabled : ''}`}
      onClick={onClick}
      aria-label={ariaLabel}
    >
      {/* 闪电图标 */}
      <svg
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className={styles.flashIcon}
      >
        <path
          d="M13 2L3 14H12L11 22L21 10H12L13 2Z"
          stroke="white"
          strokeWidth="1.5"
          strokeLinecap="round"
          strokeLinejoin="round"
          fill={enabled ? 'white' : 'none'}
        />
      </svg>
    </button>
  );
};

