// [INPUT] api/client中的apiClient, types中的分析相关类型(CreateAnalysisJobRequest, AnalysisResult等)
// [OUTPUT] 风水分析相关的API函数(createJob, getJob, getResult等), 返回类型化的响应
// [POS] API层的分析模块, 封装所有风水分析相关的API调用
import { api } from './client';
import type {
  CreateAnalysisJobRequest,
  AnalysisJobCreateResponse,
  AnalysisJobGetResponse,
  AnalysisResultGetResponse,
} from '../types';

export const analysisApi = {
  /**
   * 创建分析任务
   */
  createJob: async (data: CreateAnalysisJobRequest): Promise<AnalysisJobCreateResponse> => {
    return api.post('/v1/analysis/jobs', data);
  },

  /**
   * 获取分析任务状态
   */
  getJob: async (jobId: string): Promise<AnalysisJobGetResponse> => {
    return api.get(`/v1/analysis/jobs/${jobId}`);
  },

  /**
   * 获取分析结果
   */
  getResult: async (resultId: string): Promise<AnalysisResultGetResponse> => {
    return api.get(`/v1/analysis/results/${resultId}`);
  },
};

