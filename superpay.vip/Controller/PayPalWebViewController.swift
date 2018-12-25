
import UIKit

class PayPalWebViewController: UIViewController,  UIWebViewDelegate {
    
    var url: String = ""
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        let url = URL(string: self.url)
        
        print("paypal webview ...")
        print(url)
        
        webView.delegate = self
        webView.loadRequest(URLRequest(url: url!))
    }
    
    func webViewDidFinishLoad(_ webView : UIWebView) {
        activityIndicator.stopAnimating()
    }
}
