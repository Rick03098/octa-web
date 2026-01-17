// [INPUT] styles/variables.css中定义的渐变颜色CSS变量
// [OUTPUT] 返回CSS渐变字符串的函数, 供组件使用
// [POS] 设计系统层的工具函数, 将CSS变量组合成可用的CSS渐变字符串

/**
 * 名字信息页渐变
 */
export function nameEntryGradient(): string {
  return `linear-gradient(180deg, var(--gradient-name-entry-1) 0%, var(--gradient-name-entry-2) 100%)`;
}

/**
 * 生日信息页渐变
 */
export function birthdayGradient(): string {
  return `linear-gradient(180deg, var(--gradient-birthday-1) 0%, var(--gradient-birthday-2) 100%)`;
}

/**
 * 出生时间页渐变（Angular - 转换为linear-gradient近似）
 */
export function birthTimeGradient(): string {
  return `linear-gradient(135deg, var(--gradient-birth-time-1) 0%, var(--gradient-birth-time-2) 50%, var(--gradient-birth-time-3) 75%, var(--gradient-birth-time-4) 100%)`;
}

/**
 * 出生地页渐变
 */
export function birthLocationGradient(): string {
  return `linear-gradient(180deg, var(--gradient-birth-location-1) 0%, var(--gradient-birth-location-2) 100%)`;
}

/**
 * 性别页渐变
 */
export function genderGradient(): string {
  return `linear-gradient(180deg, var(--gradient-gender-1) 0%, var(--gradient-gender-2) 100%)`;
}

/**
 * 权限页渐变
 */
export function permissionsGradient(): string {
  return `linear-gradient(180deg, var(--gradient-permissions-1) 0%, var(--gradient-permissions-2) 100%)`;
}

/**
 * 主界面环境渐变
 */
export function mainEnvironmentGradient(): string {
  return `linear-gradient(180deg, var(--gradient-main-environment-1) 0%, var(--gradient-main-environment-2) 50%, var(--gradient-main-environment-3) 100%)`;
}

/**
 * 自我中心页渐变
 */
export function selfCenterGradient(): string {
  return `linear-gradient(180deg, var(--gradient-self-center-1) 0%, var(--gradient-self-center-2) 50%, var(--gradient-self-center-3) 100%)`;
}

/**
 * 报告页渐变
 */
export function reportGradient(): string {
  return `linear-gradient(180deg, var(--gradient-report-1) 0%, var(--gradient-report-2) 100%)`;
}

/**
 * 聊天页渐变
 */
export function chatGradient(): string {
  return `linear-gradient(180deg, var(--gradient-chat-1) 0%, var(--gradient-chat-2) 100%)`;
}


