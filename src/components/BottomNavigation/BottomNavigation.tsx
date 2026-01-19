// [INPUT] React, DSStrings常量, PlusIcon组件, onAddClick回调函数
// [OUTPUT] BottomNavigation组件, 主界面底部的单个添加按钮
// [POS] 可复用组件层, 提供主界面底部的添加按钮, 可用于多个需要单个底部操作的页面
import { PlusIcon } from '../icons/PlusIcon';
import { DSStrings } from '../../constants/strings';
import styles from './BottomNavigation.module.css';

interface BottomNavigationProps {
  onAddClick?: () => void;
}

export function BottomNavigation({ onAddClick }: BottomNavigationProps) {
  return (
    <nav className={styles.container}>
      <button
        className={styles.addButton}
        onClick={onAddClick}
        aria-label={DSStrings.Main.tabAdd}
      >
        <PlusIcon 
          className={styles.addIcon} 
          color="#2B3340" 
          width={24} 
          height={24} 
        />
      </button>
    </nav>
  );
}

