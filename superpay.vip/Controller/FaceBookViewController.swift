
import UIKit

class FaceBookViewController: UIViewController,  UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        let url = URL(string: ADDR.FACEBOOK)
        
        webView.delegate = self
        webView.loadRequest(URLRequest(url: url!))
    }
    
    func webViewDidFinishLoad(_ webView : UIWebView) {
        activityIndicator.stopAnimating()
    }
}
