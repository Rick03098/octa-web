// [INPUT] React hooks(useRef, useEffect, useState), 字符串选择器的props(values, selectedValue等), CSS Modules样式
// [OUTPUT] StringWheelPicker组件, 适配52px高度容器的iOS风格字符串滚轮选择器, 支持触摸和鼠标操作, 支持循环滚动
// [POS] 组件层的字符串滚轮选择器组件, 专门用于时段选择等场景, 在固定高度容器内显示滚动选择器
import { useRef, useEffect, useState, useCallback, useMemo } from 'react';
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
  const rafIdRef = useRef<number | null>(null);
  const isJumpingRef = useRef(false); // 防止跳转时触发scroll事件

  const itemHeight = 52; // 与容器高度一致

  // 创建循环列表：在首尾各添加一个虚拟元素实现循环
  // 结构：[最后一个] + [原始列表] + [第一个]
  const loopValues = useMemo(() => {
    if (values.length === 0) return [];
    return [values[values.length - 1], ...values, values[0]];
  }, [values]);

  // 将实际index转换为循环列表中的index（+1因为前面有虚拟元素）
  const getLoopIndex = (realIndex: number) => realIndex + 1;
  
  // 将循环列表index转换为实际index
  const getRealIndex = (loopIndex: number) => {
    if (loopIndex <= 0) return values.length - 1; // 虚拟头部 -> 最后一个
    if (loopIndex > values.length) return 0; // 虚拟尾部 -> 第一个
    return loopIndex - 1;
  };

  // 当 selectedValue 改变时，滚动到对应位置
  // 但在循环跳转过程中不执行，避免干扰
  useEffect(() => {
    // 如果正在跳转，跳过此次更新
    if (isJumpingRef.current) return;
    
    const realIndex = values.indexOf(selectedValue);
    if (realIndex !== -1 && containerRef.current) {
      const loopIndex = getLoopIndex(realIndex);
      const scrollPosition = loopIndex * itemHeight;
      containerRef.current.scrollTop = scrollPosition;
    }
  }, [selectedValue, values, itemHeight]);

  // 处理循环跳转：当滚动到虚拟元素时，无缝跳转到对应的真实位置
  const handleLoopJump = useCallback(() => {
    if (!containerRef.current || isJumpingRef.current) return;
    
    const currentScrollTop = containerRef.current.scrollTop;
    const loopIndex = Math.round(currentScrollTop / itemHeight);
    
    // 检查是否在虚拟元素位置
    if (loopIndex <= 0) {
      // 在虚拟头部（最后一个元素的副本），跳转到真实的最后一个
      isJumpingRef.current = true;
      containerRef.current.scrollTop = values.length * itemHeight;
      setTimeout(() => { isJumpingRef.current = false; }, 150);
    } else if (loopIndex > values.length) {
      // 在虚拟尾部（第一个元素的副本），跳转到真实的第一个
      isJumpingRef.current = true;
      containerRef.current.scrollTop = itemHeight;
      setTimeout(() => { isJumpingRef.current = false; }, 150);
    }
  }, [values.length, itemHeight]);

  // 使用 requestAnimationFrame 优化滚动性能
  const handleScroll = useCallback(() => {
    if (rafIdRef.current !== null) {
      cancelAnimationFrame(rafIdRef.current);
    }
    
    rafIdRef.current = requestAnimationFrame(() => {
      if (!containerRef.current || isDragging || isJumpingRef.current) return;
      
      const scrollTop = containerRef.current.scrollTop;
      const loopIndex = Math.round(scrollTop / itemHeight);
      const realIndex = getRealIndex(loopIndex);
      
      if (realIndex >= 0 && realIndex < values.length) {
        onChange(values[realIndex]);
      }
      
      // 处理循环跳转
      handleLoopJump();
      
      rafIdRef.current = null;
    });
  }, [isDragging, itemHeight, values, onChange, handleLoopJump]);

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
    // 恢复原来的方向
    const newScrollTop = scrollTop - deltaY;
    
    // 不限制滚动范围，允许自由滚动，在handleEnd时对齐
    containerRef.current.scrollTop = newScrollTop;
  };

  const handleEnd = () => {
    setIsDragging(false);
    // 滚动到最近的item，确保对齐
    if (containerRef.current) {
      const currentScrollTop = containerRef.current.scrollTop;
      let loopIndex = Math.round(currentScrollTop / itemHeight);
      
      // 确保loopIndex在有效范围内（包括虚拟元素）
      loopIndex = Math.max(0, Math.min(loopValues.length - 1, loopIndex));
      
      // 计算目标滚动位置
      let targetScroll = loopIndex * itemHeight;
      
      // 获取实际index
      let realIndex = getRealIndex(loopIndex);
      
      // 处理虚拟元素：跳转到对应的真实位置
      const isLooping = loopIndex <= 0 || loopIndex > values.length;
      
      if (loopIndex <= 0) {
        // 虚拟头部 -> 跳转到真实的最后一个
        realIndex = values.length - 1;
        targetScroll = values.length * itemHeight;
      } else if (loopIndex > values.length) {
        // 虚拟尾部 -> 跳转到真实的第一个
        realIndex = 0;
        targetScroll = itemHeight;
      }
      
      // 如果是循环跳转，先标记防止handleScroll和useEffect干扰
      if (isLooping) {
        isJumpingRef.current = true;
        // 先立即跳转到目标位置（无动画），避免中途触发onChange
        containerRef.current.scrollTop = targetScroll;
        // 立即更新选中值
        onChange(values[realIndex]);
        // 延迟重置标志，给React足够时间完成状态更新
        setTimeout(() => {
          isJumpingRef.current = false;
        }, 150);
      } else {
        // 正常滚动到对齐位置
        containerRef.current.scrollTo({
          top: targetScroll,
          behavior: 'smooth',
        });
        // 更新选中值
        setTimeout(() => {
          onChange(values[realIndex]);
        }, 100);
      }
    }
  };

  // 全局鼠标移动和释放事件（处理鼠标移出元素的情况）
  useEffect(() => {
    if (!isDragging) return;

    const handleGlobalMouseMove = (e: MouseEvent) => {
      e.preventDefault();
      if (!containerRef.current) return;
      const deltaY = e.clientY - startY;
      // 恢复原来的方向
      const newScrollTop = scrollTop - deltaY;
      
      // 不限制滚动范围，允许自由滚动，在handleEnd时对齐
      containerRef.current.scrollTop = newScrollTop;
    };

    const handleGlobalMouseUp = () => {
      setIsDragging(false);
      // 滚动到最近的item，确保对齐
      if (containerRef.current) {
        const currentScrollTop = containerRef.current.scrollTop;
        let loopIndex = Math.round(currentScrollTop / itemHeight);
        
        // 确保loopIndex在有效范围内（包括虚拟元素）
        loopIndex = Math.max(0, Math.min(loopValues.length - 1, loopIndex));
        
        // 计算目标滚动位置
        let targetScroll = loopIndex * itemHeight;
        
        // 获取实际index
        let realIndex = getRealIndex(loopIndex);
        
        // 处理虚拟元素：跳转到对应的真实位置
        const isLooping = loopIndex <= 0 || loopIndex > values.length;
        
        if (loopIndex <= 0) {
          // 虚拟头部 -> 跳转到真实的最后一个
          realIndex = values.length - 1;
          targetScroll = values.length * itemHeight;
        } else if (loopIndex > values.length) {
          // 虚拟尾部 -> 跳转到真实的第一个
          realIndex = 0;
          targetScroll = itemHeight;
        }
        
        // 如果是循环跳转，先标记防止handleScroll和useEffect干扰
        if (isLooping) {
          isJumpingRef.current = true;
          // 先立即跳转到目标位置（无动画），避免中途触发onChange
          containerRef.current.scrollTop = targetScroll;
          // 立即更新选中值
          onChange(values[realIndex]);
          // 延迟重置标志，给React足够时间完成状态更新
          setTimeout(() => {
            isJumpingRef.current = false;
          }, 150);
        } else {
          // 正常滚动到对齐位置
          containerRef.current.scrollTo({
            top: targetScroll,
            behavior: 'smooth',
          });
          // 更新选中值
          setTimeout(() => {
            onChange(values[realIndex]);
          }, 100);
        }
      }
    };

    document.addEventListener('mousemove', handleGlobalMouseMove);
    document.addEventListener('mouseup', handleGlobalMouseUp);

    return () => {
      document.removeEventListener('mousemove', handleGlobalMouseMove);
      document.removeEventListener('mouseup', handleGlobalMouseUp);
    };
  }, [isDragging, startY, scrollTop, itemHeight, values, onChange]);

  // 清理 requestAnimationFrame
  useEffect(() => {
    return () => {
      if (rafIdRef.current !== null) {
        cancelAnimationFrame(rafIdRef.current);
      }
    };
  }, []);

  // 鼠标事件
  const handleMouseDown = (e: React.MouseEvent) => {
    // 不阻止默认行为，允许原生滚轮事件
    handleStart(e.clientY);
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
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
        className={styles.scrollContainer}
      >
        {/* 循环列表：[虚拟尾部] + [原始列表] + [虚拟头部] */}
        {loopValues.map((value, idx) => (
          <div key={`${value}-${idx}`} className={styles.item} style={{ height: itemHeight }}>
            {value}
          </div>
        ))}
      </div>
    </div>
  );
}
