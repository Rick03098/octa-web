# open format for guiding coding agents (OCTA)
# 用中文回答我问你的问题（为了方便理解问题的根源，你自己隐式的思考过程还是可以英文）！在Codex-CLI中
# When you draw the frontend page, 前端使用SwiftUI（必要的情况下使用一部分UIKit），search it in 产品文档 first, if there is not, notify me! 如果你做前端接的是Figma MCP，然后是Download图片素材模式，图片可以放到frontend下面放图片的Asset部分
# our system (mobile App frontend part) should satisfy iOS>=15.0, and applying newer technique while protecting the older version.
# For liquid glass (new feature of Apple 2025), always set a fallback to pervent the problem
# frontend的整体架构是MVC架构
# frontend的注释用简体中文
# 所有包含 ObservableObject 或 @Published/@ObservedObject 的 Swift 文件，必须在顶部显式 import Combine，不要仅依赖 import SwiftUI

# 产品文档（2025-11-09）
OCTA是一款AI+风水产品，尽管在11-09的内测版本中它还是纯中文版本，但是实际上需要进行多语言的提前设置（字符串的放置位置），页面设计和逻辑上，它的主要页面按顺序包括（与Figma引入一一对应，每一页我给你的Figma都能找到因由，在backend-v1中也能找到对应的API，然后里面会有一些并列的，你应该可以理解）：
1. 登陆页（用户选择Google或者邮箱注册或者邮箱登陆）（为了防止用户在已登陆的情况下重复登陆，在前端有isAuthenticated字段，如果该字段验证的话，直接到主界面部分；登陆的背景视频的素材是.json文件的Lottie素材，具体在本版本中是login-background-video.json
2. 名字信息（用户输入昵称，对应create_bazi_profile的一部分）：用户输入name，这个要上传到firestore
3. 生日信息（用户输入生日信息）：这里的生日需要用滚轮（类似苹果的DataPicker），生日信息页的年月日选择，必须使用滚轮自身的显示效果；禁止在滚轮上方再放额外的芯片/文本同步显示，并确保滚轮位置与 Figma 素材像素级对齐
4. 出生时间信息（用户输入出生时间），同样禁止在滚轮上方再放额外的芯片/文本同步显示
5. 出生地信息
6. 生理性别信息
7. 八字结果生成（后端调用对应的four_mapping的api）：生成八字对应的四句话，八字结果界面，可以右滑，下面有小圆点表示翻到哪一页）
8. 八字结果生成第四页：八字结果到最后一页的时候，四个圆点1.5s渐变消失，变成继续的按钮
9. 开启权限：应用向用户请求相机/麦克风/位置权限，相机打开之后才可以继续，其他暂时权限没有打开没关系（Simulator除了模拟器外没有真机）
10. 主界面-添加环境（下方的环境部分）：点击进入拍照环节，用户进入拍照阶段
11. 主界面-用户设置（下方的自我部分）：一些个人信息、语言等等（但在11-09测试版本中都可以不用有跳转点开）
12. 拍摄教程（用户添加环境后跳转）：教用户怎么拍，用户点继续进行到真正的拍摄页面
13. 拍摄页面（用户真正开始拍摄）：这一页就是拍摄画面
14. 拍摄结束的感谢界面（拍摄之后，准备获取方向）：这一页用于感谢完成了拍摄，顺到之后的方向获取问题；如果使用的是.mp4/.mov作为背景的话，要注意在各种手机型号上的显示问题，不能出现黑边和白边
14. orientation获得页面：用于获得用户这个时候工位的朝向（手机放平的方向），如果3s的角度不变就记录这个orientation的方向，如果一直没有静止，循环播放背景的.mov文件
15. 工位风水加载界面（暂缺）：用于解决大模型的API等待
16. report preview：在大模型API信息回来之后，先模糊给用户一个界面，让他打开之后的东西
17. report阅读：返回大模型API生成的报告，阅读到底可以和他对话
18. chatbot对话开启：用户没有对话历史的时候，开启用户对话的界面
19. chatbot实际对话：类似chatgpt（或者其他ai问答）的提问-回答流
