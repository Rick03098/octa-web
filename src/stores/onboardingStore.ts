// [INPUT] zustand的create函数, types/models中的类型定义(UserOnboardingFlowState, BirthTimeValue, UserGender)
// [OUTPUT] useOnboardingStore hook, 提供用户引导流程的状态管理和操作方法(setName, setBirthDate等)
// [POS] 状态管理层的核心Store, 管理用户输入数据, 连接UI组件和API调用
import { create } from 'zustand';
import type { UserOnboardingFlowState, BirthTimeValue, UserGender } from '../types/models';

interface OnboardingStore extends UserOnboardingFlowState {
  // Actions
  setName: (name: string) => void;
  setBirthDate: (date: Date | null) => void;
  setBirthTime: (time: BirthTimeValue | null) => void;
  setBirthLocation: (location: string) => void;
  setGender: (gender: UserGender | null) => void;
  setOrientationDegrees: (degrees: number | null) => void;
  reset: () => void;
  
  // Computed values
  birthTimeString24: () => string | null;
}

const initialState: UserOnboardingFlowState = {
  name: '',
  birthDate: null,
  birthTime: null,
  birthLocation: '',
  gender: null,
  orientationDegrees: null,
};

export const useOnboardingStore = create<OnboardingStore>((set, get) => ({
  ...initialState,

  setName: (name) => set({ name }),
  
  setBirthDate: (date) => set({ birthDate: date }),
  
  setBirthTime: (time) => set({ birthTime: time }),
  
  setBirthLocation: (location) => set({ birthLocation: location }),
  
  setGender: (gender) => set({ gender }),
  
  setOrientationDegrees: (degrees) => set({ orientationDegrees: degrees }),
  
  reset: () => set(initialState),
  
  birthTimeString24: () => {
    const time = get().birthTime;
    if (!time) return null;
    
    const hour24 = time.period === '上午'
      ? (time.hour === 12 ? 0 : time.hour)
      : (time.hour === 12 ? 12 : time.hour + 12);
    
    return `${hour24.toString().padStart(2, '0')}:${time.minute.toString().padStart(2, '0')}`;
  },
}));
