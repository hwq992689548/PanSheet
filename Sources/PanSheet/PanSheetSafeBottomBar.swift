import UIKit

/// 贴底操作条。非键盘底 inset = max(24, safeBottom)；键盘时顶底都是 12。
public final class PanSheetSafeBottomBar: UIView {
    /// 内容容器。
    private let contentView = UIView()

    /// 主按钮。
    private let actionButton = UIButton(type: .system)

    /// contentView 底间距。
    private var contentBottomConstraint: NSLayoutConstraint?

    /// 覆盖 Home 高度；nil 时读 window。
    public var safeBottomOverride: CGFloat? {
        didSet { reloadBottomInset() }
    }

    /// 键盘抬起时底间距改成 12。
    public var isKeyboardLifted = false {
        didSet {
            guard oldValue != isKeyboardLifted else { return }
            reloadBottomInset()
        }
    }

    /// 点确定。
    public var onTap: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = PanSheetPalette.backgroundWhite
        contentView.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitle("确定", for: .normal)
        actionButton.setTitleColor(PanSheetPalette.buttonTitle, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        actionButton.backgroundColor = PanSheetPalette.buttonFill
        actionButton.layer.cornerRadius = 12
        actionButton.clipsToBounds = true
        actionButton.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        addSubview(contentView)
        contentView.addSubview(actionButton)
        let bottom = contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -resolvedBottomInset)
        contentBottomConstraint = bottom
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PanSheetMetrics.pageInset),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -PanSheetMetrics.pageInset),
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: PanSheetMetrics.bottomBarTopInset),
            bottom,
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            actionButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: PanSheetMetrics.bottomBarButtonHeight),
        ])
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: fittingHeight())
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        reloadBottomInset()
    }

    public override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        reloadBottomInset()
    }

    /// 写入按钮无障碍 id。
    public func setAccessibilityName(_ name: String) {
        actionButton.accessibilityIdentifier = name
        accessibilityIdentifier = name
    }

    /// 当前条总高。
    public func fittingHeight() -> CGFloat {
        Self.fittingHeight(safeBottom: resolveSafeBottom(), keyboardLifted: isKeyboardLifted)
    }

    /// 量 panel / snap 用的条高。
    public static func fittingHeight(safeBottom: CGFloat, keyboardLifted: Bool) -> CGFloat {
        let bottom: CGFloat
        if keyboardLifted {
            bottom = PanSheetMetrics.bottomBarTopInset
        } else {
            bottom = max(PanSheetMetrics.bottomBarMinBottomInset, safeBottom)
        }
        return PanSheetMetrics.bottomBarTopInset + PanSheetMetrics.bottomBarButtonHeight + bottom
    }

    private var resolvedBottomInset: CGFloat {
        if isKeyboardLifted {
            return PanSheetMetrics.bottomBarTopInset
        }
        return max(PanSheetMetrics.bottomBarMinBottomInset, resolveSafeBottom())
    }

    private func resolveSafeBottom() -> CGFloat {
        if let safeBottomOverride {
            return max(0, safeBottomOverride)
        }
        if let window {
            return max(0, window.safeAreaInsets.bottom)
        }
        return max(0, safeAreaInsets.bottom)
    }

    private func reloadBottomInset() {
        contentBottomConstraint?.constant = -resolvedBottomInset
        invalidateIntrinsicContentSize()
    }

    @objc private func tapAction() {
        onTap?()
    }
}
