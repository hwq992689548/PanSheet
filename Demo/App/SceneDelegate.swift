import PanSheet
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let home = HomeListViewController()
        let nav = UINavigationController(rootViewController: home)
        nav.navigationBar.prefersLargeTitles = false
        window.rootViewController = nav
        window.backgroundColor = PanSheetPalette.backgroundGray
        window.makeKeyAndVisible()
        self.window = window
    }
}
