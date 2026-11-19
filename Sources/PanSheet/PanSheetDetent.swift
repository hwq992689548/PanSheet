import UIKit

/// `UISheetPresentationController` 自定义档。
public struct PanSheetDetent {
    /// 系统 detent 标识。
    public let identifier: UISheetPresentationController.Detent.Identifier

    /// 根据 `maximumDetentValue` 算出档高。
    public let resolve: (CGFloat) -> CGFloat

    /// 转成系统 detent。
    public var uiDetent: UISheetPresentationController.Detent {
        let identifier = identifier
        let resolve = resolve
        return .custom(identifier: identifier) { context in
            let raw = resolve(context.maximumDetentValue)
            return min(max(0, raw), context.maximumDetentValue)
        }
    }

    /// 固定点高（内容定高 0.5 / 1，或输入单档）。
    public static func height(_ value: CGFloat, id: String) -> PanSheetDetent {
        PanSheetDetent(identifier: .init(id)) { _ in value }
    }

    /// 相对整屏最大 detent 的比例（列表 / 钉底栏 0.45 + 0.8）。
    public static func fraction(_ rate: CGFloat, id: String) -> PanSheetDetent {
        PanSheetDetent(identifier: .init(id)) { maximum in
            maximum * rate
        }
    }
}
