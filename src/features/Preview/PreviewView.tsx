// [INPUT] react-router-dom的useNavigate, constants中的DSStrings, 样式文件, imageUtils工具函数
// [OUTPUT] PreviewView组件, 报告预览页面的UI和交互逻辑, 导航至报告阅读页面
// [POS] 特征层的预览组件, 连接加载页面和报告阅读页面, 展示报告关键词预览和开启按钮
import { useNavigate } from 'react-router-dom';
import { DSStrings } from '../../constants/strings';
import styles from './PreviewView.module.css';

export function PreviewView() {
  const navigate = useNavigate();

  // 处理"开启"按钮点击，跳转到报告阅读页面
  const handleOpen = () => {
    navigate('/report');
  };

  return (
    <div className={styles.container}>
      {/* 背景渐变图片 - Figma: top=221px, left=-7px, width=400px, height=313.33px */}
      <div className={styles.gradientContainer}>
        <img
          src="/images/708-17842.png"
          alt="背景渐变"
          className={styles.gradientImage}
          onError={(e) => {
            // 容错处理：如果 Figma MCP 服务器不可用，隐藏图片
            const target = e.target as HTMLImageElement;
            target.style.display = 'none';
          }}
        />
      </div>

      {/* 关键词文本列表 */}
      {/* "春天的" - Figma: top=206.5px (center-y), left=128px (center-x), 宽度 290px */}
      <div className={styles.keyword} style={{ top: '206.5px', left: '128px' }}>
        {DSStrings.Preview.titleSpring}
      </div>

      {/* "像风一样" - Figma: top=261.5px (center-y), left=265px (center-x), 宽度 290px */}
      <div className={styles.keyword} style={{ top: '261.5px', left: '265px' }}>
        {DSStrings.Preview.subtitleSpring}
      </div>

      {/* "唯一的光" - Figma: top=316.5px (center-y), left=128px (center-x), 宽度 290px */}
      <div className={styles.keyword} style={{ top: '316.5px', left: '128px' }}>
        {DSStrings.Preview.titleLight}
      </div>

      {/* "糖葫芦" - Figma: top=371.5px (center-y), left=265px (center-x), 宽度 290px */}
      <div className={styles.keyword} style={{ top: '371.5px', left: '265px' }}>
        {DSStrings.Preview.subtitleLight}
      </div>

      {/* "游离在外" - Figma: top=465.5px (center-y), left=194px (center-x), 宽度 290px */}
      <div className={styles.keyword} style={{ top: '465.5px', left: '194px' }}>
        {DSStrings.Preview.titleWander}
      </div>

      {/* "开启"按钮 - Figma: top=630px, left=142px, width=110px, height=55px, 中心点在 197px */}
      <button className={styles.openButton} onClick={handleOpen}>
        {DSStrings.Preview.actionOpen}
      </button>
    </div>
  );
}

