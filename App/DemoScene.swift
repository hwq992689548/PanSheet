import UIKit

/// 与 LaserpeckerOS「开发调试 → Sheet 场景」入口一一对应，不另造变体。
enum DemoScene: String, CaseIterable {
    case home
    case fixed1 = "fixed-1"
    case fixed2 = "fixed-2"
    case fixed3 = "fixed-3"
    case inputSingle = "input-single"
    case inputMulti = "input-multi"
    case listFill = "list-fill"
    case listButton = "list-button"
    case listPinned = "list-pinned"

    /// 源场景标题（首页行、半屏顶栏共用）。
    var title: String {
        switch self {
        case .home:
            return "Sheet 场景"
        case .fixed1:
            return "场景1·内容自管 safeBottom"
        case .fixed2:
            return "场景2·底栏跟手"
        case .fixed3:
            return "场景3·钉底栏"
        case .inputSingle:
            return "单行输入 + 底栏"
        case .inputMulti:
            return "多行 120～240 往上撑开"
        case .listFill:
            return "场景1·列表铺满"
        case .listButton:
            return "场景2·按钮Cell"
        case .listPinned:
            return "场景3·钉底栏"
        }
    }

    /// 源场景副标题。
    var subtitle: String {
        switch self {
        case .home:
            return "四号穷举入口"
        case .fixed1:
            return "body 恒 500；底 safe 橙条自管；相对满高 0.5 + 1"
        case .fixed2:
            return "底栏贴 body 下；共同进退；相对满高 0.5 + 1"
        case .fixed3:
            return "body / 底栏互不连接；整屏 rate 0.45 + 0.8"
        case .inputSingle:
            return "单档 1；键盘底栏固定 24"
        case .inputMulti:
            return "单档 1；键盘底栏 24；变高不掉进键盘"
        case .listFill:
            return "原生 UITableView；无底栏；rate 0.45 + 0.8"
        case .listButton:
            return "原生表末行按钮 Cell 跟手；无 SafeBottomBar；rate 0.45 + 0.8"
        case .listPinned:
            return "原生表贴栏顶；栏自带 safeBottom；rate 0.45 + 0.8"
        }
    }

    /// 源入口 accessibilityIdentifier。
    var accessibilityIdentifier: String {
        switch self {
        case .home:
            return "debug-sheet-scenarios"
        case .fixed1:
            return "debug-sheet-scenario-1-content-managed"
        case .fixed2:
            return "debug-sheet-scenario-2-bottom-bar"
        case .fixed3:
            return "debug-sheet-scenario-3-pinned-bar"
        case .inputSingle:
            return "debug-sheet-scenario-input-single"
        case .inputMulti:
            return "debug-sheet-scenario-input-multi"
        case .listFill:
            return "debug-sheet-scenario-list-fill"
        case .listButton:
            return "debug-sheet-scenario-list-scroll-bar"
        case .listPinned:
            return "debug-sheet-scenario-list-pinned"
        }
    }

    /// 截图文件名（不含扩展名）。
    var screenshotName: String {
        rawValue
    }

    /// 从启动参数 `--demo=` 解析要自动弹出的场景。
    static func fromLaunchArguments() -> DemoScene? {
        for argument in ProcessInfo.processInfo.arguments {
            guard argument.hasPrefix("--demo=") else { continue }
            let value = String(argument.dropFirst("--demo=".count))
            return DemoScene(rawValue: value)
        }
        return nil
    }
}

/// 首页分组，对齐源页 Section。
enum DemoSceneGroup: String, CaseIterable {
    case fixedHeight = "固定高度"
    case input = "输入框"
    case list = "列表"

    var scenes: [DemoScene] {
        switch self {
        case .fixedHeight:
            return [.fixed1, .fixed2, .fixed3]
        case .input:
            return [.inputSingle, .inputMulti]
        case .list:
            return [.listFill, .listButton, .listPinned]
        }
    }
}
