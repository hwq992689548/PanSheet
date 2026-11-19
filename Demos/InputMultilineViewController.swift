import UIKit

/// 输入框 · 多行：UITextView 120～240 往上撑开；底栏钉底。
final class InputMultilineViewController: UIViewController {
    /// 底栏。
    private let bottomBar = PanSheetSafeBottomBar()

    /// 多行输入。
    private let textView = UITextView()

    /// 空态占位。
    private let placeholderLabel = UILabel()

    /// body 容器。
    private let body = UIView()

    /// 多行高约束。
    private var textHeightConstraint: NSLayoutConstraint?

    /// 多行当前高度。
    private var currentTextHeight: CGFloat = PanSheetMetrics.textMinHeight

    /// 上一帧是否键盘抬起。
    private var wasKeyboardLifted = false

    /// 当前键盘重叠。
    private var keyboardOverlap: CGFloat = 0

    /// 键盘通知。
    private var keyboardTokens: [NSObjectProtocol] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PanSheetPalette.backgroundWhite
        view.accessibilityIdentifier = "debug-sheet-scenario-input-multi-content"
        bottomBar.setAccessibilityName("debug-sheet-scenario-input-multi-bottom-bar")
        bottomBar.onTap = { [weak self] in
            guard let self else { return }
            self.view.endEditing(true)
            PanSheetPresenter.dismiss(from: self)
        }
        let nav = installNavBar(title: "输入·多行")
        body.backgroundColor = PanSheetPalette.inputBodyFill
        body.accessibilityIdentifier = "debug-sheet-scenario-input-multi-body"
        textView.backgroundColor = PanSheetPalette.cardOnWhite
        textView.font = .systemFont(ofSize: 17)
        textView.textColor = PanSheetPalette.textPrimary
        textView.layer.cornerRadius = 12
        textView.clipsToBounds = true
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.accessibilityIdentifier = "debug-sheet-scenario-input-multi-field"
        placeholderLabel.text = "多行输入（可变高度）"
        placeholderLabel.font = .systemFont(ofSize: 17)
        placeholderLabel.textColor = PanSheetPalette.textTertiary
        placeholderLabel.isUserInteractionEnabled = false
        view.addSubview(body)
        view.addSubview(bottomBar)
        body.addSubview(textView)
        body.addSubview(placeholderLabel)
        body.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        let textHeight = textView.heightAnchor.constraint(equalToConstant: PanSheetMetrics.textMinHeight)
        textHeightConstraint = textHeight
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            body.topAnchor.constraint(equalTo: nav.bottomAnchor),
            body.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            body.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            textView.leadingAnchor.constraint(equalTo: body.leadingAnchor, constant: PanSheetMetrics.pageInset),
            textView.trailingAnchor.constraint(equalTo: body.trailingAnchor, constant: -PanSheetMetrics.pageInset),
            textView.topAnchor.constraint(equalTo: body.topAnchor, constant: PanSheetMetrics.bodyVerticalPad),
            textHeight,
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 12),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor, constant: -12),
        ])
        observeKeyboard()
    }

    deinit {
        keyboardTokens.forEach { NotificationCenter.default.removeObserver($0) }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        relayoutForTextChange()
    }

    private var panelHeight: CGFloat {
        PanSheetMetrics.navBarHeight
            + PanSheetMetrics.bodyVerticalPad * 2
            + currentTextHeight
            + bottomBar.fittingHeight()
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
        keyboardOverlap = lifted ? overlap : 0
        guard lifted != wasKeyboardLifted else {
            syncDetent()
            return
        }
        wasKeyboardLifted = lifted
        bottomBar.isKeyboardLifted = lifted
        syncDetent()
    }

    private func relayoutForTextChange() {
        let width = textView.bounds.width
        guard width > 0 else { return }
        let fitting = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        let next = min(max(PanSheetMetrics.textMinHeight, ceil(fitting.height)), PanSheetMetrics.textMaxHeight)
        let heightChanged = abs(next - currentTextHeight) > 0.5
        if heightChanged {
            currentTextHeight = next
            textHeightConstraint?.constant = next
            textView.isScrollEnabled = next >= PanSheetMetrics.textMaxHeight - 0.5
            syncDetent()
        }
        placeholderLabel.isHidden = !(textView.text ?? "").isEmpty
    }

    private func syncDetent() {
        PanSheetPresenter.updateInputDetent(on: self, panelHeight: panelHeight + keyboardOverlap)
    }
}

extension InputMultilineViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        relayoutForTextChange()
    }
}
