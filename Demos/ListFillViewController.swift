import UIKit

/// 列表 · 场景1：顶栏 + 原生 UITableView 铺满，无底栏。
final class ListFillViewController: UIViewController {
    /// 行复用 id。
    private static let cellId = "debug-sheet-scenario-list-fill-cell"

    /// 原生表。
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PanSheetPalette.backgroundWhite
        view.accessibilityIdentifier = "debug-sheet-scenario-list-fill-content"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = PanSheetPalette.backgroundWhite
        tableView.keyboardDismissMode = .onDrag
        tableView.accessibilityIdentifier = "debug-sheet-scenario-list-fill-table"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellId)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = PanSheetMetrics.listRowHeight
        tableView.estimatedRowHeight = 0
        let nav = installNavBar(title: "场景1·列表铺满")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: nav.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let lift = PanSheetContentRelativeSnaps.resolveLift(in: self)
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: lift, right: 0)
        if tableView.contentInset != inset {
            tableView.contentInset = inset
            tableView.verticalScrollIndicatorInsets = inset
        }
    }
}

extension ListFillViewController: UITableViewDataSource, UITableViewDelegate {
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
        config.secondaryText = "铺满 · 无底栏 · 原生 UITableView"
        config.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        cell.accessibilityIdentifier = "debug-sheet-scenario-list-fill-row-\(indexPath.row + 1)"
        return cell
    }
}
