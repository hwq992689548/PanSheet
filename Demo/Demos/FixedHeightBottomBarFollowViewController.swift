import PanSheet
import UIKit

/// 固定高度 · 场景2：底栏贴 body 下，与 body 共同进退。
final class FixedHeightBottomBarFollowViewController: UIViewController {
    /// 底栏。
    private let bottomBar = PanSheetSafeBottomBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PanSheetPalette.backgroundWhite
        view.accessibilityIdentifier = "debug-sheet-scenario-fixed-height-2-content"
        bottomBar.setAccessibilityName("debug-sheet-scenario-2-bottom-bar")
        bottomBar.onTap = { [weak self] in
            guard let self else { return }
            PanSheetPresenter.dismiss(from: self)
        }
        let nav = installNavBar(title: "场景2·底栏跟手")
        let body = UIView()
        body.backgroundColor = PanSheetPalette.bodyFill
        body.accessibilityIdentifier = "debug-sheet-scenario-fixed-height-2-body"
        let params = PanSheetBodyParamsView()
        params.accessibilityIdentifier = "debug-sheet-scenario-fixed-height-2-tip"
        params.setLines(paramLines)
        view.addSubview(body)
        view.addSubview(bottomBar)
        body.addSubview(params)
        body.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        params.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            body.topAnchor.constraint(equalTo: nav.bottomAnchor),
            body.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            body.heightAnchor.constraint(equalToConstant: PanSheetMetrics.bodyHeight),
            params.topAnchor.constraint(equalTo: body.topAnchor, constant: PanSheetMetrics.pageInset),
            params.leadingAnchor.constraint(equalTo: body.leadingAnchor, constant: PanSheetMetrics.pageInset),
            params.trailingAnchor.constraint(equalTo: body.trailingAnchor, constant: -PanSheetMetrics.pageInset),
            bottomBar.topAnchor.constraint(equalTo: body.bottomAnchor),
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private var paramLines: [(String, String)] {
        let lift = PanSheetContentRelativeSnaps.resolveLift(in: self)
        let barBlock = Int(bottomBar.fittingHeight())
        let panel = Int(PanSheetMetrics.navBarHeight + PanSheetMetrics.bodyHeight + bottomBar.fittingHeight())
        return [
            ("场景", "2 · 固定高度 · 底栏跟手"),
            ("顶栏", "\(Int(PanSheetMetrics.navBarHeight))（不算内容）"),
            ("body", "\(Int(PanSheetMetrics.bodyHeight)) · 禁止拉伸"),
            ("safeBottom", "\(Int(lift)) · 底栏自读"),
            ("底栏 inset", "max(24, sb) = \(Int(max(24, lift)))"),
            ("底栏块高", "\(barBlock) · 禁止拉高/压扁"),
            ("放置", "底栏钉高贴 body 下 · 共同进退"),
            ("档位", "0.5 + 1"),
            ("panel", "\(panel) = preferred"),
        ]
    }
}
