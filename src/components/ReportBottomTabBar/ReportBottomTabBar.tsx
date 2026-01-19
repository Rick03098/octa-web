// [INPUT] React, 样式文件, onClick回调函数, SVG图标文件
// [OUTPUT] ReportBottomTabBar组件, 报告页底部tab栏的UI和交互逻辑
// [POS] 组件层的报告底部导航组件, 提供收藏和分享功能, 固定在报告页底部
import React from 'react';
import styles from './ReportBottomTabBar.module.css';

interface ReportBottomTabBarProps {
  onBookmarkClick?: () => void;
  onShareClick?: () => void;
}

export const ReportBottomTabBar: React.FC<ReportBottomTabBarProps> = ({
  onBookmarkClick,
  onShareClick,
}) => {
  return (
    <div className={styles.container}>
      {/* 白色背景 */}
      <div className={styles.background} />

      {/* 图标容器 - 使用 flexbox 水平居中排列 */}
      <div className={styles.iconsWrapper}>
        {/* 收藏图标 - 左侧 */}
        <button
          className={styles.bookmarkButton}
          onClick={onBookmarkClick}
          aria-label="收藏"
        >
          <img
            src="/icons/elements.svg"
            alt="收藏"
            className={styles.icon}
          />
        </button>

        {/* 星形图标 - 居中 */}
        <div className={styles.starContainer}>
          <img
            src="/icons/Star 1.svg"
            alt=""
            className={styles.starIcon}
          />
        </div>

        {/* 分享图标 - 右侧 */}
        <button
          className={styles.shareButton}
          onClick={onShareClick}
          aria-label="分享"
        >
          <img
            src="/icons/share.svg"
            alt="分享"
            className={styles.icon}
          />
        </button>
      </div>
    </div>
  );
};

