// [INPUT] React, SVG路径数据, 图标props(className, width, height, color)
// [OUTPUT] BookmarkIcon组件, 书签/收藏SVG图标组件
// [POS] 组件层的图标组件, 提供可复用的书签图标, 用于收藏功能等场景
import React from 'react';

interface BookmarkIconProps {
  className?: string;
  width?: number;
  height?: number;
  color?: string;
}

export const BookmarkIcon: React.FC<BookmarkIconProps> = ({
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
        d="M19 21L12 16L5 21V5C5 4.46957 5.21071 3.96086 5.58579 3.58579C5.96086 3.21071 6.46957 3 7 3H17C17.5304 3 18.0391 3.21071 18.4142 3.58579C18.7893 3.96086 19 4.46957 19 5V21Z"
        stroke={color}
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
};


