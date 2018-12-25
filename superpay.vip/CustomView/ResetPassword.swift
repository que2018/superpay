
import UIKit
import Toaster
import Alamofire

class ResetPassword: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var confirmButton: LoadingButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("ResetPassword", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        contentView.layer.borderWidth = 0.4
        contentView.layer.borderColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0).cgColor
        
        //login
        confirmButton.addTarget(self, action:  #selector(confirmReset(button:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("ResetPassword", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    @objc func confirmReset(button: UIButton) {
        let email = self.emailTextField.text!
        
        if email == "" {
            let alert = UIAlertController(title: NSLocalizedString("text_alert", comment: ""), message: NSLocalizedString("error_email_empty", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("button_ok", comment: ""), style: UIAlertActionStyle.default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        else
        {
            self.confirmButton.showLoading()
            self.emailTextField.isUserInteractionEnabled = false
        
            let parameters:[String: String] = [
                "email": email
            ]
        
            let parameterString =  email + ":"
            let headers = Auth.getPrivateAuthHeaders(method: "POST", apiName: "renew_password", parameterString: parameterString)
        
            Alamofire.request(ADDR.PASSWORD, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { response in
                self.confirmButton.hideLoading()
                self.emailTextField.isUserInteractionEnabled = true
                self.removeFromSuperview()
                
                if let json = response.result.value {
                    let jsonData = json as! [String  : Any]
                    //print(jsonData)
                    
                    let code = jsonData["code"] as! Int
                    
                    if code == 200 {
                        let toast = Toast(text: NSLocalizedString("text_email_sent", comment: ""))
                        ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
                        toast.show()
                    } else {
                        let toast = Toast(text: NSLocalizedString("error_mail_sent", comment: ""))
                        ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
                        toast.show()
                    }
                }
            }
        }
    }
}

