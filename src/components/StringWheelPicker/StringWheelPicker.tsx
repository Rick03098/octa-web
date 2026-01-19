// [INPUT] React hooks, embla-carousel-react, 字符串选择器的props(values, selectedValue等), CSS Modules样式
// [OUTPUT] StringWheelPicker组件, 使用Embla Carousel实现iOS风格滚轮选择器, 支持惯性滚动和无限循环
// [POS] 组件层的字符串滚轮选择器组件, 专门用于时段选择等场景
import { useRef, useEffect, useCallback } from 'react';
import useEmblaCarousel from 'embla-carousel-react';
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
  const itemHeight = 36;
  const isInitializedRef = useRef(false);
  const isUserInteractingRef = useRef(false);
  
  // 当选项少于3个时，禁用loop（Embla要求至少3个选项才能loop）
  const canLoop = values.length >= 3;
  
  // 使用Embla Carousel实现垂直滚动
  const [emblaRef, emblaApi] = useEmblaCarousel({
    axis: 'y',
    loop: canLoop,
    dragFree: false,
    containScroll: canLoop ? false : 'trimSnaps',
    align: 'center',
    skipSnaps: false,
    startIndex: values.indexOf(selectedValue) >= 0 ? values.indexOf(selectedValue) : 0,
  });

  // 处理滚动结束时的选择变化
  const onSelect = useCallback(() => {
    if (!emblaApi) return;
    
    const selectedIndex = emblaApi.selectedScrollSnap();
    if (selectedIndex >= 0 && selectedIndex < values.length) {
      const newValue = values[selectedIndex];
      if (newValue !== selectedValue) {
        onChange(newValue);
      }
    }
  }, [emblaApi, values, selectedValue, onChange]);

  // 当外部selectedValue变化时，滚动到对应位置
  useEffect(() => {
    if (!emblaApi) return;
    if (isUserInteractingRef.current) return;
    
    const targetIndex = values.indexOf(selectedValue);
    if (targetIndex !== -1) {
      const currentIndex = emblaApi.selectedScrollSnap();
      if (currentIndex !== targetIndex) {
        emblaApi.scrollTo(targetIndex, !isInitializedRef.current);
        isInitializedRef.current = true;
      }
    }
  }, [emblaApi, selectedValue, values]);

  // 监听Embla事件
  useEffect(() => {
    if (!emblaApi) return;

    const onPointerDown = () => {
      isUserInteractingRef.current = true;
    };

    const onSettle = () => {
      isUserInteractingRef.current = false;
      onSelect();
    };

    emblaApi.on('pointerDown', onPointerDown);
    emblaApi.on('settle', onSettle);
    emblaApi.on('select', onSelect);

    // 初始化
    const targetIndex = values.indexOf(selectedValue);
    if (targetIndex !== -1) {
      emblaApi.scrollTo(targetIndex, true);
      isInitializedRef.current = true;
    }

    return () => {
      emblaApi.off('pointerDown', onPointerDown);
      emblaApi.off('settle', onSettle);
      emblaApi.off('select', onSelect);
    };
  }, [emblaApi, values, selectedValue, onSelect]);

  return (
    <div className={`${styles.wrapper} ${containerClassName || ''}`}>
      {/* 遮罩层 - 上下渐变 */}
      <div className={styles.mask}>
        <div className={styles.maskTop} />
        <div className={styles.maskBottom} />
      </div>

      {/* Embla容器 */}
      <div className={styles.emblaViewport} ref={emblaRef}>
        <div className={styles.emblaContainer}>
          {values.map((value, idx) => (
            <div 
              key={`${value}-${idx}`} 
              className={styles.emblaSlide}
              style={{ height: itemHeight }}
            >
              <span className={styles.itemText}>
                {value}
              </span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
