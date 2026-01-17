// [INPUT] zustand的create函数, api/auth中的authApi, types中的认证相关类型
// [OUTPUT] useAuthStore hook, 提供用户认证状态管理和操作方法(login, logout, checkAuth等)
// [POS] 状态管理层的认证Store, 管理用户登录状态和token, 与认证API交互
import { create } from 'zustand';
import { authApi } from '../api';
import type { UserSession, LoginRequest, RegisterRequest } from '../types';

interface AuthState {
  // State
  isAuthenticated: boolean;
  user: UserSession | null;
  token: string | null;
  
  // Actions
  login: (credentials: LoginRequest) => Promise<void>;
  register: (data: RegisterRequest) => Promise<void>;
  logout: () => Promise<void>;
  checkAuth: () => Promise<void>;
  setUser: (user: UserSession | null) => void;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  isAuthenticated: false,
  user: null,
  token: localStorage.getItem('auth_token'),

  login: async (credentials) => {
    try {
      const response = await authApi.login(credentials);
      set({
        isAuthenticated: true,
        token: response.access_token,
      });
      // 登录后获取用户信息（如果需要）
      // await get().checkAuth();
    } catch (error) {
      console.error('Login failed:', error);
      throw error;
    }
  },

  register: async (data) => {
    try {
      await authApi.register(data);
      // 注册成功后可以自动登录或跳转到验证页面
    } catch (error) {
      console.error('Registration failed:', error);
      throw error;
    }
  },

  logout: async () => {
    try {
      await authApi.logout();
    } catch (error) {
      console.error('Logout failed:', error);
    } finally {
      set({
        isAuthenticated: false,
        user: null,
        token: null,
      });
    }
  },

  checkAuth: async () => {
    const token = get().token || localStorage.getItem('auth_token');
    if (!token) {
      set({ isAuthenticated: false, user: null });
      return;
    }

    try {
      // 这里可以调用获取用户信息的API来验证token
      // const user = await usersApi.getProfile();
      // set({ isAuthenticated: true, user });
      set({ isAuthenticated: true });
    } catch (error) {
      set({ isAuthenticated: false, user: null, token: null });
      localStorage.removeItem('auth_token');
    }
  },

  setUser: (user) => {
    set({ user, isAuthenticated: !!user });
  },
}));


