// [INPUT] api/client中的apiClient, types中的认证相关类型(RegisterRequest, LoginRequest等)
// [OUTPUT] 认证相关的API函数(register, login, refresh等), 返回类型化的响应
// [POS] API层的认证模块, 封装所有认证相关的API调用
import { api } from './client';
import type {
  RegisterRequest,
  LoginRequest,
  AuthRegisterResponse,
  AuthLoginResponse,
  AuthRefreshResponse,
  TokenResponse,
} from '../types';

export const authApi = {
  /**
   * 用户注册
   */
  register: async (data: RegisterRequest): Promise<AuthRegisterResponse> => {
    return api.post('/v1/auth/register', data);
  },

  /**
   * 用户登录
   */
  login: async (data: LoginRequest): Promise<AuthLoginResponse> => {
    const response = await api.post<AuthLoginResponse>('/v1/auth/login', data);
    // 登录成功后保存token
    if (response.access_token) {
      localStorage.setItem('auth_token', response.access_token);
      if (response.refresh_token) {
        localStorage.setItem('refresh_token', response.refresh_token);
      }
    }
    return response;
  },

  /**
   * OAuth登录（Google/Apple）
   */
  loginOAuth: async (provider: 'google' | 'apple', idToken: string): Promise<AuthLoginResponse> => {
    const response = await api.post<AuthLoginResponse>('/v1/auth/login-oauth', {
      provider,
      id_token: idToken,
    });
    // 登录成功后保存token
    if (response.access_token) {
      localStorage.setItem('auth_token', response.access_token);
      if (response.refresh_token) {
        localStorage.setItem('refresh_token', response.refresh_token);
      }
    }
    return response;
  },

  /**
   * 刷新访问令牌
   */
  refresh: async (refreshToken?: string): Promise<AuthRefreshResponse> => {
    const token = refreshToken || localStorage.getItem('refresh_token');
    if (!token) {
      throw new Error('No refresh token available');
    }
    const response = await api.post<AuthRefreshResponse>('/v1/auth/refresh', {
      refresh_token: token,
    });
    // 更新token
    if (response.access_token) {
      localStorage.setItem('auth_token', response.access_token);
      if (response.refresh_token) {
        localStorage.setItem('refresh_token', response.refresh_token);
      }
    }
    return response;
  },

  /**
   * 登出
   */
  logout: async (): Promise<void> => {
    try {
      await api.post('/v1/auth/logout');
    } finally {
      // 无论API调用成功与否，都清除本地token
      localStorage.removeItem('auth_token');
      localStorage.removeItem('refresh_token');
    }
  },

  /**
   * 验证邮箱
   */
  verifyEmail: async (token: string): Promise<{ message: string }> => {
    return api.post('/v1/auth/verify', { token });
  },
};

