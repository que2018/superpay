
import UIKit
import Toaster
import Alamofire

class AccountViewController: BasicViewController {

    @IBOutlet var infoInputArea: UIView!
    @IBOutlet var passwordInputArea: UIView!
    @IBOutlet var addressInputArea: UIView!
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var idNumberTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordConfirmTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var EINNumberTextField: UITextField!
    
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
        
        //set up edit information
        nameTextField.text =  UserDefaults.standard.string(forKey: "name")!
        idNumberTextField.text =  UserDefaults.standard.string(forKey: "taiwan_id")!
        phoneNumberTextField.text =  UserDefaults.standard.string(forKey: "user_id")!
        emailTextField.text =  UserDefaults.standard.string(forKey: "email")!
        addressTextField.text =  UserDefaults.standard.string(forKey: "address")!

        //submit button action
        confirmButton.addTarget(self, action:  #selector(submitEdit(button:)), for: .touchUpInside)
    }
    
    @objc func submitEdit(button: UIButton) {
        self.confirmButton.showLoading()
        
        self.view.endEditing(true)
        
        self.phoneNumberTextField.isUserInteractionEnabled = false
        self.passwordTextField.isUserInteractionEnabled = false
        self.confirmButton.showLoading()
        
        let name = self.nameTextField.text!
        let phoneNumber = self.phoneNumberTextField.text!
        let email = self.emailTextField.text!
        let taiwanId = self.idNumberTextField.text!

        let parameters:[String: String] = [
            "device_sn":  CONSTANT.DEVICE_SN_DEFAULT,
            "name": name,
            "phone_number": phoneNumber,
            "email": email,
            "taiwan_id": taiwanId
        ]
        
        let url = ADDR.MEMBER + "/" + String(Int(NSDate().timeIntervalSince1970 * 1000))
        let parameterString =  CONSTANT.DEVICE_SN_DEFAULT + ":" + name + ":" + phoneNumber + ":" + email + ":" + taiwanId + ":"
        let  headers = Auth.getPrivateAuthHeaders(method: "PUT", apiName: "member", parameterString: parameterString)
                
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            self.confirmButton.hideLoading()
            
            self.nameTextField.isUserInteractionEnabled = true
            self.phoneNumberTextField.isUserInteractionEnabled = true
            self.emailTextField.isUserInteractionEnabled = true
            self.idNumberTextField.isUserInteractionEnabled = true
            
            if let json = response.result.value {
                let jsonData = json as! [String  : Any]
                let code = jsonData["code"] as! Int
                
                if code == 200 {
                    UserDefaults.standard.set(name, forKey: "name")
                    UserDefaults.standard.set(phoneNumber, forKey: "phone_number")
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(taiwanId, forKey: "taiwan_id")
                    UserDefaults.standard.synchronize()

                    let toast = Toast(text: "edit success")
                    ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
                    toast.show()
                }
            }
        }
    }
}
