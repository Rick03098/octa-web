// [INPUT] 图片文件名或路径, 当前窗口的location对象
// [OUTPUT] 可访问的图片URL, 自动处理本地开发和移动端访问
// [POS] 工具层的图片路径处理函数, 解决localhost在移动端不可访问的问题

/**
 * 获取图片 URL，自动处理本地开发和移动端访问
 * @param imagePath Figma MCP 服务器的图片路径（如 '/assets/xxx.png'）
 * @returns 可访问的图片 URL
 */
export function getImageUrl(imagePath: string): string {
  // 如果已经是完整 URL，直接返回
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    // 替换 localhost 为当前主机 IP（移动端访问）
    if (imagePath.includes('localhost') || imagePath.includes('127.0.0.1')) {
      // 获取当前页面的主机信息
      const currentHost = window.location.hostname;
      const currentPort = window.location.port || '5173';
      
      // 如果当前访问是通过 IP，则替换 localhost
      if (currentHost !== 'localhost' && currentHost !== '127.0.0.1') {
        // 提取端口号（如果是 localhost:3845，提取 3845）
        const urlMatch = imagePath.match(/localhost:(\d+)/);
        const targetPort = urlMatch ? urlMatch[1] : '3845';
        
        // 替换为当前主机的 IP
        return imagePath.replace(/localhost:\d+/, `${currentHost}:${targetPort}`);
      }
    }
    return imagePath;
  }
  
  // 如果是相对路径，直接返回（假设图片在 public 目录）
  return imagePath.startsWith('/') ? imagePath : `/${imagePath}`;
}

/**
 * 从完整的 localhost URL 中提取路径并转换为可访问的 URL
 * @param localhostUrl 完整的 localhost URL（如 'http://localhost:3845/assets/xxx.png'）
 * @returns 可访问的图片 URL
 */
export function convertLocalhostUrl(localhostUrl: string): string {
  // 如果当前是通过 IP 访问（移动端），替换 localhost
  const currentHost = window.location.hostname;
  
  if (currentHost !== 'localhost' && currentHost !== '127.0.0.1') {
    // 提取端口号
    const urlMatch = localhostUrl.match(/localhost:(\d+)/);
    const targetPort = urlMatch ? urlMatch[1] : '3845';
    
    // 替换为当前主机的 IP
    return localhostUrl.replace(/localhost:\d+/, `${currentHost}:${targetPort}`);
  }
  
  // 如果是本地访问，保持原样
  return localhostUrl;
}


