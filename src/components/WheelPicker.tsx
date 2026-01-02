// [INPUT] React hooks(useRef, useEffect, useState), 滚轮选择器的props(values, selectedValue等)
// [OUTPUT] WheelPicker组件, iOS风格的滚轮选择器UI组件
// [POS] 组件层的滚轮选择器组件, 用于日期、时间等选择场景, 模拟iOS的滚轮选择器效果
import React, { useRef, useEffect, useState } from 'react';

interface WheelPickerProps {
  values: number[];
  selectedValue: number;
  onChange: (value: number) => void;
  labelSuffix: string;
  height?: number;
}

export const WheelPicker: React.FC<WheelPickerProps> = ({
  values,
  selectedValue,
  onChange,
  labelSuffix,
  height = 200,
}) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const [isDragging, setIsDragging] = useState(false);
  const [startY, setStartY] = useState(0);
  const [scrollTop, setScrollTop] = useState(0);

  const itemHeight = 56;
  const visibleItems = 3;
  const paddingTop = itemHeight; // 顶部padding，让第一个item居中

  useEffect(() => {
    const index = values.indexOf(selectedValue);
    if (index !== -1 && containerRef.current) {
      const scrollPosition = index * itemHeight;
      containerRef.current.scrollTop = scrollPosition;
    }
  }, [selectedValue, values]);

  const handleScroll = () => {
    if (!containerRef.current || isDragging) return;
    const scrollTop = containerRef.current.scrollTop;
    const index = Math.round(scrollTop / itemHeight);
    if (index >= 0 && index < values.length) {
      onChange(values[index]);
    }
  };

  const handleMouseDown = (e: React.MouseEvent) => {
    setIsDragging(true);
    setStartY(e.clientY);
    if (containerRef.current) {
      setScrollTop(containerRef.current.scrollTop);
    }
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!isDragging || !containerRef.current) return;
    const deltaY = e.clientY - startY;
    containerRef.current.scrollTop = scrollTop - deltaY;
  };

  const handleMouseUp = () => {
    setIsDragging(false);
    handleScroll();
  };

  return (
    <div className="relative flex-1" style={{ height }}>
      {/* 遮罩层 - 上下渐变 */}
      <div className="absolute inset-0 pointer-events-none z-10">
        <div 
          className="absolute top-0 left-0 right-0"
          style={{
            height: itemHeight,
            background: 'linear-gradient(to bottom, rgba(255,255,255,0.9), transparent)',
          }}
        />
        <div 
          className="absolute bottom-0 left-0 right-0"
          style={{
            height: itemHeight,
            background: 'linear-gradient(to top, rgba(255,255,255,0.9), transparent)',
          }}
        />
      </div>

      {/* 高亮框 */}
      <div
        className="absolute left-0 right-0 z-0 rounded-[16px] border border-white/20 bg-white/10"
        style={{
          top: itemHeight,
          height: itemHeight,
        }}
      />

      {/* 滚动容器 */}
      <div
        ref={containerRef}
        onScroll={handleScroll}
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseUp}
        className="overflow-y-scroll scrollbar-hide"
        style={{
          height,
          paddingTop,
          paddingBottom: itemHeight * (visibleItems - 1),
        }}
      >
        {values.map((value) => (
          <div
            key={value}
            className="flex items-center justify-center text-[18px] font-serif text-black"
            style={{ height: itemHeight }}
          >
            {value}{labelSuffix}
          </div>
        ))}
      </div>
    </div>
  );
};

