import UIKit

/// 用系统 `UISheetPresentationController` 弹出半屏，对应源四号 `presentWonder`。
enum PanSheetPresenter {
    /// 弹出内容页；`animated` 为 false 时给截图用。
    static func present(
        _ content: UIViewController,
        from host: UIViewController,
        detents: [PanSheetDetent],
        selected: PanSheetDetent? = nil,
        animated: Bool = true
    ) {
        content.modalPresentationStyle = .pageSheet
        content.modalTransitionStyle = .coverVertical
        // 录跟手 GIF 时禁止滑到最低档以下关掉，只在档位之间移动。
        if ProcessInfo.processInfo.arguments.contains("--hold-sheet") {
            content.isModalInPresentation = true
        }
        if let sheet = content.sheetPresentationController {
            sheet.detents = detents.map(\.uiDetent)
            sheet.selectedDetentIdentifier = (selected ?? detents.first)?.identifier
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.preferredCornerRadius = PanSheetMetrics.sheetCornerRadius
        }
        host.present(content, animated: animated)
    }

    /// 按场景装配档位并弹出。
    static func present(_ scene: DemoScene, from host: UIViewController, animated: Bool = true) {
        let lift = PanSheetContentRelativeSnaps.resolveLift(in: host)
        switch scene {
        case .home:
            return
        case .fixed1:
            let panel = PanSheetMetrics.navBarHeight + PanSheetMetrics.bodyHeight + lift
            let detents = PanSheetContentRelativeSnaps.contentRelativeDetents(panelHeight: panel)
            present(
                FixedHeightManagedSafeBottomViewController(),
                from: host,
                detents: detents,
                selected: detents.first,
                animated: animated
            )
        case .fixed2:
            let bar = PanSheetSafeBottomBar.fittingHeight(safeBottom: lift, keyboardLifted: false)
            let panel = PanSheetMetrics.navBarHeight + PanSheetMetrics.bodyHeight + bar
            let detents = PanSheetContentRelativeSnaps.contentRelativeDetents(panelHeight: panel)
            present(
                FixedHeightBottomBarFollowViewController(),
                from: host,
                detents: detents,
                selected: detents.first,
                animated: animated
            )
        case .fixed3:
            let detents = PanSheetContentRelativeSnaps.screenRateDetents()
            present(
                FixedHeightPinnedBarViewController(),
                from: host,
                detents: detents,
                selected: detents.first,
                animated: animated
            )
        case .inputSingle:
            let body = PanSheetMetrics.bodyVerticalPad * 2 + PanSheetMetrics.textFieldHeight
            let bar = PanSheetSafeBottomBar.fittingHeight(safeBottom: lift, keyboardLifted: false)
            let panel = PanSheetMetrics.navBarHeight + body + bar
            let detent = PanSheetContentRelativeSnaps.inputFullDetent(panelHeight: panel)
            present(
                InputSingleLineViewController(),
                from: host,
                detents: [detent],
                selected: detent,
                animated: animated
            )
        case .inputMulti:
            let body = PanSheetMetrics.bodyVerticalPad * 2 + PanSheetMetrics.textMinHeight
            let bar = PanSheetSafeBottomBar.fittingHeight(safeBottom: lift, keyboardLifted: false)
            let panel = PanSheetMetrics.navBarHeight + body + bar
            let detent = PanSheetContentRelativeSnaps.inputFullDetent(panelHeight: panel)
            present(
                InputMultilineViewController(),
                from: host,
                detents: [detent],
                selected: detent,
                animated: animated
            )
        case .listFill:
            let detents = PanSheetContentRelativeSnaps.screenRateDetents()
            present(
                ListFillViewController(),
                from: host,
                detents: detents,
                selected: detents.first,
                animated: animated
            )
        case .listButton:
            let detents = PanSheetContentRelativeSnaps.screenRateDetents()
            present(
                ListButtonCellViewController(),
                from: host,
                detents: detents,
                selected: detents.first,
                animated: animated
            )
        case .listPinned:
            let detents = PanSheetContentRelativeSnaps.screenRateDetents()
            present(
                ListPinnedBarViewController(),
                from: host,
                detents: detents,
                selected: detents.first,
                animated: animated
            )
        }
    }

    /// 关闭当前半屏。
    static func dismiss(from content: UIViewController) {
        content.dismiss(animated: true)
    }

    /// 输入场景：键盘抬起或正文变高时改单档高度。
    static func updateInputDetent(on content: UIViewController, panelHeight: CGFloat) {
        guard let sheet = content.sheetPresentationController else { return }
        let detent = PanSheetContentRelativeSnaps.inputFullDetent(panelHeight: panelHeight)
        sheet.animateChanges {
            sheet.detents = [detent.uiDetent]
            sheet.selectedDetentIdentifier = detent.identifier
        }
    }
}
