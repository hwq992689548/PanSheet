import UIKit

/// 半屏档位布局。8 种场景工厂会填好对应 case。
public enum PanSheetLayout {
    /// 固定高度场景1：相对内容满高 0.5 + 1，panel = 顶栏 + body + safeBottom。
    case contentRelativeManagedSafeBottom
    /// 固定高度场景2：相对内容满高 0.5 + 1，panel = 顶栏 + body + 跟手底栏。
    case contentRelativeBottomBarFollow
    /// 固定高度场景3 / 三个列表场景：整屏 0.45 + 0.8。
    case screenRates
    /// 单行输入：单档满高。
    case inputSingleLine
    /// 多行输入：单档满高，正文按 `textMinHeight` 起算。
    case inputMultiline
    /// 调用方自己给档。
    case custom([PanSheetDetent])

    /// 按宿主 Home 指示条算出当前档位。
    public func makeDetents(lift: CGFloat) -> [PanSheetDetent] {
        switch self {
        case .contentRelativeManagedSafeBottom:
            let panel = PanSheetMetrics.navBarHeight + PanSheetMetrics.bodyHeight + lift
            return PanSheetContentRelativeSnaps.contentRelativeDetents(panelHeight: panel)
        case .contentRelativeBottomBarFollow:
            let bar = PanSheetSafeBottomBar.fittingHeight(safeBottom: lift, keyboardLifted: false)
            let panel = PanSheetMetrics.navBarHeight + PanSheetMetrics.bodyHeight + bar
            return PanSheetContentRelativeSnaps.contentRelativeDetents(panelHeight: panel)
        case .screenRates:
            return PanSheetContentRelativeSnaps.screenRateDetents()
        case .inputSingleLine:
            let body = PanSheetMetrics.bodyVerticalPad * 2 + PanSheetMetrics.textFieldHeight
            let bar = PanSheetSafeBottomBar.fittingHeight(safeBottom: lift, keyboardLifted: false)
            let panel = PanSheetMetrics.navBarHeight + body + bar
            return [PanSheetContentRelativeSnaps.inputFullDetent(panelHeight: panel)]
        case .inputMultiline:
            let body = PanSheetMetrics.bodyVerticalPad * 2 + PanSheetMetrics.textMinHeight
            let bar = PanSheetSafeBottomBar.fittingHeight(safeBottom: lift, keyboardLifted: false)
            let panel = PanSheetMetrics.navBarHeight + body + bar
            return [PanSheetContentRelativeSnaps.inputFullDetent(panelHeight: panel)]
        case .custom(let detents):
            return detents
        }
    }
}

/// 弹出半屏的配置。用 8 个场景工厂，或自己填 `layout`。
public struct PanSheetConfig {
    /// 半屏内容页，由调用方创建。
    public var content: UIViewController
    /// 档位布局。
    public var layout: PanSheetLayout
    /// 默认停在第几档，从 0 起。
    public var selectedDetentIndex: Int
    /// 是否显示系统抓手。
    public var prefersGrabberVisible: Bool
    /// 列表贴顶滚动时半屏跟手升档 / 降档。
    public var followsScrolling: Bool
    /// 半屏圆角。
    public var preferredCornerRadius: CGFloat
    /// 弹出动画。
    public var animated: Bool
    /// 为 true 时不能滑出最低档关掉。
    public var isModalInPresentation: Bool

    /// 组装一份配置。
    public init(
        content: UIViewController,
        layout: PanSheetLayout,
        selectedDetentIndex: Int = 0,
        prefersGrabberVisible: Bool = true,
        followsScrolling: Bool = true,
        preferredCornerRadius: CGFloat = PanSheetMetrics.sheetCornerRadius,
        animated: Bool = true,
        isModalInPresentation: Bool = false
    ) {
        self.content = content
        self.layout = layout
        self.selectedDetentIndex = selectedDetentIndex
        self.prefersGrabberVisible = prefersGrabberVisible
        self.followsScrolling = followsScrolling
        self.preferredCornerRadius = preferredCornerRadius
        self.animated = animated
        self.isModalInPresentation = isModalInPresentation
    }

    /// 固定高度 · 场景1·内容自管 safeBottom。
    public static func fixedManagedSafeBottom(content: UIViewController) -> PanSheetConfig {
        PanSheetConfig(content: content, layout: .contentRelativeManagedSafeBottom)
    }

    /// 固定高度 · 场景2·底栏跟手。
    public static func fixedBottomBarFollow(content: UIViewController) -> PanSheetConfig {
        PanSheetConfig(content: content, layout: .contentRelativeBottomBarFollow)
    }

    /// 固定高度 · 场景3·钉底栏。
    public static func fixedPinnedBar(content: UIViewController) -> PanSheetConfig {
        PanSheetConfig(content: content, layout: .screenRates)
    }

    /// 输入框 · 单行输入 + 底栏。
    public static func inputSingleLine(content: UIViewController) -> PanSheetConfig {
        PanSheetConfig(content: content, layout: .inputSingleLine)
    }

    /// 输入框 · 多行 120～240 往上撑开。
    public static func inputMultiline(content: UIViewController) -> PanSheetConfig {
        PanSheetConfig(content: content, layout: .inputMultiline)
    }

    /// 列表 · 场景1·列表铺满。
    public static func listFill(content: UIViewController) -> PanSheetConfig {
        PanSheetConfig(content: content, layout: .screenRates)
    }

    /// 列表 · 场景2·按钮 Cell。
    public static func listButtonCell(content: UIViewController) -> PanSheetConfig {
        PanSheetConfig(content: content, layout: .screenRates)
    }

    /// 列表 · 场景3·钉底栏。
    public static func listPinnedBar(content: UIViewController) -> PanSheetConfig {
        PanSheetConfig(content: content, layout: .screenRates)
    }
}
