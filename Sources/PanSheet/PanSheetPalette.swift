import UIKit

/// 半屏默认色。集成方可在自己的内容页覆盖。
public enum PanSheetPalette {
    /// 灰页底。
    public static let backgroundGray = UIColor.systemGroupedBackground
    /// 白页底。
    public static let backgroundWhite = UIColor.systemBackground
    /// 白底上的卡片。
    public static let cardOnWhite = UIColor.secondarySystemBackground
    /// 主文案。
    public static let textPrimary = UIColor.label
    /// 次文案。
    public static let textSecondary = UIColor.secondaryLabel
    /// 弱文案。
    public static let textTertiary = UIColor.tertiaryLabel
    /// 分割线。
    public static let divider = UIColor.separator
    /// 固定高度 body 底。
    public static let bodyFill = UIColor.systemBlue.withAlphaComponent(0.12)
    /// 输入 body 底。
    public static let inputBodyFill = UIColor.systemCyan.withAlphaComponent(0.12)
    /// 自管 safeBottom 橙垫。
    public static let safePadFill = UIColor.systemOrange.withAlphaComponent(0.55)
    /// 主按钮填充。
    public static let buttonFill = UIColor.systemGreen
    /// 主按钮标题。
    public static let buttonTitle = UIColor.white
    /// 顶栏确认勾。
    public static let confirmTint = UIColor.systemGreen
    /// 抓手。
    public static let grabber = UIColor.tertiaryLabel
}
