// [INPUT] react-router-dom的useNavigate和useLocation hooks, DSStrings常量, 样式文件, ArrowLeftIcon/PlusIcon/ArrowUpIcon图标组件, /icons/icons.svg图标文件
// [OUTPUT] ChatView组件, 对话页面的完整UI和交互逻辑, 导航返回主界面操作, 消息发送功能(待实现)
// [POS] 特征层的对话组件, 从主界面进入, 展示对话历史和AI交互功能
import { useState, useEffect, useRef } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { DSStrings } from '../../constants/strings';
import { ArrowLeftIcon } from '../../components/icons/ArrowLeftIcon';
import { PlusIcon } from '../../components/icons/PlusIcon';
import { ArrowUpIcon } from '../../components/icons/ArrowUpIcon';
import styles from './ChatView.module.css';

interface Message {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: Date;
}

export function ChatView() {
  const navigate = useNavigate();
  const location = useLocation();
  const [messages, setMessages] = useState<Message[]>([]);
  const [inputValue, setInputValue] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const messagesContainerRef = useRef<HTMLDivElement>(null);
  const [showTopShadow, setShowTopShadow] = useState(false);
  const hasProcessedInitialMessage = useRef(false); // 防止重复处理初始消息

  // 从路由状态获取初始消息，如果是自动发送则直接发送
  useEffect(() => {
    // 如果已经处理过初始消息，不再处理
    if (hasProcessedInitialMessage.current) return;

    const initialMessage = location.state?.initialMessage as string | undefined;
    const autoSend = location.state?.autoSend as boolean | undefined;
    
    if (initialMessage) {
      // 标记为已处理
      hasProcessedInitialMessage.current = true;

      if (autoSend) {
        // 自动发送消息
        const userMessage: Message = {
          id: Date.now().toString(),
          role: 'user',
          content: initialMessage,
          timestamp: new Date(),
        };

        setMessages((prev) => [...prev, userMessage]);
        setIsLoading(true);

        // TODO: 调用 API 获取 AI 回复
        // 模拟 AI 回复
        setTimeout(() => {
          const aiMessage: Message = {
            id: (Date.now() + 1).toString(),
            role: 'assistant',
            content: '桌面上物品繁多，缺乏规整和随意摆放，让在无形之中对你的专注力产生干扰，让人在工作时容易产生烦躁情绪。\n\n你，是 "癸水" 的化身——如同滋润万物的晨雾，细腻、敏锐，充满灵性与不拘一格的创造力。你的天性是流动、渗透和滋养，是那种能在头脑风暴中，提出让所有人"哇"一声的那个点子的人。\n\n于是，一场无声的拉锯战在你内心深处上演： 那如水雾般轻盈的你，渴望自由地探索、试错、创造；而那如大地般厚重的能量，则要求你稳定、尽责、提交完美的文档、遵守严格的流程。\n\n这不是"好"与"坏"的对抗，而是一种深刻的内在张力。 它让你时常感到，自己满腔的才华与灵感，仿佛被一种无形的压力所抑制，难以淋漓尽致地舒展。你不是没有力量，而是你的力量，正被过于沉重的土壤所束缚。',
            timestamp: new Date(),
          };
          setMessages((prev) => [...prev, aiMessage]);
          setIsLoading(false);
        }, 1500);
      } else {
        // 只填充输入框，不自动发送
        setInputValue(initialMessage);
      }
    }
  }, [location.state]);

  // 滚动到底部
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  // 监听滚动事件，动态显示/隐藏顶部阴影
  useEffect(() => {
    const container = messagesContainerRef.current;
    if (!container) return;

    const handleScroll = () => {
      const scrollTop = container.scrollTop;
      // 当滚动位置 > 0 时显示顶部阴影
      setShowTopShadow(scrollTop > 0);
    };

    container.addEventListener('scroll', handleScroll);
    // 初始检查
    handleScroll();
    
    return () => {
      container.removeEventListener('scroll', handleScroll);
    };
  }, []);

  // 处理返回按钮点击 - 返回到主界面
  const handleBack = () => {
    navigate('/main');
  };

  // 处理输入提交
  const handleSubmit = async () => {
    if (!inputValue.trim() || isLoading) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: inputValue.trim(),
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setInputValue('');
    setIsLoading(true);

    // TODO: 调用 API 获取 AI 回复
    // 模拟 AI 回复
    setTimeout(() => {
      const aiMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: '桌面上物品繁多，缺乏规整和随意摆放，让在无形之中对你的专注力产生干扰，让人在工作时容易产生烦躁情绪。\n\n你，是 "癸水" 的化身——如同滋润万物的晨雾，细腻、敏锐，充满灵性与不拘一格的创造力。你的天性是流动、渗透和滋养，是那种能在头脑风暴中，提出让所有人"哇"一声的那个点子的人。\n\n于是，一场无声的拉锯战在你内心深处上演： 那如水雾般轻盈的你，渴望自由地探索、试错、创造；而那如大地般厚重的能量，则要求你稳定、尽责、提交完美的文档、遵守严格的流程。\n\n这不是"好"与"坏"的对抗，而是一种深刻的内在张力。 它让你时常感到，自己满腔的才华与灵感，仿佛被一种无形的压力所抑制，难以淋漓尽致地舒展。你不是没有力量，而是你的力量，正被过于沉重的土壤所束缚。',
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, aiMessage]);
      setIsLoading(false);
    }, 1500);
  };

  // 处理输入框回车
  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      handleSubmit();
    }
  };

  return (
    <div className={styles.container}>
      {/* 背景图片 */}
      <img
        src="/images/蓝绿浅.gif"
        alt="背景"
        className={styles.backgroundImage}
        onError={(e) => {
          // 容错处理：如果图片加载失败，显示背景色
          const target = e.target as HTMLImageElement;
          target.style.display = 'none';
        }}
      />

      {/* 返回按钮 - Figma: left=20px, top=49px */}
      <button
        className={styles.backButton}
        onClick={handleBack}
        aria-label={DSStrings.Common.back}
      >
        <ArrowLeftIcon width={24} height={24} color="white" />
      </button>

      {/* 顶部渐变阴影（ScrollShadow效果） */}
      {showTopShadow && (
        <div className={styles.topShadow} />
      )}

      {/* 对话内容区域 */}
      <div 
        ref={messagesContainerRef}
        className={styles.messagesContainer}
      >
        {messages.map((message) => (
          <div
            key={message.id}
            className={
              message.role === 'user'
                ? styles.userMessageContainer
                : styles.assistantMessageContainer
            }
          >
            {message.role === 'assistant' && (
              <div className={styles.messageContent}>
                {message.content.split('\n\n').map((paragraph, paragraphIndex) => {
                  // 计算之前段落的总字符数（用于延迟计算）
                  const previousChars = message.content
                    .split('\n\n')
                    .slice(0, paragraphIndex)
                    .join('')
                    .length;
                  
                  return (
                    <p key={paragraphIndex} className={styles.assistantMessage}>
                      {paragraph.split('').map((char, charIndex) => {
                        // 全局字符索引（从文档开始计算）
                        const globalCharIndex = previousChars + charIndex;
                        return (
                          <span
                            key={charIndex}
                            className={styles.assistantMessageChar}
                            style={{
                              animationDelay: `${globalCharIndex * 0.03}s`,
                            }}
                          >
                            {char === ' ' ? '\u00A0' : char}
                          </span>
                        );
                      })}
                    </p>
                  );
                })}
              </div>
            )}
            {message.role === 'user' && (
              <div className={styles.userMessageBubble}>
                <p className={styles.userMessage}>{message.content}</p>
              </div>
            )}
          </div>
        ))}

        {/* AI 加载动画 - 三个跳动的小球 */}
        {isLoading && (
          <div className={styles.loader}>
            <div className={styles.ball}></div>
            <div className={styles.ball}></div>
            <div className={styles.ball}></div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      {/* 底部输入区域 - 参考新的设计 */}
      <div className={styles.inputContainer}>
        {/* 添加按钮 - 左侧圆形按钮 */}
        <button className={styles.addButton} aria-label="添加">
          <PlusIcon width={19.2} height={19.2} color="rgba(113, 96, 101, 1)" />
        </button>

        <div 
          className={styles.composerRoot}
          data-empty={!inputValue}
          data-running={isLoading}
        >
          <div className={styles.composerInner}>
            <input
              type="text"
              className={styles.input}
              placeholder={DSStrings.ChatIntro.placeholder}
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              onKeyDown={handleKeyDown}
              disabled={isLoading}
            />
            {/* 发送按钮 - 始终显示白色背景，无输入时禁用 */}
            <button 
              className={`${styles.sendButton} ${inputValue ? styles.sendButtonActive : ''}`}
              aria-label="发送"
              onClick={handleSubmit}
              disabled={!inputValue || isLoading}
            >
              <ArrowUpIcon width={12} height={12} color="rgba(80, 80, 80, 1)" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

