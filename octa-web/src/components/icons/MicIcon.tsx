// [INPUT] React, SVG路径数据, 图标props(className, width, height, color)
// [OUTPUT] MicIcon组件, 麦克风SVG图标组件
// [POS] 组件层的图标组件, 提供可复用的麦克风图标, 用于语音输入功能等场景
import React from 'react';

interface MicIconProps {
  className?: string;
  width?: number;
  height?: number;
  color?: string;
}

export const MicIcon: React.FC<MicIconProps> = ({
  className,
  width = 24,
  height = 24,
  color = 'currentColor',
}) => {
  return (
    <svg
      className={className}
      width={width}
      height={height}
      viewBox="0 0 24 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M12 1C10.34 1 9 2.34 9 4V12C9 13.66 10.34 15 12 15C13.66 15 15 13.66 15 12V4C15 2.34 13.66 1 12 1Z"
        fill={color}
      />
      <path
        d="M19 10V12C19 15.87 15.87 19 12 19C8.13 19 5 15.87 5 12V10M12 19V23M8 23H16"
        stroke={color}
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
};


