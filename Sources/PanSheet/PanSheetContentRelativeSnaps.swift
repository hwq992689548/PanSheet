import UIKit

/// 内容相对满高换算：表面 = (顶栏+body[+底栏]) × rate。
public enum PanSheetContentRelativeSnaps {
    /// 读 window Home 指示条高度。
    public static func resolveLift(in host: UIViewController) -> CGFloat {
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
    public static func contentRelativeDetents(panelHeight: CGFloat) -> [PanSheetDetent] {
        let full = max(0, panelHeight)
        return [
            .height(full * PanSheetMetrics.contentHalfRate, id: "content-half"),
            .height(full * PanSheetMetrics.contentFullRate, id: "content-full"),
        ]
    }

    /// 输入单档满高。
    public static func inputFullDetent(panelHeight: CGFloat) -> PanSheetDetent {
        .height(max(0, panelHeight), id: "input-full")
    }

    /// 正常 Sheet 整屏双档。
    public static func screenRateDetents() -> [PanSheetDetent] {
        [
            .fraction(PanSheetMetrics.screenLowRate, id: "screen-045"),
            .fraction(PanSheetMetrics.screenHighRate, id: "screen-080"),
        ]
    }
}
