import PanSheet
import UIKit

/// 首页：对照源 `DebugSheetScenariosViewController` 的入口列表。
final class HomeListViewController: UIViewController {
    /// 分组表。
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    /// 分组数据。
    private let groups = DemoSceneGroup.allCases

    /// 是否已按启动参数弹出过。
    private var didAutoPresent = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = DemoScene.home.title
        view.backgroundColor = PanSheetPalette.backgroundGray
        view.accessibilityIdentifier = DemoScene.home.accessibilityIdentifier
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = PanSheetPalette.backgroundGray
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "scene")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let hint = makeHint()
        tableView.tableHeaderView = hint
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let header = tableView.tableHeaderView else { return }
        let width = tableView.bounds.width
        let size = header.systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        if abs(header.frame.height - size.height) > 0.5 {
            header.frame.size = CGSize(width: width, height: size.height)
            tableView.tableHeaderView = header
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didAutoPresent else { return }
        if DemoScene.shouldRunTour() {
            didAutoPresent = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
                self?.runTour(at: 0)
            }
            return
        }
        guard let scene = DemoScene.fromLaunchArguments(), scene != .home else { return }
        didAutoPresent = true
        scene.present(from: self, animated: false)
    }

    /// 录制用：选中对应行 → 带动画打开 → 停一下 → 关掉 → 下一个。
    private func runTour(at index: Int) {
        let scenes = DemoScene.tourScenes
        guard index < scenes.count else { return }
        let scene = scenes[index]
        if let path = indexPath(for: scene) {
            tableView.selectRow(at: path, animated: true, scrollPosition: .middle)
        }
        scene.present(from: self, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.45) { [weak self] in
            guard let self else { return }
            self.dismiss(animated: true) {
                if let path = self.indexPath(for: scene) {
                    self.tableView.deselectRow(at: path, animated: true)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) { [weak self] in
                    self?.runTour(at: index + 1)
                }
            }
        }
    }

    /// 场景在首页表里的位置。
    private func indexPath(for scene: DemoScene) -> IndexPath? {
        for (section, group) in groups.enumerated() {
            if let row = group.scenes.firstIndex(of: scene) {
                return IndexPath(row: row, section: section)
            }
        }
        return nil
    }

    /// 顶部说明。
    private func makeHint() -> UIView {
        let container = UIView()
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13)
        label.textColor = PanSheetPalette.textTertiary
        label.text = "对照 LaserpeckerOS「开发调试 → Sheet 场景」。本 Demo 只用系统 UISheetPresentationController 复现当时存在的用法，不含激光业务。"
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
        ])
        return container
    }
}

extension HomeListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        groups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups[section].scenes.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        groups[section].rawValue
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let scene = groups[indexPath.section].scenes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "scene", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = scene.title
        config.secondaryText = scene.subtitle
        config.textProperties.font = .systemFont(ofSize: 17, weight: .medium)
        config.secondaryTextProperties.font = .systemFont(ofSize: 13)
        config.secondaryTextProperties.color = PanSheetPalette.textSecondary
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        cell.accessibilityIdentifier = scene.accessibilityIdentifier
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let scene = groups[indexPath.section].scenes[indexPath.row]
        scene.present(from: self, animated: true)
    }
}
