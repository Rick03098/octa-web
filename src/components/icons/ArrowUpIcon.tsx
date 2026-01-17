// [INPUT] React, SVG路径数据, 图标props(className, width, height, color)
// [OUTPUT] ArrowUpIcon组件, 向上箭头SVG图标组件
// [POS] 组件层的图标组件, 提供可复用的向上箭头图标, 用于发送按钮等场景
import React from 'react';

interface ArrowUpIconProps {
  className?: string;
  width?: number;
  height?: number;
  color?: string;
}

export const ArrowUpIcon: React.FC<ArrowUpIconProps> = ({
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
        d="M12 19V5M12 5L5 12M12 5L19 12"
        stroke={color}
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
};


