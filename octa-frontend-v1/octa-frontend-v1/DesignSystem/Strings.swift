//
//  Strings.swift
//  octa-frontend-v1
//
//  Created by Codex on 2025/11/09.
//

import Foundation

enum DSStrings {
    enum Common {
        static let actionContinue = "继续"
        static let back = "返回"
    }

    enum Login {
        static let createAccount = "创建账户"
        static let loginGoogle = "谷歌登录"
        static let memberLogin = "已有账户？会员登录"
    }

    enum NameEntry {
        static let title = "请问该\n如何称呼你?"
    }

    enum Birthday {
        static let title = "你的生日在\n哪一天"
    }

    enum BirthTime {
        static let title = "你的出生时间"
        static let hint = "不确定可以选择中午十二点"
    }

    enum BirthLocation {
        static let title = "你的出生地在哪?"
    }

    enum Gender {
        static let title = "你的生理性别是"
        static let info = "性别是八字排盘的必需信息，用于确定大运"
    }

    enum Permissions {
        static let title = "开启权限"
        static let camera = "相机"
        static let microphone = "麦克风"
        static let location = "位置"
    }

    enum BaziResult {
        static let pageTitles = ["纳音", "舒适区", "能量来源", "相冲能量"]
        static let placeholders = [
            "与你相冲的能量是「庚金」，原本安稳的生活状态容易被突发事件打乱。",
            "保持充足睡眠以及规律作息，能让你的木火能量保持温和流动。",
            "与信任的友人分享心得，或专注于手作、写作等需要耐心的活动，可获得长久的内在滋养。",
            "遇到任务堆叠时，先照顾好自己的节奏与界限，再决定要投入哪些链接，避免精力被过度消耗。"
        ]
    }

    enum Main {
        static func greeting(name: String, period: String) -> String {
            "\(period)好 \(name)"
        }
        static let greetingQuestion = "你今天的感受是怎样的?"
        static let addEnvironmentTitle = "添加你的第一个环境"
        static let addEnvironmentSubtitle = "开启天人合一之境"
        static let tabEnvironment = "环境"
        static let tabSelf = "自我"
        static let tabAdd = "添加"
    }

    enum SelfCenter {
        static let tabFavorites = "收藏"
        static let tabSelf = "自我"
        static let tabSettings = "设置"
        static let sectionProfile = "个人信息"
        static let sectionReminder = "提醒"
        static let sectionLanguage = "语言"
        static let sectionTerms = "条款与条件"
        static let sectionPrivacy = "隐私"
        static let sectionSubscription = "订阅"
        static let sectionAbout = "关于"
        static let logout = "退出"
    }

    enum Tutorial {
        static let title = "捕捉完整环境"
        static let bullet1 = "将椅子和完整桌面放进框内"
        static let bullet2 = "确保环境有足够的光亮"
        static let bullet3 = "椅子到拍摄者之间没有遮挡"
    }

    enum Preview {
        static let titleSpring = "春天的"
        static let subtitleSpring = "像风一样"
        static let titleLight = "唯一的光"
        static let subtitleLight = "糖葫芦"
        static let titleWander = "游离在外"
        static let actionOpen = "开启"
    }

    enum Report {
        static let subtitle = "前室环境写实报告 · 工位分析"
        static let moreQuestions = "更多问题?"
        static let actionChat = "对话"
    }

    enum ChatIntro {
        static func greeting(name: String) -> String {
            "你好 \(name)\n关于报告、环境\n或自我的\n任何疑问?\n或 随便聊聊也好"
        }
        static let prompt1 = "今天莫名心情有点糟 是什么情况"
        static let prompt2 = "报告中有提到关于事业运的分析 我该怎样提升事业运?"
        static let prompt3 = "新买了个植物 放在哪比较合适?"
        static let placeholder = "输入一切"
    }

    enum CaptureComplete {
        static let title = "感谢完成拍摄"
        static let subtitle = "稍候我们将为你获取方位信息"
    }

    enum OrientationCapture {
        static let title = "获取方向"
        static let subtitle = "将手机保持稳定，3秒后自动记录当前朝向"
        static let recording = "正在捕捉"
        static let completed = "已记录"
    }
}
