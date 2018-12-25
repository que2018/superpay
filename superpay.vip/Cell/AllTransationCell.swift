
import UIKit

class AllTransationCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dateTimeLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
