
import UIKit
import Toaster

class PopoutViewController: UIViewController {
    
    var passwordInputWidth:CGFloat!
    var passwordInputHeight:CGFloat!
    
    var keyBoardVisible = false
    var passwordInput = PasswordInput()
    var resetPassword = ResetPassword()
    var payPalInput = PayPalInput()
    var blurEffectView:UIVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //password input
        let screenSzie = UIScreen.main.bounds
        let screenWidth = screenSzie.width
        let screenHeight = screenSzie.height
        passwordInputWidth = screenWidth * 0.8
        passwordInputHeight = screenHeight * 0.32
        passwordInput.frame = CGRect(x:0, y: 0, width: passwordInputWidth, height: passwordInputHeight)
        passwordInput.translatesAutoresizingMaskIntoConstraints = false
        passwordInput.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        passwordInput.alpha = 0
        passwordInput.confirmButton.addTarget(self, action:  #selector(passwordButtonClicked(button:)), for: .touchUpInside)

        //resetpassword
        let resetPasswordWidth = screenWidth * 0.8
        let resetPasswordHeight = screenHeight * 0.5
        resetPassword.frame = CGRect(x:0, y: 0, width: resetPasswordWidth, height: resetPasswordHeight)
        resetPassword.translatesAutoresizingMaskIntoConstraints = false
        resetPassword.alpha = 1
        
        //paypal input
        let payPalInputWidth = screenWidth * 0.7
        let payPalInputHeight = screenHeight * 0.3
        payPalInput.frame = CGRect(x:0, y: 0, width: payPalInputWidth, height: payPalInputHeight)
        payPalInput.translatesAutoresizingMaskIntoConstraints = false
        payPalInput.alpha = 1
        
        //blur effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //dismiss keyboard when touch
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(dismissInput))
        tap.cancelsTouchesInView = false
        blurEffectView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func passwordButtonClicked(button: UIButton) {
        //print("password confirm button clicked")
    }
    
    @objc func keyboardWillAppear() {
        self.keyBoardVisible = true
    }
    
    @objc func keyboardWillDisappear() {
        self.keyBoardVisible = false
    }
    
    @objc func dismissInput() {
        if(self.keyBoardVisible) {
            view.endEditing(true)
        } else {
            self.passwordInput.passwordTextField.text = ""
            self.resetPassword.emailTextField.text = ""
            self.payPalInput.amountTextField.text = ""
            self.passwordInput.removeFromSuperview()
            self.resetPassword.removeFromSuperview()
            self.payPalInput.removeFromSuperview()
            self.blurEffectView.removeFromSuperview()
        }
    }
    
    func redirectLogin() {
        let toast = Toast(text: NSLocalizedString("text_session_expire_login", comment: ""))
        ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
        toast.show()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "login_controller") as! LoginViewController
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
}

