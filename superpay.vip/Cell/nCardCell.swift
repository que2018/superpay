
import UIKit

class nCardCell: UITableViewCell {

    @IBOutlet var cardImage: UIImageView!
    @IBOutlet var cardNumberLabel: UILabel!
    @IBOutlet var rootView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        rootView.layer.cornerRadius = 6.0
        rootView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
