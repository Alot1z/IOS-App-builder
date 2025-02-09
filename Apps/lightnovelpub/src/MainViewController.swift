import UIKit
import WebKit
import SafariServices
import SwiftUI

class MainViewController: UIViewController {
    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var refreshControl: UIRefreshControl!
    private var themeObserver: NSKeyValueObservation?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupUI()
        setupNavigationBar()
        setupRefreshControl()
        setupThemeObserver()
        loadInitialURL()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTheme()
    }
    
    // MARK: - Setup
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        
        // Enable modern WebKit features
        if #available(iOS 16.0, *) {
            config.preferences.isElementFullscreenEnabled = true
            config.preferences.isSiteSpecificQuirksModeEnabled = true
            
            if #available(iOS 17.0, *) {
                config.preferences.isInlineMediaPlaybackEnabled = true
                config.preferences.isMediaSourceEnabled = true
            }
        }
        
        // Setup content rules
        let contentController = WKUserContentController()
        let readerScript = """
            function enableReaderMode() {
                document.body.style.backgroundColor = '\(isDarkMode ? "#1a1a1a" : "#ffffff")';
                document.body.style.color = '\(isDarkMode ? "#ffffff" : "#000000")';
                document.querySelector('.chapter-content').style.fontSize = '18px';
                document.querySelector('.chapter-content').style.lineHeight = '1.8';
                document.querySelector('.chapter-content').style.padding = '20px';
                // Hide ads and unnecessary elements
                document.querySelectorAll('.ad, .banner, .sidebar').forEach(e => e.style.display = 'none');
            }
        """
        let script = WKUserScript(source: readerScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(script)
        config.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = "LightNovelPub/1.0"
        
        // Enable modern scrolling behavior
        if #available(iOS 16.0, *) {
            webView.scrollView.isScrollingEnabled = true
            webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        }
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupUI() {
        // Progress view
        progressView = UIProgressView(progressViewStyle: .default)
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    private func setupNavigationBar() {
        title = "LightNovel Pub"
        
        // Setup navigation items
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(showSettings))
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareContent))
        let readerModeButton = UIBarButtonItem(image: UIImage(systemName: "textformat.size"), style: .plain, target: self, action: #selector(toggleReaderMode))
        
        if #available(iOS 16.0, *) {
            // Add modern navigation items
            let menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(showMenu))
            navigationItem.rightBarButtonItems = [menuButton, shareButton, readerModeButton, settingsButton]
            
            // Add search controller
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchBar.placeholder = "Search novels..."
            searchController.searchResultsUpdater = self
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            navigationItem.rightBarButtonItems = [shareButton, readerModeButton, settingsButton]
        }
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
    }
    
    private func setupThemeObserver() {
        themeObserver = UserDefaults.standard.observe(\.bool, forKey: "darkMode") { [weak self] _, _ in
            self?.updateTheme()
        }
    }
    
    // MARK: - Actions
    
    @objc private func refreshPage() {
        webView.reload()
        refreshControl.endRefreshing()
    }
    
    @objc private func showSettings() {
        if #available(iOS 16.0, *) {
            let settingsView = SettingsView()
            let hostingController = UIHostingController(rootView: settingsView)
            hostingController.modalPresentationStyle = .formSheet
            present(hostingController, animated: true)
        } else {
            let alert = UIAlertController(title: "Settings", message: "Settings are only available on iOS 16 and later", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @objc private func shareContent() {
        guard let url = webView.url else { return }
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
    @objc private func toggleReaderMode() {
        webView.evaluateJavaScript("enableReaderMode();")
    }
    
    @available(iOS 16.0, *)
    @objc private func showMenu() {
        let menu = UIMenu(title: "", children: [
            UIAction(title: "Download Chapter", image: UIImage(systemName: "arrow.down.circle")) { [weak self] _ in
                self?.downloadCurrentChapter()
            },
            UIAction(title: "Add to Library", image: UIImage(systemName: "book")) { [weak self] _ in
                self?.addToLibrary()
            },
            UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
                self?.shareContent()
            }
        ])
        
        let menuButton = navigationItem.rightBarButtonItems?.first
        menuButton?.menu = menu
    }
    
    // MARK: - Helper Methods
    
    private var isDarkMode: Bool {
        return UserDefaults.standard.bool(forKey: "darkMode")
    }
    
    private func updateTheme() {
        if #available(iOS 16.0, *) {
            view.window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
        webView.evaluateJavaScript("document.body.style.backgroundColor = '\(isDarkMode ? "#1a1a1a" : "#ffffff")';")
        webView.evaluateJavaScript("document.body.style.color = '\(isDarkMode ? "#ffffff" : "#000000")';")
    }
    
    func loadURL(_ url: URL) {
        webView.load(URLRequest(url: url))
    }
    
    private func loadInitialURL() {
        if let url = URL(string: "https://lightnovelpub.com") {
            loadURL(url)
        }
    }
    
    @available(iOS 16.0, *)
    private func downloadCurrentChapter() {
        // Implement chapter download logic
        let alert = UIAlertController(title: "Download Started", message: "Chapter is being downloaded...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @available(iOS 16.0, *)
    private func addToLibrary() {
        // Implement library addition logic
        let alert = UIAlertController(title: "Added to Library", message: "Novel has been added to your library", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            progressView.progress = Float(webView.estimatedProgress)
            progressView.isHidden = webView.estimatedProgress == 1
        }
    }
}

// MARK: - WKNavigationDelegate

extension MainViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
        title = webView.title
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else { return }
        if let url = URL(string: "https://lightnovelpub.com/search?keyword=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            loadURL(url)
        }
    }
}
