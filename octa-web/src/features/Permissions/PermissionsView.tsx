// [INPUT] react-router-dom的useNavigate, React hooks(useState), constants中的DSStrings, 样式文件, permissions工具函数
// [OUTPUT] PermissionsView组件, 权限申请页面的UI和交互逻辑, 触发系统权限弹窗, 导航至主界面空状态(/main-empty)
// [POS] 特征层的权限申请页面组件, 连接八字结果页面和主界面空状态, 统一请求相机/麦克风/位置权限
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { DSStrings } from '../../constants/strings';
import {
  requestCameraPermission,
  requestMicrophonePermission,
  requestLocationPermission,
  type PermissionStatus,
} from '../../utils/permissions';
import styles from './PermissionsView.module.css';

// 权限项类型
interface PermissionItem {
  id: 'camera' | 'microphone' | 'location';
  name: string;
  description: string;
  icon: React.ReactNode;
  required: boolean;
}

// 权限状态类型
type ToggleState = 'off' | 'on' | 'loading';

export function PermissionsView() {
  const navigate = useNavigate();
  
  // 权限状态管理
  const [permissionStates, setPermissionStates] = useState<Record<string, ToggleState>>({
    camera: 'off',
    microphone: 'off',
    location: 'off',
  });

  // 权限列表配置
  const permissions: PermissionItem[] = [
    {
      id: 'camera',
      name: DSStrings.Permissions.camera,
      description: '用于拍摄工位环境',
      icon: <CameraIcon />,
      required: true, // 相机是必须的
    },
    {
      id: 'microphone',
      name: DSStrings.Permissions.microphone,
      description: '用于语音相关功能',
      icon: <MicrophoneIcon />,
      required: false,
    },
    {
      id: 'location',
      name: DSStrings.Permissions.location,
      description: '用于更精确的风水分析',
      icon: <LocationIcon />,
      required: false,
    },
  ];

  // 处理权限开关点击
  const handleToggle = async (permissionId: 'camera' | 'microphone' | 'location') => {
    const currentState = permissionStates[permissionId];
    
    // 如果已经开启，不允许关闭（权限一旦授予无法撤销）
    if (currentState === 'on') {
      return;
    }
    
    // 如果正在加载，不响应
    if (currentState === 'loading') {
      return;
    }

    // 设置为加载状态
    setPermissionStates(prev => ({ ...prev, [permissionId]: 'loading' }));

    let result: PermissionStatus;
    
    // 根据权限类型调用对应的请求函数
    switch (permissionId) {
      case 'camera':
        result = await requestCameraPermission();
        break;
      case 'microphone':
        result = await requestMicrophonePermission();
        break;
      case 'location':
        result = await requestLocationPermission();
        break;
    }

    // 更新状态
    setPermissionStates(prev => ({
      ...prev,
      [permissionId]: result === 'granted' ? 'on' : 'off',
    }));
  };

  // 返回上一页
  const handleBack = () => {
    navigate('/onboarding/bazi-result');
  };

  // 继续到主界面（空状态，第一次进入需要添加环境）
  const handleContinue = () => {
    navigate('/main-empty');
  };

  // 检查是否可以继续（相机权限必须开启）
  const canContinue = permissionStates.camera === 'on';

  return (
    <div className={styles.container}>
      {/* 背景渐变 */}
      <div className={styles.backgroundGradient} />

      {/* 返回按钮 */}
      <button className={styles.backButton} onClick={handleBack} aria-label="返回">
        <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
          <path
            d="M11 14L6 9L11 4"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </button>

      {/* 内容区域 */}
      <div className={styles.content}>
        {/* 标题 */}
        <h1 className={styles.title}>{DSStrings.Permissions.title}</h1>

        {/* 权限列表 */}
        <div className={styles.permissionsList}>
          {permissions.map((permission) => (
            <div key={permission.id} className={styles.permissionCard}>
              <div className={styles.permissionInfo}>
                <div className={styles.permissionIcon}>{permission.icon}</div>
                <div className={styles.permissionText}>
                  <span className={styles.permissionName}>{permission.name}</span>
                  <span className={styles.permissionDescription}>
                    {permission.description}
                  </span>
                </div>
              </div>
              <div
                className={styles.toggle}
                data-state={permissionStates[permission.id]}
                onClick={() => handleToggle(permission.id)}
                role="switch"
                aria-checked={permissionStates[permission.id] === 'on'}
                aria-label={`${permission.name}权限开关`}
                tabIndex={0}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    handleToggle(permission.id);
                  }
                }}
              >
                <div className={styles.toggleKnob} />
              </div>
            </div>
          ))}
        </div>

        {/* 提示文字 */}
        {!canContinue && (
          <p className={styles.hint}>请开启相机权限以继续</p>
        )}

        {/* 继续按钮 */}
        <button
          className={styles.continueButton}
          onClick={handleContinue}
          disabled={!canContinue}
        >
          {DSStrings.Common.actionContinue}
        </button>
      </div>
    </div>
  );
}

// 相机图标组件
function CameraIcon() {
  return (
    <img
      src="/icons/permissions-camera.svg"
      alt="相机"
      width={20}
      height={20}
      aria-hidden="true"
    />
  );
}

// 麦克风图标组件
function MicrophoneIcon() {
  return (
    <img
      src="/icons/permissions-mic.svg"
      alt="麦克风"
      width={20}
      height={20}
      aria-hidden="true"
    />
  );
}

// 位置图标组件
function LocationIcon() {
  return (
    <img
      src="/icons/permissions-location.svg"
      alt="位置"
      width={20}
      height={20}
      aria-hidden="true"
    />
  );
}

export default PermissionsView;
