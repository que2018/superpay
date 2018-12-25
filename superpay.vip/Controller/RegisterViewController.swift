
import UIKit
import Toaster
import Alamofire

class RegisterViewController: BasicViewController {
    
    @IBOutlet var infoInputArea: UIView!
    @IBOutlet var passwordInputArea: UIView!
    @IBOutlet var addressInputArea: UIView!
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var idNumberTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordConfirmTextField: UITextField!
    @IBOutlet var EINNumberTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    
    @IBOutlet var confirmButton: LoadingButton!
    
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
        infoInputArea.backgroundColor = UIColor.white
        infoInputArea.layer.cornerRadius = 8.0
        infoInputArea.layer.borderColor = UIColor.gray.cgColor
        infoInputArea.layer.borderWidth = 0.7
        infoInputArea.clipsToBounds = true
        
        passwordInputArea.backgroundColor = UIColor.white
        passwordInputArea.layer.cornerRadius = 8.0
        passwordInputArea.layer.borderColor = UIColor.gray.cgColor
        passwordInputArea.layer.borderWidth = 0.7
        passwordInputArea.clipsToBounds = true
        
        addressInputArea.backgroundColor = UIColor.white
        addressInputArea.layer.cornerRadius = 8.0
        addressInputArea.layer.borderColor = UIColor.gray.cgColor
        addressInputArea.layer.borderWidth = 0.7
        addressInputArea.clipsToBounds = true
        
        confirmButton.addTarget(self, action:  #selector(submitRegister(button:)), for: .touchUpInside)
    }
    
    @objc func submitRegister(button: UIButton) {
        self.view.endEditing(true)
        
        let name = self.nameTextField.text!
        let idNumber = self.idNumberTextField.text!
        let phoneNumber = self.phoneNumberTextField.text!
        let email = self.emailTextField.text!
        let password = self.passwordTextField.text!
        let passwordConfirm = self.passwordConfirmTextField.text!
        
        if password == passwordConfirm {
            self.confirmButton.showLoading()

            self.nameTextField.isUserInteractionEnabled = false
            self.idNumberTextField.isUserInteractionEnabled = false
            self.phoneNumberTextField.isUserInteractionEnabled = false
            self.emailTextField.isUserInteractionEnabled = false
            self.passwordTextField.isUserInteractionEnabled = false
            self.passwordConfirmTextField.isUserInteractionEnabled = false
            
            let parameters:[String: String] = [
                "device_sn": CONSTANT.DEVICE_SN_DEFAULT,
                "email": email,
                "id_number": idNumber,
                "name": name,
                "password": password,
                "phone_number": phoneNumber
            ]
            
            let parameterString = CONSTANT.DEVICE_SN_DEFAULT + ":" + email + ":" + idNumber + ":" + name + ":" + password  + ":" + phoneNumber + ":"
            
            let headers = Auth.getPublicAuthHeaders(method: "POST", apiName: "member", parameterString: parameterString)
            
            Alamofire.request(ADDR.REGISTER, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { response in
                self.confirmButton.hideLoading()
            
                self.nameTextField.isUserInteractionEnabled = true
                self.idNumberTextField.isUserInteractionEnabled = true
                self.phoneNumberTextField.isUserInteractionEnabled = true
                self.emailTextField.isUserInteractionEnabled = true
                self.passwordTextField.isUserInteractionEnabled = true
                self.passwordConfirmTextField.isUserInteractionEnabled = true
                
                if let json = response.result.value {
                    let jsonData = json as! [String  : Any]
                    
                    //print(jsonData)
                    
                    let code = jsonData["code"] as! Int
                    
                    if code == 200 {
                        DispatchQueue.main.async {
                            let toast = Toast(text: NSLocalizedString("text_register_success", comment: ""))
                            ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
                            toast.show()
                            
                            self.navigationController?.popViewController(animated: true)
                            self.dismiss(animated: true, completion: nil)                            
                        }
                    } else {
                        let alert = UIAlertController(title: "Alert", message: "register information error", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        else
        {
            let alert = UIAlertController(title: "Alert", message: "passord not the same", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
