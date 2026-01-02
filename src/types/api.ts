// [INPUT] types/models中的类型定义, 后端API响应格式
// [OUTPUT] API请求和响应的TypeScript类型定义, 用于API客户端函数的类型约束
// [POS] 类型定义层的API类型文件, 定义API接口的请求和响应类型

import type {
  RegisterRequest,
  LoginRequest,
  TokenResponse,
  UserProfile,
  UpdateUserRequest,
  CreateBaziProfileRequest,
  BaziProfileResponse,
  BaziProfile,
  CreateAnalysisJobRequest,
  AnalysisJob,
  AnalysisResult,
} from './models';

/**
 * API错误响应
 */
export interface ApiError {
  error: {
    code: string;
    message: string;
    details?: Record<string, any>;
  };
}

/**
 * 分页响应
 */
export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  limit: number;
  offset: number;
}

/**
 * 认证API响应类型
 */
export type AuthRegisterResponse = {
  user_id: string;
  email: string;
  verification_token?: string;
};

export type AuthLoginResponse = TokenResponse;

export type AuthRefreshResponse = TokenResponse;

/**
 * 用户API响应类型
 */
export type UserProfileResponse = UserProfile;

export type UserUpdateResponse = UserProfile;

/**
 * 八字档案API响应类型
 */
export type BaziProfileListResponse = {
  profiles: BaziProfileResponse[];
  total: number;
  max_allowed: number;
};

export type BaziProfileCreateResponse = BaziProfileResponse;

export type BaziProfileGetResponse = BaziProfileResponse;

/**
 * 分析API响应类型
 */
export type AnalysisJobCreateResponse = AnalysisJob;

export type AnalysisJobGetResponse = AnalysisJob;

export type AnalysisResultGetResponse = AnalysisResult;

