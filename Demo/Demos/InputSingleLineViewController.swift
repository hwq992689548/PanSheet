import PanSheet
import UIKit

/// 输入框 · 单行：顶栏 + 单行输入 + 钉底栏；单档满高，跟键盘抬高。
final class InputSingleLineViewController: UIViewController {
    /// 底栏。
    private let bottomBar = PanSheetSafeBottomBar()

    /// 输入框。
    private let field = UITextField()

    /// 上一帧是否键盘抬起。
    private var wasKeyboardLifted = false

    /// 键盘通知。
    private var keyboardTokens: [NSObjectProtocol] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PanSheetPalette.backgroundWhite
        view.accessibilityIdentifier = "debug-sheet-scenario-input-single-content"
        bottomBar.setAccessibilityName("debug-sheet-scenario-input-single-bottom-bar")
        bottomBar.onTap = { [weak self] in
            guard let self else { return }
            self.view.endEditing(true)
            PanSheetPresenter.dismiss(from: self)
        }
        let nav = installNavBar(title: "输入·单行")
        let body = UIView()
        body.backgroundColor = PanSheetPalette.inputBodyFill
        body.accessibilityIdentifier = "debug-sheet-scenario-input-single-body"
        field.placeholder = "单行输入"
        field.borderStyle = .none
        field.backgroundColor = PanSheetPalette.cardOnWhite
        field.layer.cornerRadius = 12
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        field.rightViewMode = .always
        field.font = .systemFont(ofSize: 17)
        field.accessibilityIdentifier = "debug-sheet-scenario-input-single-field"
        view.addSubview(body)
        view.addSubview(bottomBar)
        body.addSubview(field)
        body.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        field.translatesAutoresizingMaskIntoConstraints = false
        let bodyHeight = PanSheetMetrics.bodyVerticalPad * 2 + PanSheetMetrics.textFieldHeight
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.topAnchor.constraint(greaterThanOrEqualTo: body.bottomAnchor),
            body.topAnchor.constraint(equalTo: nav.bottomAnchor),
            body.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            body.heightAnchor.constraint(equalToConstant: bodyHeight),
            field.leadingAnchor.constraint(equalTo: body.leadingAnchor, constant: PanSheetMetrics.pageInset),
            field.trailingAnchor.constraint(equalTo: body.trailingAnchor, constant: -PanSheetMetrics.pageInset),
            field.topAnchor.constraint(equalTo: body.topAnchor, constant: PanSheetMetrics.bodyVerticalPad),
            field.heightAnchor.constraint(equalToConstant: PanSheetMetrics.textFieldHeight),
        ])
        observeKeyboard()
    }

    deinit {
        keyboardTokens.forEach { NotificationCenter.default.removeObserver($0) }
    }

    private var panelHeight: CGFloat {
        let body = PanSheetMetrics.bodyVerticalPad * 2 + PanSheetMetrics.textFieldHeight
        return PanSheetMetrics.navBarHeight + body + bottomBar.fittingHeight()
    }

    private func observeKeyboard() {
        let center = NotificationCenter.default
        let shown = center.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.handleKeyboard(note)
        }
        let hidden = center.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.handleKeyboard(note)
        }
        keyboardTokens = [shown, hidden]
    }

    private func handleKeyboard(_ note: Notification) {
        guard let window = view.window else { return }
        let frame = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
        let converted = window.convert(frame, from: nil)
        let overlap = max(0, window.bounds.maxY - converted.minY)
        let lifted = overlap > 1
        guard lifted != wasKeyboardLifted else { return }
        wasKeyboardLifted = lifted
        bottomBar.isKeyboardLifted = lifted
        let extra = lifted ? overlap : 0
        PanSheetPresenter.updateInputDetent(on: self, panelHeight: panelHeight + extra)
    }
}
