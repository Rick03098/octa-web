// [INPUT] api/client中的apiClient, types中的用户相关类型(UserProfile, UpdateUserRequest等)
// [OUTPUT] 用户资料相关的API函数(getProfile, updateProfile等), 返回类型化的响应
// [POS] API层的用户模块, 封装所有用户资料相关的API调用
import { api } from './client';
import type {
  UserProfileResponse,
  UserUpdateResponse,
  UpdateUserRequest,
} from '../types';

export const usersApi = {
  /**
   * 获取当前用户资料
   */
  getProfile: async (): Promise<UserProfileResponse> => {
    return api.get('/v1/users/me');
  },

  /**
   * 更新用户资料
   */
  updateProfile: async (data: UpdateUserRequest): Promise<UserUpdateResponse> => {
    return api.patch('/v1/users/me', data);
  },

  /**
   * 发起账号删除请求
   */
  requestDeletion: async (): Promise<{
    deletion_requested_at: string;
    deletion_scheduled_at: string;
    grace_period_days: number;
  }> => {
    return api.post('/v1/users/me/deletion');
  },

  /**
   * 查询账号删除进度
   */
  getDeletionStatus: async (): Promise<{
    deletion_pending: boolean;
    deletion_scheduled_at?: string;
    days_remaining?: number;
  }> => {
    return api.get('/v1/users/me/deletion');
  },

  /**
   * 撤回账号删除请求
   */
  cancelDeletion: async (): Promise<{ success: boolean; message: string }> => {
    return api.delete('/v1/users/me/deletion');
  },
};

