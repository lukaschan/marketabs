import SwiftUI
import WebKit
import Combine

/// 每个 Tab 独立持有的浏览器状态模型
final class WebViewModel: NSObject, ObservableObject {
    let homeURL: URL
    let webView: WKWebView

    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var isLoading = false
    @Published var estimatedProgress: Double = 0
    @Published var pageTitle: String = ""
    @Published var currentHost: String = ""

    /// 下拉刷新控件（挂在 webView.scrollView 上，仅在页面滚动到顶部时下拉才触发）
    private var refreshControl: UIRefreshControl?

    private var observations: [NSKeyValueObservation] = []
    private var cancellables = Set<AnyCancellable>()

    init(homeURL: URL) {
        self.homeURL = homeURL
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        // 让站点拿到移动端页面
        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()

        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true   // 支持边缘右滑返回上一页
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.scrollView.backgroundColor = .systemBackground

        setupRefreshControl()
        bindObservers()
        loadHome()
    }

    /// 配置下拉刷新：滚动到页面顶部继续下拉即触发重新加载
    private func setupRefreshControl() {
        let control = UIRefreshControl()
        control.tintColor = .systemBlue
        control.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        webView.scrollView.refreshControl = control
        refreshControl = control
    }

    @objc private func refreshTriggered() {
        webView.reload()
    }

    private func endRefreshing() {
        refreshControl?.endRefreshing()
    }

    func loadHome() {
        webView.load(URLRequest(url: homeURL))
    }

    func goBack()   { webView.goBack() }
    func goForward(){ webView.goForward() }
    func reload()   { webView.reload() }

    private func bindObservers() {
        observations = [
            webView.observe(\.estimatedProgress, options: .new) { [weak self] _, change in
                DispatchQueue.main.async { self?.estimatedProgress = change.newValue ?? 0 }
            },
            webView.observe(\.canGoBack, options: .new) { [weak self] _, change in
                DispatchQueue.main.async { self?.canGoBack = change.newValue ?? false }
            },
            webView.observe(\.canGoForward, options: .new) { [weak self] _, change in
                DispatchQueue.main.async { self?.canGoForward = change.newValue ?? false }
            },
            webView.observe(\.title, options: .new) { [weak self] _, change in
                DispatchQueue.main.async {
                    if let t = change.newValue, !t.isEmpty { self?.pageTitle = t }
                }
            },
            webView.observe(\.URL, options: .new) { [weak self] _, change in
                DispatchQueue.main.async {
                    self?.currentHost = change.newValue?.host ?? ""
                }
            }
        ]
    }
}

extension WebViewModel: WKNavigationDelegate {
    // 页面开始加载
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
    }

    // 页面加载完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        endRefreshing()
        estimatedProgress = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            if self?.estimatedProgress == 1.0 { self?.estimatedProgress = 0 }
        }
    }

    // 页面加载失败
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        endRefreshing()
        estimatedProgress = 0
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        endRefreshing()
        estimatedProgress = 0
    }

    // 点击页面内链接：在此处统一放行，即可支持链接点击跳转
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}

/// SwiftUI 包装的 WKWebView
struct WebView: UIViewRepresentable {
    @ObservedObject var model: WebViewModel

    func makeUIView(context: Context) -> WKWebView {
        model.webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
