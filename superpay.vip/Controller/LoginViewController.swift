
import UIKit
import Toaster
import Alamofire

class LoginViewController: PopoutViewController {
    
    @IBOutlet weak var userInputView: UIView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: LoadingButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet var passwordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up background
        let bgImageView = UIImageView(frame: view.bounds)
        bgImageView.contentMode =  UIViewContentMode.scaleAspectFill
        bgImageView.clipsToBounds = true
        bgImageView.center = view.center
        bgImageView.image = UIImage(named: "bg_member_login")
        self.view.addSubview(bgImageView)
        self.view.sendSubview(toBack: bgImageView)
        
        //set up input
        userInputView.backgroundColor = UIColor.white
        userInputView.layer.cornerRadius = 8.0
        userInputView.layer.borderColor = UIColor.gray.cgColor
        userInputView.layer.borderWidth = 0.7
        userInputView.clipsToBounds = true
        
        phoneNumberTextField.borderStyle = .none
        phoneNumberTextField.layer.backgroundColor = UIColor.white.cgColor
        phoneNumberTextField.layer.masksToBounds = false
        phoneNumberTextField.layer.shadowColor = UIColor.gray.cgColor
        phoneNumberTextField.layer.shadowOffset = CGSize(width: 0.0, height: 0.3)
        phoneNumberTextField.layer.shadowOpacity = 1.0
        phoneNumberTextField.layer.shadowRadius = 0.0
        
