import PanSheet
import UIKit

/// 固定高度 · 场景1：顶栏 + body 恒 500 + 内容自管橙 safe 垫。
final class FixedHeightManagedSafeBottomViewController: UIViewController {
    /// 橙垫。
    private let safePad = UIView()

    /// 橙垫高度。
    private var safePadHeightConstraint: NSLayoutConstraint?

    /// 参数表。
    private let params = PanSheetBodyParamsView()

    /// 橙垫文案。
    private let padLabel = UILabel()

    /// 上次写入的垫高。
    private var lastAppliedSafeBottom: CGFloat = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PanSheetPalette.backgroundWhite
        view.accessibilityIdentifier = "debug-sheet-scenario-fixed-height-content"
        let nav = installNavBar(title: "场景1·内容自管")
        let body = UIView()
        body.backgroundColor = PanSheetPalette.bodyFill
        body.accessibilityIdentifier = "debug-sheet-scenario-fixed-height-body"
        params.accessibilityIdentifier = "debug-sheet-scenario-fixed-height-tip"
        safePad.backgroundColor = PanSheetPalette.safePadFill
        safePad.accessibilityIdentifier = "debug-sheet-scenario-fixed-height-safe-pad"
        padLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        padLabel.textColor = .black
        padLabel.textAlignment = .center
        padLabel.numberOfLines = 0
        view.addSubview(body)
        view.addSubview(safePad)
        body.addSubview(params)
        safePad.addSubview(padLabel)
        body.translatesAutoresizingMaskIntoConstraints = false
        safePad.translatesAutoresizingMaskIntoConstraints = false
        params.translatesAutoresizingMaskIntoConstraints = false
        padLabel.translatesAutoresizingMaskIntoConstraints = false
        let lift = resolvedSafeBottom
        let padHeight = safePad.heightAnchor.constraint(equalToConstant: lift)
        safePadHeightConstraint = padHeight
        NSLayoutConstraint.activate([
            body.topAnchor.constraint(equalTo: nav.bottomAnchor),
            body.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            body.heightAnchor.constraint(equalToConstant: PanSheetMetrics.bodyHeight),
            params.topAnchor.constraint(equalTo: body.topAnchor, constant: PanSheetMetrics.pageInset),
            params.leadingAnchor.constraint(equalTo: body.leadingAnchor, constant: PanSheetMetrics.pageInset),
            params.trailingAnchor.constraint(equalTo: body.trailingAnchor, constant: -PanSheetMetrics.pageInset),
            safePad.topAnchor.constraint(equalTo: body.bottomAnchor),
            safePad.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            safePad.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            padHeight,
            padLabel.centerXAnchor.constraint(equalTo: safePad.centerXAnchor),
            padLabel.centerYAnchor.constraint(equalTo: safePad.centerYAnchor),
            padLabel.leadingAnchor.constraint(equalTo: safePad.leadingAnchor, constant: 8),
            padLabel.trailingAnchor.constraint(equalTo: safePad.trailingAnchor, constant: -8),
        ])
        lastAppliedSafeBottom = lift
        applySafePadCopy(safeBottom: lift)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let lift = resolvedSafeBottom
        guard abs(lift - lastAppliedSafeBottom) > 0.5 else { return }
        lastAppliedSafeBottom = lift
        safePadHeightConstraint?.constant = lift
        applySafePadCopy(safeBottom: lift)
    }

    private var resolvedSafeBottom: CGFloat {
        PanSheetContentRelativeSnaps.resolveLift(in: self)
    }

    private func applySafePadCopy(safeBottom: CGFloat) {
        padLabel.text = "自管 safeBottom = \(Int(safeBottom))（不算进 body）"
        let navH = Int(PanSheetMetrics.navBarHeight)
        let bodyH = Int(PanSheetMetrics.bodyHeight)
        let sb = Int(safeBottom)
        let panel = navH + bodyH + sb
        params.setLines([
            ("场景", "1 · 内容自管 safeBottom"),
            ("body", "\(bodyH) ← 只要这个高，不是 \(bodyH + sb)"),
            ("自管垫", "\(sb) · 橙条在 body 下，不算 body"),
            ("顶栏", "\(navH)"),
            ("preferred", "\(panel) = 顶栏+body+自管垫"),
            ("档位", "相对满高 0.5 + 1"),
        ])
    }
}
