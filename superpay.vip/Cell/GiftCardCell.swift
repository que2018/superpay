
import UIKit

class GiftCardCell: UITableViewCell {

    @IBOutlet var rootView: UIView!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var editGroup: TouchUIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rootView.layer.cornerRadius = 6.0
        rootView.clipsToBounds = true
        
        editGroup.layer.cornerRadius = 6.0
        editGroup.layer.borderColor = UIColor.white.cgColor
        editGroup.layer.borderWidth = 1
        editGroup.clipsToBounds = true
        editGroup.backgroundColorTouched = UIColor(red: 186/255, green: 14/255, blue: 71/255, alpha: 1.0)
        editGroup.backgroundColorUntouched = UIColor(red: 246/255, green: 54/255, blue: 119/255, alpha: 1.0)
    }
}
