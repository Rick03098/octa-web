// [INPUT] zustand的create函数
// [OUTPUT] useCaptureStore hook, 提供拍摄图片的状态管理(图片数据存储、清除等)
// [POS] 状态管理层的拍摄Store, 管理拍摄的图片数据, 连接CaptureView和后续上传逻辑

import { create } from 'zustand';

/**
 * 拍摄状态接口
 */
interface CaptureState {
  /** Base64 格式的图片数据（用于预览） */
  capturedImage: string | null;
  /** 原始 Blob 数据（用于上传） */
  imageBlob: Blob | null;
  /** 图片 MIME 类型 */
  imageMimeType: string | null;
  /** 拍摄时间戳 */
  capturedAt: number | null;
}

/**
 * 拍摄操作接口
 */
interface CaptureActions {
  /** 保存拍摄的图片 */
  setCapturedImage: (base64: string, blob: Blob, mimeType?: string) => void;
  /** 清除拍摄数据 */
  clearCapture: () => void;
  /** 检查是否有已拍摄的图片 */
  hasCapture: () => boolean;
}

/**
 * 完整的 Store 类型
 */
type CaptureStore = CaptureState & CaptureActions;

/**
 * 初始状态
 */
const initialState: CaptureState = {
  capturedImage: null,
  imageBlob: null,
  imageMimeType: null,
  capturedAt: null,
};

/**
 * 拍摄状态管理 Store
 * 
 * 用途：
 * 1. 存储用户拍摄的工位照片
 * 2. 在拍摄完成后保留数据供后续页面使用
 * 3. 最终用于上传到服务器进行风水分析
 */
export const useCaptureStore = create<CaptureStore>((set, get) => ({
  ...initialState,

  /**
   * 保存拍摄的图片
   * @param base64 Base64 格式的图片数据
   * @param blob 原始 Blob 数据
   * @param mimeType 图片 MIME 类型，默认 'image/jpeg'
   */
  setCapturedImage: (base64, blob, mimeType = 'image/jpeg') => {
    set({
      capturedImage: base64,
      imageBlob: blob,
      imageMimeType: mimeType,
      capturedAt: Date.now(),
    });
  },

  /**
   * 清除所有拍摄数据
   */
  clearCapture: () => {
    set(initialState);
  },

  /**
   * 检查是否有已拍摄的图片
   */
  hasCapture: () => {
    const state = get();
    return state.capturedImage !== null && state.imageBlob !== null;
  },
}));

export default useCaptureStore;
