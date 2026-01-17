// [INPUT] React hooks(useState), react-router-dom的useNavigate, stores中的useOnboardingStore, components中的ArrowLeftIcon/UnifiedWheelPicker, constants中的DSStrings, types中的DayPeriod, 样式文件
// [OUTPUT] BirthTimeInputView组件, 出生时间输入页面的UI和交互逻辑, 用户通过轮盘选择器选择时、分、时段后保存到onboardingStore并跳转到出生地信息页
// [POS] 特征层的出生时间输入页面组件, 负责用户出生时间输入界面渲染和状态管理, 是引导流程的第三步
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useOnboardingStore } from '../../stores/onboardingStore';
import { ArrowLeftIcon } from '../../components/icons/ArrowLeftIcon';
import { UnifiedWheelPicker } from '../../components/UnifiedWheelPicker';
import { DSStrings } from '../../constants/strings';
import { DayPeriod } from '../../types/models';
import styles from './BirthTimeInputView.module.css';

export function BirthTimeInputView() {
  const navigate = useNavigate();
  const { birthTime, setBirthTime } = useOnboardingStore();

  // 初始化时间（如果有存储的时间则使用，否则使用默认值：12点0分上午）
  const defaultTime = birthTime || { hour: 12, minute: 0, period: DayPeriod.AM };
  const [hour, setHour] = useState(defaultTime.hour);
  const [minute, setMinute] = useState(defaultTime.minute);
  const [period, setPeriod] = useState<DayPeriod>(defaultTime.period);

  // 生成小时列表（1-12）
  const hours = Array.from({ length: 12 }, (_, i) => i + 1);
  
  // 生成分钟列表（0-59）
  const minutes = Array.from({ length: 60 }, (_, i) => i);
  
  // 时段列表
  const periods = [DayPeriod.AM, DayPeriod.PM];

  const handleContinue = () => {
    setBirthTime({ hour, minute, period });
    navigate('/onboarding/birth-location');
  };

  const handleBack = () => {
    navigate('/onboarding/birthday');
  };

  return (
    <div className={styles.container}>
      {/* 背景渐变 - Eclipse */}
      <div className={styles.backgroundEclipse} />
      {/* 背景渐变 - 蓝色径向渐变 */}
      <div className={styles.backgroundBlueGradient} />

      {/* 返回按钮 */}
      <button
        className={styles.backButton}
        onClick={handleBack}
        aria-label={DSStrings.Common.back}
      >
        <ArrowLeftIcon className={styles.backIcon} color="black" width={24} height={24} />
      </button>

      {/* 标题 */}
      <div className={styles.titleContainer}>
        <h1 className={styles.title}>
          {DSStrings.BirthTime.title}
        </h1>
      </div>

      {/* 轮盘选择器容器 */}
      <div className={styles.pickersContainer}>
        {/* 时选择器 */}
        <div className={`${styles.pickerWrapper} ${styles.pickerWrapperHour}`}>
          <div className={styles.pickerContainer}>
            <UnifiedWheelPicker
              values={hours}
              selectedValue={hour}
              onChange={setHour}
              labelSuffix="点"
              infinite
            />
          </div>
        </div>

        {/* 分选择器 */}
        <div className={`${styles.pickerWrapper} ${styles.pickerWrapperMinute}`}>
          <div className={styles.pickerContainer}>
            <UnifiedWheelPicker
              values={minutes}
              selectedValue={minute}
              onChange={setMinute}
              labelSuffix="分"
              infinite
            />
          </div>
        </div>

        {/* 时段选择器（只有上午和下午两个选项，不启用循环） */}
        <div className={styles.pickerWrapper}>
          <div className={styles.pickerContainer}>
            <UnifiedWheelPicker
              values={periods}
              selectedValue={period}
              onChange={(value) => setPeriod(value as DayPeriod)}
              infinite={false}
            />
          </div>
        </div>
      </div>

      {/* 底部区域（使用Auto Layout） */}
      <div className={styles.bottomSection}>
        {/* 提示文字 */}
        <div className={styles.hintText}>
          {DSStrings.BirthTime.hint}
        </div>

        {/* 继续按钮 */}
        <button
          className={styles.continueButton}
          onClick={handleContinue}
          aria-label={DSStrings.Common.actionContinue}
        >
          {DSStrings.Common.actionContinue}
        </button>
      </div>
    </div>
  );
}
