
import UIKit

class ShotBuyConfirm: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var cardView: UIView!
    @IBOutlet var cardImage: UIImageView!
    @IBOutlet var cardBalanceLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var receiverLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var unicodeLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var returnButton: UIButton!
    @IBOutlet var confirmButton: LoadingButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("ShotBuyConfirm", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("ShotBuyConfirm", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
