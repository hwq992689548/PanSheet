import UIKit

/// 列表场景末行：整行一颗主按钮，跟手滚。
final class ListButtonCell: UITableViewCell {
    /// 复用 id。
    static let reuseId = "debug-sheet-scenario-list-button-cell"

    /// 主按钮。
    private let actionButton = UIButton(type: .system)

    /// 点击回调。
    var onTap: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = PanSheetPalette.backgroundWhite
        contentView.backgroundColor = PanSheetPalette.backgroundWhite
        actionButton.setTitle("确定", for: .normal)
        actionButton.setTitleColor(PanSheetPalette.buttonTitle, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        actionButton.backgroundColor = PanSheetPalette.buttonFill
        actionButton.layer.cornerRadius = 12
        actionButton.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    @objc private func tapAction() {
        onTap?()
    }
}
