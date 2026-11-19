import UIKit

/// 半屏顶栏：高 56、白底、底部分割线、右侧勾确认。对齐源 `LPSheetNavBar`。
final class PanSheetNavBar: UIView {
    /// 标题。
    private let titleLabel = UILabel()

    /// 右侧确认。
    private let confirmButton = UIButton(type: .system)

    /// 底部分割线。
    private let divider = UIView()

    /// 点确认。
    var onConfirm: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = PanSheetPalette.backgroundWhite
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = PanSheetPalette.textPrimary
        titleLabel.textAlignment = .center
        confirmButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        confirmButton.tintColor = PanSheetPalette.confirmTint
        confirmButton.accessibilityIdentifier = "sheet-nav-confirm"
        confirmButton.addTarget(self, action: #selector(tapConfirm), for: .touchUpInside)
        divider.backgroundColor = PanSheetPalette.divider
        addSubview(titleLabel)
        addSubview(confirmButton)
        addSubview(divider)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: PanSheetMetrics.navBarHeight),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 56),
            confirmButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            confirmButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 44),
            confirmButton.heightAnchor.constraint(equalToConstant: 44),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
        ])
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    required init?(coder: NSCoder) {
        nil
    }

    /// 写入标题。
    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    @objc private func tapConfirm() {
        onConfirm?()
    }
}
