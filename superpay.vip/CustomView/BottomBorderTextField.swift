
import UIKit

class BottomBorderTextField: UITextField {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setBottomBorder(borderColor: UIColor)  {
        let border = CALayer()
        let width = CGFloat(0.8)
        border.borderColor = borderColor.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
