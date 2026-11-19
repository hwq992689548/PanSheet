import UIKit

/// `UISheetPresentationController` 自定义档，对应源四号 `XWonderSnap`。
struct PanSheetDetent {
    /// 系统 detent 标识。
    let identifier: UISheetPresentationController.Detent.Identifier

    /// 根据 `maximumDetentValue` 算出档高。
    let resolve: (CGFloat) -> CGFloat

    /// 转成系统 detent。
    var uiDetent: UISheetPresentationController.Detent {
        let identifier = identifier
        let resolve = resolve
        return .custom(identifier: identifier) { context in
            let raw = resolve(context.maximumDetentValue)
            return min(max(0, raw), context.maximumDetentValue)
        }
    }

    /// 固定点高（内容定高 0.5 / 1，或输入单档）。
    static func height(_ value: CGFloat, id: String) -> PanSheetDetent {
        PanSheetDetent(identifier: .init(id)) { _ in value }
    }

    /// 相对整屏最大 detent 的比例（列表 / 钉底栏 0.45 + 0.8）。
    static func fraction(_ rate: CGFloat, id: String) -> PanSheetDetent {
        PanSheetDetent(identifier: .init(id)) { maximum in
            maximum * rate
        }
    }
}

/// 内容相对满高换算：表面 = (顶栏+body[+底栏]) × rate，对齐源 `fixedSnaps`。
enum PanSheetContentRelativeSnaps {
    /// 读 window Home 指示条高度。
    static func resolveLift(in host: UIViewController) -> CGFloat {
        if let window = host.view.window {
            return max(0, window.safeAreaInsets.bottom)
        }
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        if let window = scenes.flatMap(\.windows).first(where: \.isKeyWindow) {
            return max(0, window.safeAreaInsets.bottom)
        }
        return max(0, host.view.safeAreaInsets.bottom)
    }

    /// 内容定高双档：相对满高 0.5 + 1。
    static func contentRelativeDetents(panelHeight: CGFloat) -> [PanSheetDetent] {
        let full = max(0, panelHeight)
        return [
            .height(full * PanSheetMetrics.contentHalfRate, id: "content-half"),
            .height(full * PanSheetMetrics.contentFullRate, id: "content-full"),
        ]
    }

    /// 输入单档满高。
    static func inputFullDetent(panelHeight: CGFloat) -> PanSheetDetent {
        .height(max(0, panelHeight), id: "input-full")
    }

    /// 正常 Sheet 整屏双档。
    static func screenRateDetents() -> [PanSheetDetent] {
        [
            .fraction(PanSheetMetrics.screenLowRate, id: "screen-045"),
            .fraction(PanSheetMetrics.screenHighRate, id: "screen-080"),
        ]
    }
}
