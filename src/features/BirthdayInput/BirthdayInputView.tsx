// [INPUT] React hooks, react-router-dom的useNavigate, stores中的useOnboardingStore, components中的ArrowLeftIcon和UnifiedWheelPicker, constants中的DSStrings, 样式文件
// [OUTPUT] BirthdayInputView组件, 生日输入页面的UI和交互逻辑, 用户通过轮盘选择器选择年、月、日后保存到onboardingStore并跳转到出生时间信息页
// [POS] 特征层的生日输入页面组件, 负责用户生日输入界面渲染和状态管理, 是引导流程的第二步
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useOnboardingStore } from '../../stores/onboardingStore';
import { ArrowLeftIcon } from '../../components/icons/ArrowLeftIcon';
import { UnifiedWheelPicker } from '../../components/UnifiedWheelPicker';
import { DSStrings } from '../../constants/strings';
import styles from './BirthdayInputView.module.css';

export function BirthdayInputView() {
  const navigate = useNavigate();
  const { birthDate, setBirthDate } = useOnboardingStore();

  // 初始化日期（如果有存储的日期则使用，否则使用当前日期减20年作为默认值）
  const defaultDate = birthDate || new Date(new Date().getFullYear() - 20, 0, 1);
  const [year, setYear] = useState(defaultDate.getFullYear());
  const [month, setMonth] = useState(defaultDate.getMonth() + 1);
  const [day, setDay] = useState(defaultDate.getDate());

  // 生成年份列表（1900年到当前年份，倒序）
  const currentYear = new Date().getFullYear();
  const years = Array.from({ length: currentYear - 1899 }, (_, i) => currentYear - i);
  
  // 生成月份列表（1-12）
  const months = Array.from({ length: 12 }, (_, i) => i + 1);
  
  // 根据年月计算天数（考虑闰年）
  const getDaysInMonth = (y: number, m: number) => {
    return new Date(y, m, 0).getDate();
  };
  
  // 生成日期列表（根据选择的年月动态计算）
  const [days, setDays] = useState<number[]>(() => {
    const daysCount = getDaysInMonth(year, month);
    return Array.from({ length: daysCount }, (_, i) => i + 1);
  });

  // 当年或月改变时，更新日期列表，并确保选择的日期不超过新的最大值
  useEffect(() => {
    const maxDay = getDaysInMonth(year, month);
    const newDays = Array.from({ length: maxDay }, (_, i) => i + 1);
    setDays(newDays);
    
    if (day > maxDay) {
      setDay(maxDay);
    }
  }, [year, month]);

  const handleContinue = () => {
    const date = new Date(year, month - 1, day);
    setBirthDate(date);
    navigate('/onboarding/birth-time');
  };

  const handleBack = () => {
    navigate('/onboarding/name');
  };

  return (
    <div className={styles.container}>
      {/* 背景渐变 - Ellipse */}
      <div className={styles.backgroundEllipse} />
      {/* 背景渐变 - Polygon */}
      <div className={styles.backgroundPolygon} />

      {/* 返回按钮 */}
      <button
        className={styles.backButton}
        onClick={handleBack}
        aria-label="返回"
      >
        <ArrowLeftIcon className={styles.backIcon} color="black" width={24} height={24} />
      </button>

      {/* 标题 */}
      <div className={styles.titleContainer}>
        <h1 className={styles.title}>
          你的生日在<br />哪一天
        </h1>
      </div>

      {/* 轮盘选择器容器 */}
      <div className={styles.pickersContainer}>
        {/* 年选择器 */}
        <div className={styles.pickerWrapper} style={{ width: '136px' }}>
          <div className={styles.pickerContainer}>
            <UnifiedWheelPicker
              values={years}
              selectedValue={year}
              onChange={setYear}
              labelSuffix="年"
              infinite
            />
          </div>
        </div>

        {/* 月选择器 */}
        <div className={styles.pickerWrapper} style={{ width: '57px' }}>
          <div className={styles.pickerContainer}>
            <UnifiedWheelPicker
              values={months}
              selectedValue={month}
              onChange={setMonth}
              labelSuffix="月"
              infinite
            />
          </div>
        </div>

        {/* 日选择器 */}
        <div className={styles.pickerWrapper} style={{ width: '63px' }}>
          <div className={styles.pickerContainer}>
            <UnifiedWheelPicker
              values={days}
              selectedValue={day}
              onChange={setDay}
              labelSuffix="日"
              infinite
            />
          </div>
        </div>
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
  );
}
