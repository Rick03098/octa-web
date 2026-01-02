// [INPUT] React, SVG路径数据, 图标props(className, width, height, color)
// [OUTPUT] SearchIcon组件, 搜索SVG图标组件
// [POS] 组件层的图标组件, 提供可复用的搜索图标, 用于搜索框等场景
import React from 'react';

interface SearchIconProps {
  className?: string;
  width?: number;
  height?: number;
  color?: string;
}

export const SearchIcon: React.FC<SearchIconProps> = ({
  className,
  width = 17,
  height = 17,
  color = 'currentColor',
}) => {
  return (
    <svg
      className={className}
      width={width}
      height={height}
      viewBox="0 0 17 17"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <circle
        cx="7.5"
        cy="7.5"
        r="6.5"
        stroke={color}
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M12.5 12.5L16 16"
        stroke={color}
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
};

