// [INPUT] React, SVG路径数据, 图标props(className, width, height, color)
// [OUTPUT] ShareIcon组件, 分享SVG图标组件
// [POS] 组件层的图标组件, 提供可复用的分享图标, 用于分享功能等场景
import React from 'react';

interface ShareIconProps {
  className?: string;
  width?: number;
  height?: number;
  color?: string;
}

export const ShareIcon: React.FC<ShareIconProps> = ({
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
        d="M18 8C19.6569 8 21 6.65685 21 5C21 3.34315 19.6569 2 18 2C16.3431 2 15 3.34315 15 5C15 5.35064 15.0602 5.68722 15.1707 6M18 8C17.4932 8 17.0281 7.81946 16.6587 7.51882L7.34131 12.4812C7.97191 12.1805 8.50678 12 9 12C10.6569 12 12 13.3431 12 15C12 16.6569 10.6569 18 9 18C7.34315 18 6 16.6569 6 15C6 14.6494 6.06015 14.3128 6.17071 14M18 8V11M6 3C4.34315 3 3 4.34315 3 6C3 7.65685 4.34315 9 6 9C7.65685 9 9 7.65685 9 6C9 4.34315 7.65685 3 6 3Z"
        stroke={color}
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
};

