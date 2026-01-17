/**
 * [INPUT]: 依赖 @ncdai/react-wheel-picker 的核心组件和类型
 * [OUTPUT]: 对外提供 UnifiedWheelPicker 组件，统一的时间选择器适配层
 * [POS]: components/ 的滚轮选择器适配器，桥接第三方库API和项目设计系统
 * [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
 */

import { useMemo } from 'react';
import { WheelPicker } from '@ncdai/react-wheel-picker';
import type {
  WheelPickerOption,
  WheelPickerValue,
} from '@ncdai/react-wheel-picker';
import '@ncdai/react-wheel-picker/style.css';
import styles from './UnifiedWheelPicker.module.css';

// ============================================================================
// TYPES
// ============================================================================

interface UnifiedWheelPickerProps<T extends number | string> {
  /** 可选值数组（数字或字符串） */
  values: T[];
  /** 当前选中的值 */
  selectedValue: T;
  /** 值变化回调 */
  onChange: (value: T) => void;
  /** 数字选择器的后缀标签（如 "年"、"月"、"日"） */
  labelSuffix?: string;
  /** 是否启用循环滚动（默认 true） */
  infinite?: boolean;
  /** 自定义容器类名 */
  containerClassName?: string;
}

// ============================================================================
// COMPONENT
// ============================================================================

/**
 * 统一滚轮选择器组件
 *
 * 架构设计：
 * - 基础层：@ncdai/react-wheel-picker 提供惯性滚动、循环逻辑、事件处理
 * - 适配层：UnifiedWheelPicker 桥接库API和项目设计系统
 * - 业务层：BirthdayInput/BirthTimeInput 使用统一接口
 *
 * 核心特性：
 * - 惯性滚动：速度衰减模型 v(t) = v₀ × e^(-kt)
 * - 无缝循环：使用 transform translate（GPU加速）而非 scrollTop
 * - 统一输入：Pointer Events API 处理 touch/mouse/wheel
 * - 性能优化：RAF 调度、被动事件监听、硬件加速
 */
export function UnifiedWheelPicker<T extends number | string>({
  values,
  selectedValue,
  onChange,
  labelSuffix,
  infinite = true,
  containerClassName,
}: UnifiedWheelPickerProps<T>) {
  // --------------------------------------------------------------------------
  // Data Transformation - 将 values 数组转换为 WheelPicker 的 options 格式
  // --------------------------------------------------------------------------
  const options: WheelPickerOption<T>[] = useMemo(() => {
    return values.map((value) => ({
      value,
      label: labelSuffix ? `${value}${labelSuffix}` : String(value),
    }));
  }, [values, labelSuffix]);

  // --------------------------------------------------------------------------
  // Event Handling - 桥接 onValueChange 到项目的 onChange
  // --------------------------------------------------------------------------
  const handleValueChange = (value: WheelPickerValue) => {
    onChange(value as T);
  };

  // --------------------------------------------------------------------------
  // Render
  // --------------------------------------------------------------------------
  return (
    <div className={`${styles.wrapper} ${containerClassName || ''}`}>
      {/* 顶部渐变遮罩 - 使上方选项半透明 */}
      <div className={styles.maskTop} />

      {/* 底部渐变遮罩 - 使下方选项半透明 */}
      <div className={styles.maskBottom} />

      {/* 核心滚轮选择器 */}
      <WheelPicker
        value={selectedValue}
        onValueChange={handleValueChange}
        options={options}
        infinite={infinite}
        visibleCount={3}
        optionItemHeight={52}
        classNames={{
          optionItem: styles.item,
          highlightWrapper: styles.highlightWrapper,
        }}
      />
    </div>
  );
}
