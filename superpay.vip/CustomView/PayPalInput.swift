
import UIKit
import Alamofire

class PayPalInput: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var confirmButton: LoadingButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("PayPalInput", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("PayPalInput", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]        
    }
}

