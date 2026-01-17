// [INPUT] React, SVG路径数据, 图标props(className, width, height, color)
// [OUTPUT] InfoIcon组件, 信息图标SVG组件
// [POS] 组件层的图标组件, 提供可复用的信息图标, 用于教程提示等场景
import React from 'react';

interface InfoIconProps {
  className?: string;
  width?: number;
  height?: number;
  color?: string;
}

export const InfoIcon: React.FC<InfoIconProps> = ({
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
      <circle
        cx="12"
        cy="12"
        r="10"
        stroke={color}
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M12 16V12"
        stroke={color}
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <circle cx="12" cy="8" r="1" fill={color} />
    </svg>
  );
};


