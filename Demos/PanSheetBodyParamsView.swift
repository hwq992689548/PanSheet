import UIKit

/// 固定高场景 body 内的参数表。
final class PanSheetBodyParamsView: UIView {
    /// 当前行。
    private var lineLabels: [UILabel] = []

    /// 刷新键值行。
    func setLines(_ lines: [(String, String)]) {
        lineLabels.forEach { $0.removeFromSuperview() }
        lineLabels.removeAll()
        var previous: UILabel?
        for line in lines {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
            label.textColor = PanSheetPalette.textPrimary
            label.text = "\(line.0)  \(line.1)"
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: leadingAnchor),
                label.trailingAnchor.constraint(equalTo: trailingAnchor),
                label.topAnchor.constraint(equalTo: previous?.bottomAnchor ?? topAnchor, constant: previous == nil ? 0 : 6),
            ])
            previous = label
            lineLabels.append(label)
        }
        previous?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
