// [INPUT] 本目录下的所有API模块(auth.ts, profiles.ts, analysis.ts, users.ts, client.ts)
// [OUTPUT] 统一导出的API函数, 供其他模块使用
// [POS] API层的入口文件, 统一导出所有API模块, 简化导入路径
export { default as apiClient, api } from './client';
export { authApi } from './auth';
export { profilesApi } from './profiles';
export { analysisApi } from './analysis';
export { usersApi } from './users';