        //login
        loginButton.addTarget(self, action:  #selector(submitLogin(button:)), for: .touchUpInside)
        
        //register
        registerButton.addTarget(self, action:  #selector(goToRegister(button:)), for: .touchUpInside)
        
        //forget password
        passwordButton.addTarget(self, action:  #selector(resetPassword(button:)), for: .touchUpInside)
    }
    
    @objc func submitLogin(button: UIButton) {
        self.view.endEditing(true)
        
        let phoneNumber = self.phoneNumberTextField.text!
        let password = self.passwordTextField.text!
        
        if (phoneNumber == "") || (password == "") {
            let alert = UIAlertController(title: NSLocalizedString("text_alert", comment: ""), message: NSLocalizedString("error_phone_number_or_password_empty", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("button_ok", comment: ""), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            self.loginButton.showLoading()
            
            self.phoneNumberTextField.isUserInteractionEnabled = false
            self.passwordTextField.isUserInteractionEnabled = false
            
            let parameters:[String: String] = [
                "password": password,
                "phone_number": phoneNumber,
                "device_sn": CONSTANT.DEVICE_SN_DEFAULT,
            ]
            
            let parameterString =  CONSTANT.DEVICE_SN_DEFAULT + ":" + password + ":" + phoneNumber + ":"
            let headers = Auth.getPublicAuthHeaders(method: "POST", apiName: "login", parameterString: parameterString)
            
            Alamofire.request(ADDR.LOGIN, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { response in
                self.loginButton.hideLoading()

                self.phoneNumberTextField.isUserInteractionEnabled = true
                self.passwordTextField.isUserInteractionEnabled = true
                
                if let json = response.result.value {
                    let jsonData = json as! [String  : Any]
                    
                    //print(jsonData)
                    
                    let code = jsonData["code"] as! Int
                    
                    if code == 200 {
                        let objectJson = jsonData["object"] as! [String  : Any]
                        let authKey = objectJson["auth_key"] as! String
                        let defaultCardNumber = objectJson["default_card_number"] as! String
                        let id = objectJson["id"] as! String
                        let idCode = objectJson["id_code"]
                        let memberId = objectJson["memberId"]
                        let memberType = objectJson["memberType"]
                        let userId = objectJson["userId"]
                        
                        UserDefaults.standard.set(true, forKey: "is_login")
                        UserDefaults.standard.set(password, forKey: "password")
                        UserDefaults.standard.set(authKey, forKey: "auth_key")
                        UserDefaults.standard.set(defaultCardNumber, forKey: "default_card_number")
                        UserDefaults.standard.set(id, forKey: "id")
                        UserDefaults.standard.set(idCode, forKey: "id_code")
                        UserDefaults.standard.set(memberId, forKey: "member_id")
                        UserDefaults.standard.set(memberType, forKey: "member_type")
                        UserDefaults.standard.set(userId, forKey: "user_id")
                        UserDefaults.standard.synchronize()
                        
                        //get extra user information
                        let headers = Auth.getPrivateAuthHeaders(method: "GET", apiName: "member", parameterString: "")
                        
                        Alamofire.request(ADDR.MEMBER, headers: headers) .responseJSON { response in
                            if let json = response.result.value {
                                let jsonData = json as! [String  : Any]
                                let objectData = jsonData["object"] as!  [String  : Any]
                                let address = objectData["address"] as? String
                                let dayPayLimit = objectData["day_pay_limit"] as? String
                                let email = objectData["email"] as? String
                                let name = objectData["name"] as? String
                                let payThreshold = objectData["pay_threshold"] as? String
                                let socialId = objectData["social_id"] as? String
                                let taiwanId = objectData["taiwan_id"] as? String
                                let vat = objectData["vat"] as? String
                                let webBuyLimit = objectData["web_buy_limit"] as? String
                                
                                address != nil ? UserDefaults.standard.set(address, forKey: "address") : UserDefaults.standard.set("", forKey: "address")
                                dayPayLimit != nil ? UserDefaults.standard.set(dayPayLimit, forKey: "day_pay_limit") : UserDefaults.standard.set("", forKey: "day_pay_limit")
                                email != nil ? UserDefaults.standard.set(email, forKey: "email") : UserDefaults.standard.set("", forKey: "email")
                                name != nil ? UserDefaults.standard.set(name, forKey: "name") : UserDefaults.standard.set("", forKey: "name")
                                payThreshold != nil ? UserDefaults.standard.set(payThreshold, forKey: "pay_threshold") : UserDefaults.standard.set("", forKey: "pay_threshold")
                                socialId != nil ? UserDefaults.standard.set(socialId, forKey: "social_id") : UserDefaults.standard.set("", forKey: "social_id")
                                taiwanId != nil ? UserDefaults.standard.set(taiwanId, forKey: "taiwan_id") : UserDefaults.standard.set("", forKey: "taiwan_id")
                                vat != nil ? UserDefaults.standard.set(vat, forKey: "vat") : UserDefaults.standard.set("", forKey: "vat")
                                webBuyLimit != nil ? UserDefaults.standard.set(webBuyLimit, forKey: "web_buy_limit") : UserDefaults.standard.set("", forKey: "web_buy_limit")
                                
                                UserDefaults.standard.synchronize()
                            }
                        }
                        
                        //redirect to main view
                        DispatchQueue.main.async {
                            let toast = Toast(text: NSLocalizedString("text_login_success", comment: ""), duration: Delay.short)
                            ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
                            toast.show()
                            
                            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                            let navigationController = storyBoard.instantiateViewController(withIdentifier: "nav_controller") as! UINavigationController
                            self.present(navigationController, animated:true, completion:nil)
                        }
                    } else {
                        var message = ""
                        
                        if code == 204 { message = NSLocalizedString("error_user_not_exist", comment: "") }
                        
                        let alert = UIAlertController(title: NSLocalizedString("text_alert", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("button_ok", comment: ""), style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @objc func goToRegister(button: UIButton) {
        performSegue(withIdentifier: "segue_register", sender: self)
    }
    
    @objc func resetPassword(button: UIButton) {
        self.view.addSubview(blurEffectView)
        self.view.addSubview(resetPassword)
        self.view.bringSubview(toFront: resetPassword)
        
        let screenSzie = UIScreen.main.bounds
        let screenWidth = screenSzie.width
        let screenHeight = screenSzie.height
        let width = screenWidth * 0.8
        let height = screenHeight * 0.5
        
        let widthConstraint = NSLayoutConstraint(item: resetPassword, attribute: .width, relatedBy: .equal,toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width)
        let heightConstraint = NSLayoutConstraint(item: resetPassword, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height)
        let xConstraint = NSLayoutConstraint(item: resetPassword, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: resetPassword, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 20)
        self.view.addConstraints([xConstraint, yConstraint, widthConstraint, heightConstraint])
        
        self.resetPassword.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.resetPassword.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

