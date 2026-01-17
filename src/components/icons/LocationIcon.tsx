// [INPUT] React, SVG路径数据, 图标props(className, width, height, color)
// [OUTPUT] LocationIcon组件, 位置/地点SVG图标组件
// [POS] 组件层的图标组件, 提供可复用的位置图标, 用于出生地输入等场景
import React from 'react';

interface LocationIconProps {
  className?: string;
  width?: number;
  height?: number;
  color?: string;
}

export const LocationIcon: React.FC<LocationIconProps> = ({
  className,
  width = 18,
  height = 18,
  color = 'currentColor',
}) => {
  return (
    <svg
      className={className}
      width={width}
      height={height}
      viewBox="0 0 18 18"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M9 1.5C6.105 1.5 3.75 3.855 3.75 6.75C3.75 11.0625 9 16.5 9 16.5C9 16.5 14.25 11.0625 14.25 6.75C14.25 3.855 11.895 1.5 9 1.5ZM9 8.625C8.3775 8.625 7.875 8.1225 7.875 7.5C7.875 6.8775 8.3775 6.375 9 6.375C9.6225 6.375 10.125 6.8775 10.125 7.5C10.125 8.1225 9.6225 8.625 9 8.625Z"
        fill={color}
      />
    </svg>
  );
};


