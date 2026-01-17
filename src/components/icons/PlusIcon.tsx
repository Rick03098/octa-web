// [INPUT] React, SVG路径数据, 图标props(className, width, height, color)
// [OUTPUT] PlusIcon组件, 加号/添加SVG图标组件
// [POS] 组件层的图标组件, 提供可复用的加号图标, 用于添加按钮等场景
import React from 'react';

interface PlusIconProps {
  className?: string;
  width?: number;
  height?: number;
  color?: string;
}

export const PlusIcon: React.FC<PlusIconProps> = ({
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
        d="M12 5V19M5 12H19"
        stroke={color}
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
};


