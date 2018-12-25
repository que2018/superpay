
import UIKit

class SideMenu: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var websiteView: UIView!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var helpCenterView: UIView!
    @IBOutlet weak var feedBackView: UIView!
    @IBOutlet weak var logoutView: UIView!
    
    @IBOutlet var logoutTextLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("SideMenu", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("SideMenu", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
