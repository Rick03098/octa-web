// [INPUT] 后端Pydantic模型(backend-v1/app/models/), iOS版本的UserOnboardingFlowState(作为参考)
// [OUTPUT] TypeScript类型定义, 供API客户端和组件使用, 确保前后端类型一致
// [POS] 类型定义层的基础文件, 定义所有数据模型类型, 与后端保持同步

/**
 * 前端用户引导流程状态（对应iOS的UserOnboardingFlowState）
 */
export interface UserOnboardingFlowState {
  name: string;
  birthDate: Date | null;
  birthTime: BirthTimeValue | null;
  birthLocation: string;
  gender: UserGender | null;
  orientationDegrees: number | null;
}

/**
 * 出生时间值
 */
export interface BirthTimeValue {
  hour: number; // 1-12
  minute: number; // 0-59
  period: DayPeriod;
}

/**
 * 一天时段（上午/下午）
 */
export enum DayPeriod {
  AM = '上午',
  PM = '下午',
}

/**
 * 用户性别
 */
export enum UserGender {
  MALE = '男性',
  FEMALE = '女性',
}

// ============================================================================
// 后端API类型定义（对应 backend-v1/app/models/）
// ============================================================================

/**
 * 认证相关类型（对应 backend-v1/app/models/auth.py）
 */
export interface RegisterRequest {
  email: string;
  password: string;
  language?: string;
  timezone?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface TokenResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
}

export interface UserSession {
  user_id: string;
  email: string;
  is_verified: boolean;
  is_active: boolean;
  subscription_tier: string;
  created_at: string;
  last_login?: string;
}

/**
 * 用户相关类型（对应 backend-v1/app/models/users.py）
 */
export interface UserProfile {
  user_id: string;
  email: string;
  display_name?: string;
  language: string;
  timezone: string;
  is_verified: boolean;
  is_active: boolean;
  subscription_tier: string;
  subscription_expires_at?: string;
  created_at: string;
  updated_at: string;
  last_login?: string;
  metadata?: Record<string, any>;
}

export interface UpdateUserRequest {
  display_name?: string;
  language?: string;
  timezone?: string;
}

/**
 * 八字相关类型（对应 backend-v1/app/models/profiles.py）
 */
export interface BaziElements {
  wood: number;
  fire: number;
  earth: number;
  metal: number;
  water: number;
}

export interface BaziPillar {
  heavenly_stem: string; // 天干
  earthly_branch: string; // 地支
  element: string; // 五行
}

export interface BaziChart {
  year_pillar: BaziPillar;
  month_pillar: BaziPillar;
  day_pillar: BaziPillar;
  hour_pillar: BaziPillar;
  day_master: string; // 日主
  elements: BaziElements;
}

export interface CreateBaziProfileRequest {
  birth_date: string; // ISO date string
  birth_time: string; // ISO time string (HH:mm:ss)
  birth_location: string;
  gender: 'male' | 'female' | 'other';
  name?: string;
}

export interface BaziProfile {
  profile_id: string;
  user_id: string;
  name?: string;
  birth_date: string;
  birth_time: string;
  birth_location: string;
  gender: string;
  chart: BaziChart;
  lucky_elements: string[];
  unlucky_elements: string[];
  lucky_directions: string[];
  lucky_colors: string[];
  personality_traits: Record<string, any>;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  last_modified_at?: string;
}

export interface BaziProfileResponse {
  profile_id: string;
  name?: string;
  birth_date: string;
  birth_time: string;
  birth_location: string;
  gender: string;
  chart: BaziChart;
  lucky_elements: string[];
  lucky_directions: string[];
  lucky_colors: string[];
  is_active: boolean;
  created_at: string;
}

export interface BaziFourSentencesResponse {
  day_pillar: string;
  strength_label: string; // 身强身弱
  sentences: {
    [key: string]: string; // Keys: "纳音", "舒适区", "能量来源", "相冲能量"
  };
}

/**
 * 分析相关类型（对应 backend-v1/app/models/analysis.py）
 */
export enum SceneType {
  WORKSPACE = 'workspace', // 工位风水
  FLOORPLAN = 'floorplan', // 户型风水
  LOOKAROUND8 = 'lookaround8', // 八方环扫
}

export enum JobStatus {
  PENDING = 'pending',
  RUNNING = 'running',
  COMPLETED = 'completed',
  FAILED = 'failed',
}

export interface CreateAnalysisJobRequest {
  scene_type: SceneType;
  bazi_profile_id: string;
  media_ids?: string[];
  media_set_id?: string;
  metadata?: Record<string, any>;
}

export interface AnalysisJob {
  job_id: string;
  user_id: string;
  scene_type: SceneType;
  bazi_profile_id: string;
  media_ids?: string[];
  media_set_id?: string;
  status: JobStatus;
  result_id?: string;
  error_message?: string;
  created_at: string;
  started_at?: string;
  completed_at?: string;
  metadata: Record<string, any>;
}

export interface FengShuiRecommendation {
  category: string;
  priority: 'high' | 'medium' | 'low';
  title: string;
  description: string;
  expected_improvement: string;
  implementation_tips: string[];
}

export interface AnalysisResult {
  result_id: string;
  job_id: string;
  user_id: string;
  scene_type: SceneType;
  bazi_profile_id: string;
  overall_score: number;
  summary: string;
  details: Record<string, any>;
  recommendations: FengShuiRecommendation[];
  lucky_elements_present: string[];
  unlucky_elements_present: string[];
  suggested_colors: string[];
  suggested_items: string[];
  analysis_version: string;
  created_at: string;
  processing_time_seconds: number;
}

/**
 * 前端展示用的类型
 */
export interface BaziResultPage {
  title: string;
  detail: string;
  gradient: string[];
}

export interface EnvironmentReportSection {
  title: string;
  body: string;
}

export interface EnvironmentReport {
  title: string;
  subtitle: string;
  sections: EnvironmentReportSection[];
}
