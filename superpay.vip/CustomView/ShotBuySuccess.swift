
import UIKit

class ShotBuySuccess: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var receiverLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var unicodeLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var returnHomeButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("ShotBuySuccess", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        contentView.layer.borderWidth = 0.4
        contentView.layer.borderColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0).cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("ShotBuySuccess", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
