// [INPUT] React的children prop, styles中的CSS变量
// [OUTPUT] AppShell组件, 提供应用的基础布局(固定宽度、背景、容器样式)
// [POS] 组件层的布局容器, 所有页面内容的容器, 确保移动端固定宽度布局
import type { ReactNode } from 'react';
import styles from './AppShell.module.css';

interface AppShellProps {
  children: ReactNode;
}

export default function AppShell({ children }: AppShellProps) {
  return (
    <div className={styles.container}>
      {children}
    </div>
  );
}
