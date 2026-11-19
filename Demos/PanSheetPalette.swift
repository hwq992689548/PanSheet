import UIKit

/// 演示色，不引用 LaserpeckerOS 令牌。
enum PanSheetPalette {
    static let backgroundGray = UIColor.systemGroupedBackground
    static let backgroundWhite = UIColor.systemBackground
    static let cardOnWhite = UIColor.secondarySystemBackground
    static let textPrimary = UIColor.label
    static let textSecondary = UIColor.secondaryLabel
    static let textTertiary = UIColor.tertiaryLabel
    static let divider = UIColor.separator
    static let bodyFill = UIColor.systemBlue.withAlphaComponent(0.12)
    static let inputBodyFill = UIColor.systemCyan.withAlphaComponent(0.12)
    static let safePadFill = UIColor.systemOrange.withAlphaComponent(0.55)
    static let buttonFill = UIColor.systemGreen
    static let buttonTitle = UIColor.white
    static let confirmTint = UIColor.systemGreen
    static let grabber = UIColor.tertiaryLabel
}

/// 与源场景一致的几何常量。
enum PanSheetMetrics {
    static let navBarHeight: CGFloat = 56
    static let bodyHeight: CGFloat = 500
    static let textFieldHeight: CGFloat = 48
    static let bodyVerticalPad: CGFloat = 24
    static let pageInset: CGFloat = 24
    static let bottomBarTopInset: CGFloat = 12
    static let bottomBarMinBottomInset: CGFloat = 24
    static let bottomBarButtonHeight: CGFloat = 44
    static let listRowHeight: CGFloat = 72
    static let listButtonCellHeight: CGFloat = 12 + 44 + 12
    static let textMinHeight: CGFloat = 120
    static let textMaxHeight: CGFloat = 240
    static let listFillRowCount = 20
    static let listButtonRowCount = 15
    static let sheetCornerRadius: CGFloat = 16
    static let contentHalfRate: CGFloat = 0.5
    static let contentFullRate: CGFloat = 1.0
    static let screenLowRate: CGFloat = 0.45
    static let screenHighRate: CGFloat = 0.8
}
