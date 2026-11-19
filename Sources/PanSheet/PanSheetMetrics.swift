import UIKit

/// 与源场景一致的几何常量，集成方可直接用，也可在 `PanSheetConfig` 里改档。
public enum PanSheetMetrics {
    /// 半屏顶栏高度。
    public static let navBarHeight: CGFloat = 56
    /// 固定高度场景 body 高度。
    public static let bodyHeight: CGFloat = 500
    /// 单行输入高度。
    public static let textFieldHeight: CGFloat = 48
    /// body 上下内边距。
    public static let bodyVerticalPad: CGFloat = 24
    /// 页左右边距。
    public static let pageInset: CGFloat = 24
    /// 底栏顶间距。
    public static let bottomBarTopInset: CGFloat = 12
    /// 底栏非键盘时的最小底间距。
    public static let bottomBarMinBottomInset: CGFloat = 24
    /// 底栏主按钮高度。
    public static let bottomBarButtonHeight: CGFloat = 44
    /// 列表普通行高。
    public static let listRowHeight: CGFloat = 72
    /// 列表末行按钮 Cell 高度。
    public static let listButtonCellHeight: CGFloat = 12 + 44 + 12
    /// 多行输入最小高度。
    public static let textMinHeight: CGFloat = 120
    /// 多行输入最大高度。
    public static let textMaxHeight: CGFloat = 240
    /// 列表铺满演示行数。
    public static let listFillRowCount = 20
    /// 按钮 Cell 场景普通行数。
    public static let listButtonRowCount = 15
    /// 半屏圆角。
    public static let sheetCornerRadius: CGFloat = 16
    /// 内容定高低档比例。
    public static let contentHalfRate: CGFloat = 0.5
    /// 内容定高满档比例。
    public static let contentFullRate: CGFloat = 1.0
    /// 整屏低档比例。
    public static let screenLowRate: CGFloat = 0.45
    /// 整屏高档比例。
    public static let screenHighRate: CGFloat = 0.8
}
