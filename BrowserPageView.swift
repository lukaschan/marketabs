import SwiftUI

/// 单个 Tab 的浏览器页面：顶部导航栏 + 加载进度条 + 网页视图
struct BrowserPageView: View {
    let page: TabPage
    @StateObject private var model: WebViewModel

    init(page: TabPage) {
        self.page = page
        _model = StateObject(wrappedValue: WebViewModel(homeURL: page.url))
    }

    var body: some View {
        NavigationStack {
            WebView(model: model)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(page.title)
                .navigationBarTitleDisplayMode(.inline)
                .overlay(alignment: .top) {
                    // 顶部加载进度条
                    GeometryReader { proxy in
                        LinearProgressIndicator(progress: model.estimatedProgress)
                            .frame(width: proxy.size.width * model.estimatedProgress.clamped(0...1))
                    }
                    .frame(height: 3)
                    .opacity(model.isLoading ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: model.isLoading)
                    .allowsHitTesting(false)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        // 返回上一级
                        Button {
                            model.goBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .disabled(!model.canGoBack)
                        .opacity(model.canGoBack ? 1 : 0.3)
                        .accessibilityLabel("返回上一页")

                        // 前进
                        Button {
                            model.goForward()
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .disabled(!model.canGoForward)
                        .opacity(model.canGoForward ? 1 : 0.3)
                        .accessibilityLabel("前进")
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        // 刷新
                        Button {
                            model.reload()
                        } label: {
                            Image(systemName: model.isLoading ? "xmark" : "arrow.clockwise")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .accessibilityLabel(model.isLoading ? "停止加载" : "刷新")

                        // 分享当前页面
                        ShareLink(item: model.webView.url ?? page.url) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .accessibilityLabel("分享")
                    }
                }
                .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct BrowserPageView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserPageView(page: tabPages[0])
    }
}

/// 自绘的细进度条，宽度随加载进度增长
struct LinearProgressIndicator: View {
    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            Capsule()
                .fill(Color.accentColor)
                .frame(width: proxy.size.width, height: 3)
                .shadow(color: Color.accentColor.opacity(0.4), radius: 1.5, y: 1)
        }
    }
}

extension Comparable {
    func clamped(_ range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
