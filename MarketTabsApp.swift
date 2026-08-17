import SwiftUI

@main
struct MarketTabsApp: App {
    init() {
        // 全局外观定制：让系统导航栏 / 标签栏配色与现代设计风格统一
        let accent = UIColor(red: 0.00, green: 0.48, blue: 1.00, alpha: 1.0)
        UIView.appearance().tintColor = accent

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithDefaultBackground()
        tabAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.92)
        tabAppearance.shadowColor = UIColor.separator
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        navAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.92)
        navAppearance.shadowColor = UIColor.separator
        navAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 17, weight: .semibold)]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(nil) // 跟随系统深浅色
        }
    }
}
