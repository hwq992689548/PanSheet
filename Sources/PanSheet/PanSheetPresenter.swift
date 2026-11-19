import UIKit

/// 用系统 `UISheetPresentationController` 弹出半屏。
public enum PanSheetPresenter {
    /// 按配置弹出内容页。`followsScrolling` 打开时，贴顶列表滚到边界会带着半屏换档。
    public static func present(from host: UIViewController, config: PanSheetConfig) {
        let content = config.content
        content.modalPresentationStyle = .pageSheet
        content.modalTransitionStyle = .coverVertical
        content.isModalInPresentation = config.isModalInPresentation
        let lift = PanSheetContentRelativeSnaps.resolveLift(in: host)
        let detents = config.layout.makeDetents(lift: lift)
        let selected: PanSheetDetent?
        if config.selectedDetentIndex >= 0, config.selectedDetentIndex < detents.count {
            selected = detents[config.selectedDetentIndex]
        } else {
            selected = detents.first
        }
        if let sheet = content.sheetPresentationController {
            sheet.detents = detents.map(\.uiDetent)
            sheet.selectedDetentIdentifier = selected?.identifier
            sheet.prefersGrabberVisible = config.prefersGrabberVisible
            sheet.prefersScrollingExpandsWhenScrolledToEdge = config.followsScrolling
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.preferredCornerRadius = config.preferredCornerRadius
        }
        host.present(content, animated: config.animated)
    }

    /// 关闭当前半屏。
    public static func dismiss(from content: UIViewController) {
        content.dismiss(animated: true)
    }

    /// 输入场景：键盘抬起或正文变高时改单档高度。
    public static func updateInputDetent(on content: UIViewController, panelHeight: CGFloat) {
        guard let sheet = content.sheetPresentationController else { return }
        let detent = PanSheetContentRelativeSnaps.inputFullDetent(panelHeight: panelHeight)
        sheet.animateChanges {
            sheet.detents = [detent.uiDetent]
            sheet.selectedDetentIdentifier = detent.identifier
        }
    }
}
