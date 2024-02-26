//
//  SceneDelegate.swift
//  ChuckNorrisJokes
//
//  Created by Ilya Maenkov on 22.02.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let launchScreenViewController = LaunchScreenVC()
        
        window.rootViewController = launchScreenViewController
        
        window.makeKeyAndVisible()
        self.window = window
        self.window?.overrideUserInterfaceStyle = .light
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showMainApp()
        }
    }
    
    //MARK: - Private
    
    private func showMainApp() {
        window?.rootViewController = createTabBarController()
    }
    
    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        DatabaseService.shared.tabBarController = tabBarController
        
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .white
        
        setTabBarItemColors(appearance.stackedLayoutAppearance)
        setTabBarItemColors(appearance.inlineLayoutAppearance)
        setTabBarItemColors(appearance.compactInlineLayoutAppearance)
        
        setTabBarBadgeAppearance(appearance.stackedLayoutAppearance)
        setTabBarBadgeAppearance(appearance.inlineLayoutAppearance)
        setTabBarBadgeAppearance(appearance.compactInlineLayoutAppearance)
        
        tabBarController.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
        tabBarController.tabBar.isTranslucent = false
        
        tabBarController.viewControllers = (0...2)
            .map { index in
                let viewController: UIViewController
                let imageName: String
                let title: String
                
                switch index {
                case 0:
                    viewController = LoadJokeVC()
                    imageName = "smiley.fill"
                    title = "New Joke"
                case 1:
                    viewController = JokeListVC(category: nil, isTabBarSelected: true)
                    imageName = "list.bullet.circle"
                    title = "Jokes"
                case 2:
                    viewController = JokeCategoriesVC()
                    imageName = "theatermasks.circle"
                    title = "Categories"
                default:
                    fatalError("Invalid index")
                }
                
                viewController.tabBarItem.image = UIImage(systemName: imageName)
                viewController.title = title
                
                return UINavigationController(rootViewController: viewController)
            }
        return tabBarController
    }
    
    
    private func setTabBarItemColors(_ itemAppearance: UITabBarItemAppearance) {
        itemAppearance.normal.iconColor = .systemGray
        itemAppearance.normal.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.systemGray,
            NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default
        ]
        
        itemAppearance.selected.iconColor = .black
        itemAppearance.selected.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default
        ]
        
    }
    
    private func setTabBarBadgeAppearance(_ itemAppearance: UITabBarItemAppearance) {
        itemAppearance.normal.badgeBackgroundColor = .systemRed
        itemAppearance.normal.badgeTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }
}
