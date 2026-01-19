// [INPUT] api/client中的apiClient, types中的八字相关类型(CreateBaziProfileRequest, BaziProfileResponse等)
// [OUTPUT] 八字档案相关的API函数(create, list, get等), 返回类型化的响应
// [POS] API层的八字档案模块, 封装所有八字档案相关的API调用
import { api } from './client';
import type {
  CreateBaziProfileRequest,
  BaziProfileCreateResponse,
  BaziProfileGetResponse,
  BaziProfileListResponse,
  BaziProfileResponse,
  BaziFourSentencesResponse,
} from '../types';

export const profilesApi = {
  /**
   * 创建八字档案
   */
  create: async (data: CreateBaziProfileRequest): Promise<BaziProfileCreateResponse> => {
    return api.post('/v1/profiles/bazi', data);
  },

  /**
   * 获取八字档案列表
   */
  list: async (): Promise<BaziProfileListResponse> => {
    return api.get('/v1/profiles/bazi');
  },

  /**
   * 获取单个八字档案详情
   */
  get: async (profileId: string): Promise<BaziProfileGetResponse> => {
    return api.get(`/v1/profiles/bazi/${profileId}`);
  },

  /**
   * 更新八字档案
   */
  update: async (
    profileId: string,
    data: { name?: string; is_active?: boolean }
  ): Promise<BaziProfileResponse> => {
    return api.patch(`/v1/profiles/bazi/${profileId}`, data);
  },

  /**
   * 删除八字档案
   */
  delete: async (profileId: string): Promise<{ success: boolean; message: string }> => {
    return api.delete(`/v1/profiles/bazi/${profileId}`);
  },

  /**
   * 激活八字档案（切换使用的档案）
   */
  activate: async (profileId: string): Promise<BaziProfileResponse> => {
    return api.post(`/v1/profiles/bazi/${profileId}:activate`);
  },

  /**
   * 获取八字四句话
   */
  getFourSentences: async (profileId: string): Promise<BaziFourSentencesResponse> => {
    return api.get(`/v1/profiles/bazi/${profileId}/four-sentences`);
  },
};

