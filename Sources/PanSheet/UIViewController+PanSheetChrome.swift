import UIKit

extension UIViewController {
    /// 装半屏顶栏并钉在 content 顶。
    @discardableResult
    public func installNavBar(title: String) -> PanSheetNavBar {
        let bar = PanSheetNavBar()
        bar.setTitle(title)
        bar.onConfirm = { [weak self] in
            guard let self else { return }
            PanSheetPresenter.dismiss(from: self)
        }
        bar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar)
        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        return bar
    }
}
