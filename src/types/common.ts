// [INPUT] 无外部依赖
// [OUTPUT] 通用TypeScript类型定义, 供整个应用使用
// [POS] 类型定义层的通用类型文件, 定义应用中常用的工具类型和枚举

/**
 * 通用响应包装类型
 */
export interface ApiResponse<T = any> {
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: Record<string, any>;
  };
}

/**
 * 异步操作状态
 */
export type AsyncStatus = 'idle' | 'loading' | 'success' | 'error';

/**
 * 加载状态
 */
export interface LoadingState {
  status: AsyncStatus;
  error?: string | null;
}

/**
 * 分页参数
 */
export interface PaginationParams {
  limit?: number;
  offset?: number;
}

/**
 * 排序参数
 */
export interface SortParams {
  field: string;
  order: 'asc' | 'desc';
}

/**
 * 文件上传信息
 */
export interface FileUploadInfo {
  file: File;
  type: string;
  size: number;
  name: string;
}


