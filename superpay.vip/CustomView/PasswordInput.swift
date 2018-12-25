
import UIKit

class PasswordInput: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       Bundle.main.loadNibNamed("PasswordInput", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        //contentView.layer.borderWidth = 0.4
        //contentView.layer.borderColor = UIColor(red: 255/255, green: 182/255, blue: 0/255, alpha: 1.0).cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("PasswordInput", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
