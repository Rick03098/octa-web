// [INPUT] iOS版本的DSColors.swift中的渐变定义(作为参考)
// [OUTPUT] gradients常量对象, 包含所有页面的CSS渐变字符串
// [POS] 工具层的渐变定义文件, 提供页面背景渐变的CSS字符串(注意: 新代码应使用styles/gradients.ts中的函数)
// 对应 iOS 的 DSColors 渐变
// 注意: 此文件为旧版本, 新代码应使用 styles/gradients.ts 中的函数

export const gradients = {
  nameEntry: 'linear-gradient(180deg, #FFA1A1 0%, #FFDBCF 100%)',
  birthday: 'linear-gradient(180deg, #C2F0DC 0%, #FAD4E6 100%)',
  birthTime: 'radial-gradient(circle at center, #C7F0FF 0%, #FCF5ED 100%)',
  birthLocation: 'linear-gradient(180deg, #B09E94 0%, #FAEDE0 100%)',
  gender: 'linear-gradient(180deg, #DCD4D1 0%, #FDF7F2 100%)',
  permissions: 'linear-gradient(180deg, #FFF0F0 0%, #FFF8F5 100%)',
  mainEnvironment: 'linear-gradient(180deg, #FFF7F2 0%, #FFE0EB 0%, #FFF8F2 100%)',
  selfCenter: 'linear-gradient(180deg, #FCF0E6 0%, #F7EDF5 0%, #F0EBFA 100%)',
  report: 'linear-gradient(180deg, #E6F5FF 0%, #F7F7F0 100%)',
  orientation: 'linear-gradient(180deg, #DBECFF 0%, #FAF7F0 100%)',
};

