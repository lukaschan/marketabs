import SwiftUI

/// Tab 页面定义
struct TabPage: Identifiable, Hashable {
    let id: String
    let title: String
    let url: URL
    let icon: String          // SF Symbols 名称
    let iconFilled: String    // 选中态 SF Symbols 名称
    let subtitle: String      // 侧边栏副标题
}

let tabPages: [TabPage] = [
    TabPage(
        id: "marketgrep",
        title: "行情",
        url: URL(string: "https://lite.marketgrep.com")!,
        icon: "chart.line.uptrend.xyaxis",   // iOS 15+ 可用
        iconFilled: "chart.line.uptrend.xyaxis",
        subtitle: "lite.marketgrep.com"
    ),
    TabPage(
        id: "dollarliquidity",
        title: "美元流动性",
        url: URL(string: "https://dollarliquidity.com")!,
        icon: "dollarsign.circle",
        iconFilled: "dollarsign.circle.fill",
        subtitle: "dollarliquidity.com"
    ),
    TabPage(
        id: "historyofmarket",
        title: "市场历史",
        url: URL(string: "https://historyofmarket.com")!,
        icon: "book.closed",
        iconFilled: "book.closed.fill",
        subtitle: "historyofmarket.com"
    ),
]

struct ContentView: View {
    // iPad 横屏 / 大屏为 regular，iPhone 为 compact
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selection: String = tabPages[0].id

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                SidebarLayout(selection: $selection)
            } else {
                TabLayout(selection: $selection)
            }
        }
    }
}

// MARK: - iPhone 布局：底部标签栏

struct TabLayout: View {
    @Binding var selection: String

    var body: some View {
        TabView(selection: $selection) {
            ForEach(tabPages) { page in
                BrowserPageView(page: page)
                    .tabItem {
                        Label(page.title, systemImage: selection == page.id ? page.iconFilled : page.icon)
                    }
                    .tag(page.id)
            }
        }
    }
}

// MARK: - iPad 布局：左侧边栏 + 内容区

struct SidebarLayout: View {
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 0) {
            Sidebar(selection: $selection)
                .frame(width: 248)
                .background(Color(uiColor: .secondarySystemGroupedBackground))

            Divider()
                .ignoresSafeArea()

            // 内容区：所有页面常驻 ZStack，切换仅改变可见性，
            // 保证与 TabView 一致的"各页面状态独立保留"体验
            ZStack {
                ForEach(tabPages) { page in
                    BrowserPageView(page: page)
                        .opacity(selection == page.id ? 1 : 0)
                        .allowsHitTesting(selection == page.id)
                        .accessibilityHidden(selection != page.id)
                }
            }
        }
    }
}

/// iPad 侧边栏：应用标题 + 导航项列表 + 底部域名说明
struct Sidebar: View {
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 侧边栏头部
            HStack(spacing: 10) {
                Image(systemName: "circle.hexagongrid.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Color.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text("市场速览")
                        .font(.system(size: 17, weight: .bold))
                    Text("MarketTabs")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 18)

            // 导航项
            VStack(spacing: 4) {
                ForEach(tabPages) { page in
                    SidebarItem(page: page, isSelected: selection == page.id) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selection = page.id
                        }
                    }
                }
            }
            .padding(.horizontal, 12)

            Spacer()

            // 底部说明
            VStack(alignment: .leading, spacing: 6) {
                Rectangle()
                    .fill(Color.primary.opacity(0.06))
                    .frame(height: 1)
                ForEach(tabPages) { page in
                    if selection == page.id {
                        Text("当前来源：\(page.subtitle)")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
            .animation(.easeInOut(duration: 0.15), value: selection)
        }
    }
}

struct SidebarItem: View {
    let page: TabPage
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? page.iconFilled : page.icon)
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: 26)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)

                VStack(alignment: .leading, spacing: 1) {
                    Text(page.title)
                        .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                    Text(page.subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
            )
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
