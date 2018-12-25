
import UIKit

class CardCell: UITableViewCell {

    @IBOutlet var roorView: UIView!
    @IBOutlet var cardImage: UIImageView!
    @IBOutlet var cardNumber: UILabel!
    @IBOutlet var editGroup: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roorView.layer.cornerRadius = 6.0
        roorView.clipsToBounds = true
        
        editGroup.layer.cornerRadius = 6.0
        editGroup.layer.borderColor = UIColor.white.cgColor
        editGroup.layer.borderWidth = 1
        editGroup.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
