import SwiftUI
import AuthenticationServices

struct StravaAuthView: View {
    @ObservedObject var stravaService: StravaService
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            if let url = stravaService.getAuthorizationURL() {
                WebView(url: url, stravaService: stravaService, isPresented: $isPresented)
            } else {
                Text("Error creating auth URL")
            }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    @ObservedObject var stravaService: StravaService
    @Binding var isPresented: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let url = navigationAction.request.url,
               url.scheme == "activityroaster" {
                
                // Extract the code from URL
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let code = components.queryItems?.first(where: { $0.name == "code" })?.value {
                    
                    Task {
                        try? await parent.stravaService.exchangeToken(code: code)
                        await MainActor.run {
                            parent.isPresented = false
                        }
                    }
                }
                
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
    }
}

import WebKit
