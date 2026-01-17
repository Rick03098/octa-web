// [INPUT] react-router-dom的useNavigate hook, constants中的DSStrings, 样式文件, ArrowLeftIcon图标组件, ReportBottomTabBar组件, imageUtils工具函数, 报告数据(当前为占位数据)
// [OUTPUT] ReportView组件, 报告阅读页面的完整UI和交互逻辑, 导航至聊天页面的操作(右上角向右箭头按钮和底部对话按钮), 底部固定tab栏提供收藏和分享功能
// [POS] 特征层的报告组件, 连接预览页面和聊天页面, 展示完整的环境分析报告内容, 支持长内容滚动, 底部操作区跟随内容滚动, 底部固定tab栏提供收藏和分享功能
import { useNavigate } from 'react-router-dom';
import { DSStrings } from '../../constants/strings';
import { ArrowLeftIcon } from '../../components/icons/ArrowLeftIcon';
import { ReportBottomTabBar } from '../../components/ReportBottomTabBar';
import styles from './ReportView.module.css';

export function ReportView() {
  const navigate = useNavigate();

  // 处理右上角对话按钮点击，跳转到对话开启页面
  const handleChat = () => {
    navigate('/chat-intro');
  };

  // 处理收藏按钮点击
  const handleBookmark = () => {
    // TODO: 实现收藏功能
    console.log('Bookmark clicked');
  };

  // 处理分享按钮点击
  const handleShare = () => {
    // TODO: 实现分享功能
    console.log('Share clicked');
  };

  // TODO: 实际应该从后端 API 获取报告数据
  // 当前使用占位数据
  const reportData = {
    title: '前半壁街35号院 工位分析',
    date: '2025年11月6日午时| ',
    content: `（四象青龙）亮点：左侧多层收纳与文具把能量层层引流，像有一条有序的龙脉在守着你；上方软玩偶与小物件给丙火以温柔的陪伴，创意被看见也被安放。隐忧：物件偏多、色彩杂而高耸，木气易滞，灵感被碎片化；椅背披衣压在左臂动线，像把风按住。建议：保留最能点燃灵感的少数符号，其余入盒分层；左前添一株小绿植或柔光台灯，令木气生而不乱。

（四象白虎）亮点：右侧留白较多，手账与笔准备就绪，执行面清晰；打孔板把小工具收拢，白虎有边界、有规矩。隐忧：订书机等金属小件与锐角聚于右侧，易催促火气化为急躁，行动锋芒略显。建议：维持"左高右低"的格局，把尖角转向隔板或收纳盒，以一件圆润小物镇边，让出一条干净的执行通道。

（四象朱雀）亮点：前方隔板上缘透光，台前两盆小植像温柔的听众，与你的丙火彼此映照；键鼠安放，表达并未被关上。隐忧：隔板高度与前沿零碎形成一堵低墙，笔电常合盖，远望被折成近事的琐碎。建议：从键盘到前沿清出一条中轴线，桌面常用物不超过三样；抬高或开启屏幕，给朱雀一束向北的光带。
（四象玄武）亮点：椅背披衣与坐垫像一朵软云，给忙碌的你一方缓冲。隐忧：背后为空、无实靠，且椅背偏低，玄武之山不稳；久之易生"被看见却不被托住"的分神。建议：座椅更靠近桌缘，添高一点的靠垫或披毯做软靠，背后可放一只稳重色收纳箱作低山，先稳住心再点燃火。

（地支六合）子丑合：子位（北·前方）见透明水杯，丑位（东北·前右）亦有玻璃/收纳，构成子丑合——财库有源，灵感更易落地为产出。

卯戌合：卯位（东·右侧）有打孔板与执行工具，戌位（西北·前左）高位收纳与资料呼应，构成卯戌合——资源与执行对话，上级协同与扶持可期。

辰酉合：酉位（西·左侧）金属层架稳固，辰位（东南）若以盆栽之土为记，隐约成辰酉合的苗头——兴趣与偏财可被稳定滋养。

寅亥合、巳申合、午未合：未见对应迹象。

（地支六冲）卯酉冲：卯位（东·右侧）与酉位（西·左侧）两臂皆强——右侧工具与左侧高架相对，使决策易左右拉扯；宜以右侧留白与收纳软化其力。
巳亥冲：巳位（东南·后右斜）的小凳/杂物与亥位（西北·前左）的高位收纳相对，隐约成巳亥冲——流程易被临时事务打断，需设定节奏边界。
子午冲、未丑冲、寅申冲、辰戌冲：未见对应迹象。`,
    imageUrl: '/images/蓝绿浅.gif',
  };

  return (
    <div className={styles.container}>
      {/* 顶部白色背景 header */}
      <div className={styles.header}>
        {/* 对话按钮（右上角向右箭头）- Figma: left=341px, top=68px, 24x24px */}
        <button className={styles.chatNavButton} onClick={handleChat} aria-label="对话">
          <ArrowLeftIcon
            width={24}
            height={24}
            color="black"
            className={styles.arrowRightIcon}
          />
        </button>
      </div>

      {/* 滚动内容区域 */}
      <div className={styles.scrollContainer}>
        {/* 顶部图片容器 - Figma: height=211px */}
        <div className={styles.imageContainer}>
          <img
            src={reportData.imageUrl}
            alt="环境照片"
            className={styles.image}
            onError={(e) => {
              // 容错处理：如果图片加载失败，隐藏图片
              const target = e.target as HTMLImageElement;
              target.style.display = 'none';
            }}
          />
        </div>

        {/* 报告内容区域 - 白色背景卡片 */}
        <div className={styles.contentCard}>
          {/* 报告标题 - Figma: Noto Serif SC, Regular, 18px, black */}
          <h1 className={styles.title}>{reportData.title}</h1>

          {/* 日期 - Figma: Noto Serif SC, Regular, 12px, #828282 */}
          <p className={styles.date}>{reportData.date}</p>

          {/* 报告内容文本 - Figma: left=32px, Source Han Serif SC, Regular, 18px, line-height: 28px */}
          <div className={styles.content}>
            {reportData.content.split('\n').map((paragraph, index) => (
              <p key={index} className={styles.paragraph}>
                {paragraph || '\u00A0'}
              </p>
            ))}
          </div>

          {/* 底部操作区域 - 跟随内容滚动 - Figma: Component 3 */}
          <div className={styles.footer}>
            {/* "更多问题?" 文本 */}
            <p className={styles.moreQuestions}>{DSStrings.Report.moreQuestions}</p>

            {/* 向下箭头 - 24x24px, 旋转 270deg */}
            <div className={styles.arrowDown}>
              <ArrowLeftIcon
                width={24}
                height={24}
                color="black"
                className={styles.arrowDownIcon}
              />
            </div>

            {/* "对话" 按钮 - Figma: width=340px, height=58px */}
            <button className={styles.chatButton} onClick={handleChat}>
              {DSStrings.Report.actionChat}
            </button>
          </div>
        </div>

        {/* 底部间距，为底部 tab 栏留出空间 */}
        <div className={styles.bottomSpacer} />
      </div>

      {/* 底部固定 tab 栏 */}
      <ReportBottomTabBar
        onBookmarkClick={handleBookmark}
        onShareClick={handleShare}
      />
    </div>
  );
}
