// [INPUT] React hooks(useRef, useEffect, useState), 字符串选择器的props(values, selectedValue等), CSS Modules样式
// [OUTPUT] StringWheelPicker组件, 适配52px高度容器的iOS风格字符串滚轮选择器, 支持触摸和鼠标操作
// [POS] 组件层的字符串滚轮选择器组件, 专门用于时段选择等场景, 在固定高度容器内显示滚动选择器
import { useRef, useEffect, useState } from 'react';
import styles from './StringWheelPicker.module.css';

interface StringWheelPickerProps {
  values: string[];
  selectedValue: string;
  onChange: (value: string) => void;
  containerClassName?: string;
}

export function StringWheelPicker({
  values,
  selectedValue,
  onChange,
  containerClassName,
}: StringWheelPickerProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [isDragging, setIsDragging] = useState(false);
  const [startY, setStartY] = useState(0);
  const [scrollTop, setScrollTop] = useState(0);

  const itemHeight = 52; // 与容器高度一致
  const visibleItems = 3; // 显示3个item（上下各一个半透明）

  useEffect(() => {
    const index = values.indexOf(selectedValue);
    if (index !== -1 && containerRef.current) {
      const scrollPosition = index * itemHeight;
      containerRef.current.scrollTop = scrollPosition;
    }
  }, [selectedValue, values, itemHeight]);

  const handleScroll = () => {
    if (!containerRef.current || isDragging) return;
    const scrollTop = containerRef.current.scrollTop;
    const index = Math.round(scrollTop / itemHeight);
    if (index >= 0 && index < values.length) {
      onChange(values[index]);
    }
  };

  const handleStart = (clientY: number) => {
    setIsDragging(true);
    setStartY(clientY);
    if (containerRef.current) {
      setScrollTop(containerRef.current.scrollTop);
    }
  };

  const handleMove = (clientY: number) => {
    if (!isDragging || !containerRef.current) return;
    const deltaY = clientY - startY;
    containerRef.current.scrollTop = scrollTop - deltaY;
  };

  const handleEnd = () => {
    setIsDragging(false);
    // 滚动到最近的item
    if (containerRef.current) {
      const scrollTop = containerRef.current.scrollTop;
      const index = Math.round(scrollTop / itemHeight);
      const targetScroll = index * itemHeight;
      containerRef.current.scrollTo({
        top: targetScroll,
        behavior: 'smooth',
      });
    }
    handleScroll();
  };

  // 鼠标事件
  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault();
    handleStart(e.clientY);
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (isDragging) {
      e.preventDefault();
      handleMove(e.clientY);
    }
  };

  const handleMouseUp = () => {
    handleEnd();
  };

  // 触摸事件
  const handleTouchStart = (e: React.TouchEvent) => {
    e.preventDefault();
    handleStart(e.touches[0].clientY);
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (isDragging) {
      e.preventDefault();
      handleMove(e.touches[0].clientY);
    }
  };

  const handleTouchEnd = () => {
    handleEnd();
  };

  return (
    <div className={`${styles.wrapper} ${containerClassName || ''}`}>
      {/* 遮罩层 - 上下渐变，只显示中间选中项和上下两个半透明项 */}
      <div className={styles.mask}>
        <div className={styles.maskTop} />
        <div className={styles.maskBottom} />
      </div>

      {/* 滚动容器 */}
      <div
        ref={containerRef}
        onScroll={handleScroll}
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseUp}
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
        className={styles.scrollContainer}
      >
        {/* 顶部padding，让第一个item可以滚动到顶部 */}
        <div style={{ height: itemHeight }} />
        {values.map((value) => (
          <div key={value} className={styles.item} style={{ height: itemHeight }}>
            {value}
          </div>
        ))}
        {/* 底部padding，让最后一个item可以滚动到底部 */}
        <div style={{ height: itemHeight }} />
      </div>
    </div>
  );
}

