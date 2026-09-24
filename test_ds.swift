import WebKit
import Cocoa

class Delegate: NSObject, WKNavigationDelegate {
    var done = false
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Success!")
        done = true
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Failed: \(error)")
        done = true
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse {
            print("Status code: \(response.statusCode)")
        }
        decisionHandler(.allow)
    }
}

let app = NSApplication.shared
let delegate = Delegate()
let webView = WKWebView()
webView.navigationDelegate = delegate
webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
let req = URLRequest(url: URL(string: "https://chat.deepseek.com")!)
webView.load(req)

let start = Date()
while !delegate.done && Date().timeIntervalSince(start) < 10 {
    RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.1))
}
if !delegate.done {
    print("Timeout")
}
