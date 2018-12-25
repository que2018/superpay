
import Foundation
import XLPagerTabStrip

class HistoryViewController: ButtonBarPagerTabStripViewController {
    
    let graySpotifyColor = UIColor(red: 21/255.0, green: 21/255.0, blue: 24/255.0, alpha: 1.0)
    let darkGraySpotifyColor = UIColor(red: 19/255.0, green: 20/255.0, blue: 20/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = graySpotifyColor
        settings.style.buttonBarItemBackgroundColor = graySpotifyColor
        settings.style.selectedBarBackgroundColor = UIColor(red: 84/255.0, green: 194/255.0, blue: 255/255.0, alpha: 1.0)
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 18)
        settings.style.selectedBarHeight = 5.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        
        settings.style.buttonBarLeftContentInset = 20
        settings.style.buttonBarRightContentInset = 20
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor(red: 138/255.0, green: 138/255.0, blue: 144/255.0, alpha: 1.0)
            newCell?.label.textColor = .white
        }
        
        super.viewDidLoad()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let allTransactionViewController = AllTransactionViewController(style: .plain, itemInfo: IndicatorInfo(title: NSLocalizedString("tab_all_transaction", comment: "")))
        let depositViewController = DepositViewController(style: .plain, itemInfo: IndicatorInfo(title: NSLocalizedString("tab_pay", comment: "")))
        let widthdrawViewController = WidthdrawViewController(style: .plain, itemInfo: IndicatorInfo(title: NSLocalizedString("tab_draw", comment: "")))
        
        return [allTransactionViewController, depositViewController, widthdrawViewController]
    }
}
