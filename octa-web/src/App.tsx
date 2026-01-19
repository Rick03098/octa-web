// [INPUT] react-router-dom的路由组件(BrowserRouter, Routes, Route), 各Feature页面的View组件
// [OUTPUT] App根组件, 配置了应用的所有路由规则, 控制页面导航
// [POS] 应用层的路由控制器, 定义所有页面路径和组件映射, 是应用导航的入口点
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import AppShell from './components/AppShell';
import { LoginView } from './features/Login/LoginView';
import { NameEntryView } from './features/NameEntry/NameEntryView';
import { BirthdayInputView } from './features/BirthdayInput/BirthdayInputView';
import { BirthTimeInputView } from './features/BirthTimeInput/BirthTimeInputView';
import { BirthLocationInputView } from './features/BirthLocationInput/BirthLocationInputView';
import { GenderSelectionView } from './features/GenderSelection/GenderSelectionView';
import { BaziResultView } from './features/BaziResult/BaziResultView';
import { PermissionsView } from './features/Permissions/PermissionsView';
import { MainDashboardView } from './features/MainDashboard/MainDashboardView';
import { MainDashboardEmptyView } from './features/MainDashboardEmpty/MainDashboardEmptyView';
import { TutorialView } from './features/Tutorial/TutorialView';
import { CaptureView } from './features/Capture/CaptureView';
import { CaptureCompleteView } from './features/CaptureComplete/CaptureCompleteView';
import { OrientationCaptureView } from './features/OrientationCapture/OrientationCaptureView';
import { LoadingView } from './features/Loading/LoadingView';
import { PreviewView } from './features/Preview/PreviewView';
import { ReportView } from './features/Report/ReportView';
import { ChatIntroView } from './features/ChatIntro/ChatIntroView';
import { ChatView } from './features/Chat/ChatView';

function App() {
  return (
    <AppShell>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Navigate to="/login" replace />} />
          <Route path="/login" element={<LoginView />} />
          <Route path="/onboarding/name" element={<NameEntryView />} />
          <Route path="/onboarding/birthday" element={<BirthdayInputView />} />
          <Route path="/onboarding/birth-time" element={<BirthTimeInputView />} />
          <Route path="/onboarding/birth-location" element={<BirthLocationInputView />} />
          <Route path="/onboarding/gender" element={<GenderSelectionView />} />
          <Route path="/onboarding/bazi-result" element={<BaziResultView />} />
          <Route path="/permissions" element={<PermissionsView />} />
          <Route path="/main-empty" element={<MainDashboardEmptyView />} />
          <Route path="/main" element={<MainDashboardView />} />
          <Route path="/tutorial" element={<TutorialView />} />
          <Route path="/capture" element={<CaptureView />} />
          <Route path="/capture-complete" element={<CaptureCompleteView />} />
          <Route path="/orientation" element={<OrientationCaptureView />} />
          <Route path="/loading" element={<LoadingView />} />
          <Route path="/preview" element={<PreviewView />} />
          <Route path="/report" element={<ReportView />} />
          <Route path="/chat-intro" element={<ChatIntroView />} />
          <Route path="/chat" element={<ChatView />} />
          {/* 其他路由将在后续实现中逐步添加 */}
        </Routes>
      </BrowserRouter>
    </AppShell>
  );
}

export default App;
