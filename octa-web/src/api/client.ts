// [INPUT] axios库, VITE_API_BASE_URL环境变量, localStorage中的auth_token, 后端API响应
// [OUTPUT] 配置好的axios客户端实例, 自动添加JWT token的请求拦截器, 统一错误处理的响应拦截器
// [POS] API层的核心入口, 所有API调用必须通过此客户端, 处理认证和错误
import axios from 'axios';
import type { AxiosError, AxiosInstance, InternalAxiosRequestConfig } from 'axios';
import type { ApiError } from '../types';

const apiClient: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000',
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 30000, // 30秒超时
});

// 请求拦截器：自动添加 token
apiClient.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = localStorage.getItem('auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// 响应拦截器：统一错误处理
apiClient.interceptors.response.use(
  (response) => {
    // 直接返回数据部分
    return response.data;
  },
  (error: AxiosError<ApiError>) => {
    // 处理401未授权错误
    if (error.response?.status === 401) {
      localStorage.removeItem('auth_token');
      localStorage.removeItem('refresh_token');
      // 如果不在登录页，重定向到登录页
      if (window.location.pathname !== '/login') {
        window.location.href = '/login';
      }
    }
    
    // 返回错误信息
    return Promise.reject(error.response?.data || error.message);
  }
);

// 创建一个类型安全的包装函数
export const api = {
  get: <T = any>(url: string, config?: any) => apiClient.get<T>(url, config).then(res => res as unknown as T),
  post: <T = any>(url: string, data?: any, config?: any) => apiClient.post<T>(url, data, config).then(res => res as unknown as T),
  put: <T = any>(url: string, data?: any, config?: any) => apiClient.put<T>(url, data, config).then(res => res as unknown as T),
  patch: <T = any>(url: string, data?: any, config?: any) => apiClient.patch<T>(url, data, config).then(res => res as unknown as T),
  delete: <T = any>(url: string, config?: any) => apiClient.delete<T>(url, config).then(res => res as unknown as T),
};

export default api;
