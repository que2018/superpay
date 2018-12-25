
import UIKit

class PasswordViewController: UIViewController {
    
    var passwordInputWidth:CGFloat!
    var passwordInputHeight:CGFloat!
    
    var keyBoardVisible = false
    var passwordInput = PasswordInput()
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
        
        //blur effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //dismiss keyboard when touch
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(dismissInput))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func passwordButtonClicked(button: UIButton) {
        print("password confirm button clicked")
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
            //self.passwordInput.passwordTextField.text = ""
            //self.passwordInput.removeFromSuperview()
            //self.blurEffectView.removeFromSuperview()
        }
    }
}
