
import UIKit

class BRCCardCell: UITableViewCell {

    @IBOutlet var rootView: UIView!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var editGroup: TouchUIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        rootView.layer.cornerRadius = 6.0
        rootView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
