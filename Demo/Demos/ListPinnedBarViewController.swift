import PanSheet
import UIKit

/// 列表 · 场景3：原生表贴栏顶；底栏钉 content 底；表 inset 为 0。
final class ListPinnedBarViewController: UIViewController {
    /// 行复用 id。
    private static let cellId = "debug-sheet-scenario-list-pinned-cell"

    /// 原生表。
    private let tableView = UITableView(frame: .zero, style: .plain)

    /// 钉在 content 底的底栏。
    private let bottomBar = PanSheetSafeBottomBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PanSheetPalette.backgroundWhite
        view.accessibilityIdentifier = "debug-sheet-scenario-list-pinned-content"
        bottomBar.setAccessibilityName("debug-sheet-scenario-list-pinned-bottom-bar")
        bottomBar.onTap = { [weak self] in
            guard let self else { return }
            PanSheetPresenter.dismiss(from: self)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = PanSheetPalette.backgroundWhite
        tableView.keyboardDismissMode = .onDrag
        tableView.accessibilityIdentifier = "debug-sheet-scenario-list-pinned-table"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellId)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = PanSheetMetrics.listRowHeight
        tableView.estimatedRowHeight = 0
        let nav = installNavBar(title: "场景3·钉底栏")
        view.addSubview(tableView)
        view.addSubview(bottomBar)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: nav.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let lift = PanSheetContentRelativeSnaps.resolveLift(in: self)
        if abs((bottomBar.safeBottomOverride ?? -1) - lift) > 0.5 {
            bottomBar.safeBottomOverride = lift
        }
        if tableView.contentInset != .zero {
            tableView.contentInset = .zero
            tableView.verticalScrollIndicatorInsets = .zero
        }
    }
}

extension ListPinnedBarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        PanSheetMetrics.listFillRowCount
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        PanSheetMetrics.listRowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellId, for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = "列表项 \(indexPath.row + 1)"
        config.secondaryText = "钉底栏 · 栏不动 · 原生 UITableView"
        config.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        cell.accessibilityIdentifier = "debug-sheet-scenario-list-pinned-row-\(indexPath.row + 1)"
        return cell
    }
}
