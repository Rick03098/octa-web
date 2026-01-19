// [INPUT] React, SVG路径数据, 图标props(className, width, height, color)
// [OUTPUT] VoiceWaveIcon组件, 声音波形SVG图标组件（4个垂直条）
// [POS] 组件层的图标组件, 提供可复用的声音波形图标, 用于语音输入功能等场景
import React from 'react';

interface VoiceWaveIconProps {
  className?: string;
  width?: number;
  height?: number;
  color?: string;
}

export const VoiceWaveIcon: React.FC<VoiceWaveIconProps> = ({
  className,
  width = 24,
  height = 24,
  color = 'rgba(151, 130, 130, 1)',
}) => {
  // 基于Figma设计的音频波形图标：4个不同高度的垂直条
  // Figma: 24x24px, 起始位置 x=4.53px, 总宽度 20.938px
  // 根据截图描述，4个条的高度从左到右：中等、最高、次高、最低
  
  // 对于24px基础尺寸
  const baseWidth = 24;
  const baseHeight = 24;
  const scale = width / baseWidth; // 缩放比例
  
  // 条的宽度和间距（基于24px设计，需要缩放）
  const barWidth = 3 * scale;
  const gap = 3 * scale;
  const startX = 4.53 * scale;
  const centerY = height / 2;
  
  // 4个条的高度（基于24px设计的像素值，从截图描述估算）
  // 从左到右：中等、最高、次高、最低
  const heights = [
    12 * scale,  // 中等
    18 * scale,  // 最高
    15 * scale,  // 次高
    9 * scale,   // 最低
  ];
  
  return (
    <svg
      className={className}
      width={width}
      height={height}
      viewBox={`0 0 ${width} ${height}`}
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      {/* 4个垂直条，从左到右 */}
      {heights.map((barHeight, index) => {
        const x = startX + index * (barWidth + gap);
        const y = centerY - barHeight / 2;
        
        return (
          <rect
            key={index}
            x={x}
            y={y}
            width={barWidth}
            height={barHeight}
            rx={barWidth / 2} // 圆角，使条看起来更圆润
            fill={color}
          />
        );
      })}
    </svg>
  );
};

