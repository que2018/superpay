
import UIKit

class BannerCell: UITableViewCell {

    var isSet = false
    
    @IBOutlet var bannerView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
