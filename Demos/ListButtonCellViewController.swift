import UIKit

/// 列表 · 场景2：原生表末行按钮 Cell 跟手滚，不用 SafeBottomBar。
final class ListButtonCellViewController: UIViewController {
    /// 行复用 id。
    private static let cellId = "debug-sheet-scenario-list-scroll-bar-cell"

    /// 原生表。
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PanSheetPalette.backgroundWhite
        view.accessibilityIdentifier = "debug-sheet-scenario-list-scroll-bar-content"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = PanSheetPalette.backgroundWhite
        tableView.keyboardDismissMode = .onDrag
        tableView.accessibilityIdentifier = "debug-sheet-scenario-list-scroll-bar-table"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellId)
        tableView.register(ListButtonCell.self, forCellReuseIdentifier: ListButtonCell.reuseId)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = PanSheetMetrics.listRowHeight
        tableView.estimatedRowHeight = 0
        let nav = installNavBar(title: "场景2·按钮Cell")
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

extension ListButtonCellViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        PanSheetMetrics.listButtonRowCount + 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= PanSheetMetrics.listButtonRowCount {
            return PanSheetMetrics.listButtonCellHeight
        }
        return PanSheetMetrics.listRowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= PanSheetMetrics.listButtonRowCount {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ListButtonCell.reuseId,
                for: indexPath
            )
            let buttonCell = cell as? ListButtonCell ?? ListButtonCell(style: .default, reuseIdentifier: ListButtonCell.reuseId)
            buttonCell.accessibilityIdentifier = "debug-sheet-scenario-list-scroll-bar-action"
            buttonCell.onTap = { [weak self] in
                guard let self else { return }
                PanSheetPresenter.dismiss(from: self)
            }
            return buttonCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellId, for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = "列表项 \(indexPath.row + 1)"
        config.secondaryText = "末行是按钮 Cell · 跟手滚"
        config.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        cell.accessibilityIdentifier = "debug-sheet-scenario-list-scroll-bar-row-\(indexPath.row + 1)"
        return cell
    }
}
