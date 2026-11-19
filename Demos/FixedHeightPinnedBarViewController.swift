import PanSheet
import UIKit

/// 固定高度 · 场景3：body 与底栏互不连接；中间 gap 吃变高；整屏 0.45 + 0.8。
final class FixedHeightPinnedBarViewController: UIViewController {
    /// 钉在 content 底的底栏。
    private let bottomBar = PanSheetSafeBottomBar()

    /// 中间可伸缩空白。
    private let gap = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PanSheetPalette.backgroundWhite
        view.accessibilityIdentifier = "debug-sheet-scenario-fixed-height-3-content"
        bottomBar.setAccessibilityName("debug-sheet-scenario-3-bottom-bar")
        bottomBar.onTap = { [weak self] in
            guard let self else { return }
            PanSheetPresenter.dismiss(from: self)
        }
        gap.accessibilityIdentifier = "debug-sheet-scenario-fixed-height-3-gap"
        let nav = installNavBar(title: "场景3·钉底栏")
        let body = UIView()
        body.backgroundColor = PanSheetPalette.bodyFill
        body.accessibilityIdentifier = "debug-sheet-scenario-fixed-height-3-body"
        let params = PanSheetBodyParamsView()
        params.accessibilityIdentifier = "debug-sheet-scenario-fixed-height-3-tip"
        let barBlock = Int(bottomBar.fittingHeight())
        params.setLines([
            ("场景", "3 · 固定高度 · 钉底栏"),
            ("body", "\(Int(PanSheetMetrics.bodyHeight)) · 只钉高，不连底栏"),
            ("底栏", "\(barBlock) · 只钉父底"),
            ("中间", "gap 吃变高"),
            ("档位", "整屏 rate 0.45 + 0.8"),
            ("对照", "场景2 底栏贴 body 共同进退"),
        ])
        view.addSubview(body)
        view.addSubview(gap)
        view.addSubview(bottomBar)
        body.addSubview(params)
        body.translatesAutoresizingMaskIntoConstraints = false
        gap.translatesAutoresizingMaskIntoConstraints = false
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
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gap.topAnchor.constraint(equalTo: body.bottomAnchor),
            gap.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gap.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gap.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
        ])
        gap.setContentHuggingPriority(.defaultLow, for: .vertical)
        gap.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let lift = PanSheetContentRelativeSnaps.resolveLift(in: self)
        if abs((bottomBar.safeBottomOverride ?? -1) - lift) > 0.5 {
            bottomBar.safeBottomOverride = lift
        }
    }
}
