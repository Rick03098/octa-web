// [INPUT] React, react-router-dom的useNavigate
// [OUTPUT] PermissionsView组件, 权限请求页面的UI和交互逻辑
// [POS] 特征层的权限请求页面组件, 负责相机/麦克风/位置权限请求界面渲染(旧版本, 待重建)
import React from 'react';
import { useNavigate } from 'react-router-dom';

export const PermissionsView: React.FC = () => {
  const navigate = useNavigate();

  const handleContinue = () => {
    navigate('/main');
  };

  return (
    <div className="relative w-full min-h-screen bg-[#fffcf9] flex flex-col">
      {/* 背景渐变 */}
      <div className="absolute inset-0 bg-gradient-to-b from-purple-100/50 via-blue-100/50 to-pink-100/50" />
      
      <div className="relative z-10 flex flex-col flex-1 px-6 pt-20 pb-8">
        {/* 返回按钮 */}
        <button
          onClick={() => navigate('/onboarding/bazi-result')}
          className="w-10 h-10 flex items-center justify-center rounded-full bg-white/15 mb-8 self-start"
        >
          <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
            <path d="M11 14L6 9L11 4" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>

        {/* 标题 */}
        <h1 className="text-[24px] font-semibold text-[#0a1931] mb-12 text-center">
          开启权限
        </h1>

        {/* 权限列表 */}
        <div className="flex-1 flex flex-col justify-center gap-4 mb-8">
          <div className="bg-[rgba(250,250,250,0.5)] rounded-[20px] p-6 flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-5 h-5 bg-gray-400 rounded" />
              <div>
                <h3 className="text-[16px] font-normal text-[#0a1931] mb-1">相机</h3>
                <p className="text-[14px] text-[#0a1931]/60">用于拍摄工位环境</p>
              </div>
            </div>
            <div className="w-[42px] h-[26px] bg-[rgba(255,195,195,0.3)] border border-white rounded-[30px] relative">
              <div className="absolute right-[3px] top-[3px] w-5 h-5 bg-white rounded-full shadow-sm" />
            </div>
          </div>

          <div className="bg-[rgba(250,250,250,0.5)] rounded-[20px] p-6 flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-5 h-5 bg-gray-400 rounded" />
              <div>
                <h3 className="text-[16px] font-normal text-[#0a1931] mb-1">麦克风</h3>
                <p className="text-[14px] text-[#0a1931]/60">用于语音相关功能</p>
              </div>
            </div>
            <div className="w-[42px] h-[26px] bg-[rgba(255,195,195,0.3)] border border-white rounded-[30px] relative">
              <div className="absolute right-[3px] top-[3px] w-5 h-5 bg-white rounded-full shadow-sm" />
            </div>
          </div>

          <div className="bg-[rgba(250,250,250,0.5)] rounded-[20px] p-6 flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-5 h-5 bg-gray-400 rounded" />
              <div>
                <h3 className="text-[16px] font-normal text-[#0a1931] mb-1">位置</h3>
                <p className="text-[14px] text-[#0a1931]/60">用于更精确的风水分析</p>
              </div>
            </div>
            <div className="w-[42px] h-[26px] bg-[rgba(0,0,0,0.1)] border border-white rounded-[40px] relative">
              <div className="absolute left-[3px] top-[3px] w-5 h-5 bg-white rounded-full shadow-sm" />
            </div>
          </div>
        </div>

        {/* 继续按钮 */}
        <button
          onClick={handleContinue}
          className="w-full h-[58px] bg-white rounded-[20px] text-black font-normal text-base"
        >
          继续
        </button>
      </div>
    </div>
  );
};
