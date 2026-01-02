// [INPUT] React, SVG路径数据, 图标props(className, width, height, color)
// [OUTPUT] SquareIcon组件, 方形/停止SVG图标组件
// [POS] 组件层的图标组件, 提供可复用的方形图标, 用于停止按钮等场景
import React from 'react';

interface SquareIconProps {
  className?: string;
  width?: number;
  height?: number;
  color?: string;
}

export const SquareIcon: React.FC<SquareIconProps> = ({
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
      <rect
        x="6"
        y="6"
        width="12"
        height="12"
        rx="2"
        fill={color}
      />
    </svg>
  );
};

