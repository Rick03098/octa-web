// [INPUT] React的StrictMode和createRoot, App根组件, styles/index.css全局样式
// [OUTPUT] 渲染到DOM的React应用, 启动整个前端应用
// [POS] 应用的入口文件, 负责初始化React应用并挂载到DOM, 是整个应用的生命周期起点
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';
import './styles/index.css';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>
);
