// [INPUT] iOS版本的DSStrings.swift(作为参考), 产品文档中的字符串需求
// [OUTPUT] DSStrings常量对象, 包含所有UI字符串, 供组件使用
// [POS] 常量层的字符串定义文件, 集中管理所有UI文本, 便于本地化和维护
// 对应 iOS 的 DSStrings

export const DSStrings = {
  Common: {
    actionContinue: '继续',
    back: '返回',
  },
  Login: {
    createAccount: '创建账户',
    loginGoogle: '谷歌登录',
    memberLogin: '已有账户？会员登录',
  },
  NameEntry: {
    title: '请问该\n如何称呼你?',
  },
  Birthday: {
    title: '你的生日在\n哪一天',
  },
  BirthTime: {
    title: '你的出生时间',
    hint: '不确定可以选择中午十二点',
  },
  BirthLocation: {
    title: '你的出生地在哪?',
  },
  Gender: {
    title: '你的生理性别是',
    info: '性别是八字排盘的必需信息，用于确定大运',
  },
  Permissions: {
    title: '开启权限',
    camera: '相机',
    microphone: '麦克风',
    location: '位置',
  },
  BaziResult: {
    pageTitles: ['纳音', '舒适区', '能量来源', '相冲能量'],
    placeholders: [
      '与你相冲的能量是「庚金」，原本安稳的生活状态容易被突发事件打乱。',
      '保持充足睡眠以及规律作息，能让你的木火能量保持温和流动。',
      '与信任的友人分享心得，或专注于手作、写作等需要耐心的活动，可获得长久的内在滋养。',
      '遇到任务堆叠时，先照顾好自己的节奏与界限，再决定要投入哪些链接，避免精力被过度消耗。',
    ],
  },
  Main: {
    greeting: (name: string, period: string) => `${period}好 ${name}`,
    greetingQuestion: '你今天的感受是怎样的?',
    addEnvironmentTitle: '添加你的第一个环境',
    addEnvironmentSubtitle: '开启天人合一之境',
    tabEnvironment: '环境',
    tabSelf: '自我',
    tabAdd: '添加',
  },
  SelfCenter: {
    tabFavorites: '收藏',
    tabSelf: '自我',
    tabSettings: '设置',
    sectionProfile: '个人信息',
    sectionReminder: '提醒',
    sectionLanguage: '语言',
    sectionTerms: '条款与条件',
    sectionPrivacy: '隐私',
    sectionSubscription: '订阅',
    sectionAbout: '关于',
    logout: '退出',
  },
  Tutorial: {
    title: '捕捉完整环境',
    bullet1: '将椅子和完整桌面放进框内',
    bullet2: '确保环境有足够的光亮',
    bullet3: '椅子到拍摄者之间没有遮挡',
  },
  Preview: {
    titleSpring: '春天的',
    subtitleSpring: '像风一样',
    titleLight: '唯一的光',
    subtitleLight: '糖葫芦',
    titleWander: '游离在外',
    actionOpen: '开启',
  },
  Report: {
    subtitle: '前室环境写实报告 · 工位分析',
    moreQuestions: '更多问题?',
    actionChat: '对话',
  },
  ChatIntro: {
    greeting: (name: string) => `你好 ${name}\n关于报告、环境\n或自我的\n任何疑问?\n或 随便聊聊也好`,
    prompt1: '今天莫名心情有点糟 是什么情况',
    prompt2: '报告中有提到关于事业运的分析 我该怎样提升事业运?',
    prompt3: '新买了个植物 放在哪比较合适?',
    placeholder: '输入一切',
  },
  CaptureComplete: {
    title: '感谢你的的观察',
    subtitle: '请返回座位',
  },
  Capture: {
    flash: '闪光灯',
    shutter: '拍摄',
    tutorial: '查看教程',
    back: '返回',
  },
  OrientationCapture: {
    title: '获取方向',
    subtitle: '将手机保持稳定，3秒后自动记录当前朝向',
    recording: '正在捕捉',
    completed: '已记录',
    instruction1: '将手机放在桌面',
    instruction2: '指向工作时的正前方',
    instruction3: '静待三秒',
  },
  Loading: {
    line1: '准备就绪',
    line2: '开始演算',
    perceiving: '感知环境磁场',
    analyzing: '深入解析数据',
    converging: '汇聚分析结果',
  },
};

