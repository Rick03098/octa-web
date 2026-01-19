// [INPUT] React, SearchIcon组件, className和onClick等props
// [OUTPUT] GlassSearchButton组件, 带有复杂玻璃效果的搜索按钮UI
// [POS] 可复用组件层, 提供符合iOS设计规范的玻璃效果按钮, 用于搜索入口等场景
import { SearchIcon } from '../icons/SearchIcon';
import styles from './GlassSearchButton.module.css';

interface GlassSearchButtonProps {
  className?: string;
  onClick?: () => void;
}

export function GlassSearchButton({ className, onClick }: GlassSearchButtonProps) {
  return (
    <button
      className={`${styles.container} ${className || ''}`}
      onClick={onClick}
      aria-label="搜索"
    >
      <div className={styles.glassBackground} />
      <SearchIcon 
        className={styles.icon} 
        color="rgba(60, 60, 67, 0.6)" 
        width={17} 
        height={17} 
      />
    </button>
  );
}


