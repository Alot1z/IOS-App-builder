import UIKit
import WebKit
import SafariServices
import SwiftUI

class MainViewController: UIViewController {
    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var refreshControl: UIRefreshControl!
    private var settingsButton: UIBarButtonItem!
    private var searchController: UISearchController!
    private var currentURL: URL?
    
    private let baseURL = URL(string: "https://lightnovelpub.com")!
    private let userScriptSource = """
        // Custom JavaScript for enhanced functionality
        document.addEventListener('DOMContentLoaded', function() {
            // Remove ads
            document.querySelectorAll('.ad-container').forEach(e => e.remove());
            
            // Enhance reader experience
            document.body.style.fontFamily = '-apple-system, system-ui';
            document.body.style.fontSize = '18px';
            document.body.style.lineHeight = '1.6';
            
            // Add dark mode support
            if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
                document.body.classList.add('dark-mode');
            }
        });
    """
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebView()
        setupSearchController()
        setupRefreshControl()
        setupNavigationBar()
        loadLastURL()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "LightNovelPub"
        
        // Progress view
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        let userScript = WKUserScript(source: userScriptSource,
                                    injectionTime: .atDocumentEnd,
                                    forMainFrameOnly: true)
        config.userContentController.addUserScript(userScript)
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = "LightNovelPub-iOS/1.0"
        
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Observe progress
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search novels..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
    }
    
    private func setupNavigationBar() {
        // Settings button
        settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(showSettings))
        navigationItem.rightBarButtonItem = settingsButton
        
        // Navigation buttons
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                       style: .plain,
                                       target: webView,
                                       action: #selector(webView.goBack))
        let forwardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"),
                                          style: .plain,
                                          target: webView,
                                          action: #selector(webView.goForward))
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(shareURL))
        
        navigationItem.leftBarButtonItems = [backButton, forwardButton]
        navigationItem.rightBarButtonItems = [settingsButton, shareButton]
    }
    
    private func loadLastURL() {
        if let urlString = UserDefaults.standard.string(forKey: "lastURL"),
           let url = URL(string: urlString) {
            currentURL = url
            webView.load(URLRequest(url: url))
        } else {
            currentURL = baseURL
            webView.load(URLRequest(url: baseURL))
        }
    }
    
    // MARK: - Actions
    
    @objc private func refreshWebView() {
        webView.reload()
    }
    
    @objc private func showSettings() {
        let settingsView = SettingsView()
        let hostingController = UIHostingController(rootView: settingsView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    @objc private func shareURL() {
        guard let url = currentURL else { return }
        let activityViewController = UIActivityViewController(activityItems: [url],
                                                            applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
    // MARK: - Public Methods
    
    func loadNovel(url: String) {
        guard let url = URL(string: url) else { return }
        currentURL = url
        webView.load(URLRequest(url: url))
    }
    
    func showUpdatePrompt(url: String) {
        let alert = UIAlertController(title: "Update Available",
                                    message: "A new version of the app is available. Would you like to update?",
                                    preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Update", style: .default) { _ in
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Later", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func saveCurrentState() {
        if let url = currentURL {
            UserDefaults.standard.set(url.absoluteString, forKey: "lastURL")
        }
    }
    
    func refreshContent() {
        webView.reload()
    }
    
    func registerDeviceToken(_ token: String) {
        // Send token to server for push notifications
        // Implementation depends on server API
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            progressView.progress = Float(webView.estimatedProgress)
            progressView.isHidden = webView.estimatedProgress == 1
        }
    }
}

// MARK: - WKNavigationDelegate

extension MainViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshControl.endRefreshing()
        currentURL = webView.url
        title = webView.title
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        refreshControl.endRefreshing()
        showError(error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        // Handle external links
        if !url.host?.contains("lightnovelpub.com") ?? true {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
}

// MARK: - UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let searchURL = baseURL.appendingPathComponent("search").appendingPathComponent(query)
        webView.load(URLRequest(url: searchURL))
        searchBar.resignFirstResponder()
    }
}

// MARK: - Error Handling

extension MainViewController {
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error",
                                    message: error.localizedDescription,
                                    preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.refreshWebView()
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        present(alert, animated: true)
    }
}
