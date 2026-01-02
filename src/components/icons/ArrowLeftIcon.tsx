// [INPUT] React, SVG路径数据, 图标props(className, width, height, color)
// [OUTPUT] ArrowLeftIcon组件, 左箭头SVG图标组件
// [POS] 组件层的图标组件, 提供可复用的左箭头图标, 用于返回按钮等场景
import React from 'react';

interface ArrowLeftIconProps {
  className?: string;
  width?: number;
  height?: number;
  color?: string;
}

export const ArrowLeftIcon: React.FC<ArrowLeftIconProps> = ({
  className,
  width = 24,
  height = 24,
  color = 'black',
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
        d="M19 12H5M5 12L11 6M5 12L11 18"
        stroke={color}
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
};

