
import UIKit

class DepositCardCell: UITableViewCell {

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
        editGroup.backgroundColorTouched = UIColor(red: 188/255, green: 138/255, blue: 11/255, alpha: 1.0)
        editGroup.backgroundColorUntouched = UIColor(red: 255/255, green: 182/255, blue: 0/255, alpha: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
