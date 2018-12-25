
import UIKit
import Toaster

class HomeViewController: UIViewController {
    
    var isLogin = false
    var menuVisible = false
    var menuView: SideMenu = SideMenu()

    @IBOutlet var bannerView: UIView!
    
    @IBOutlet weak var quickPayButton: UIButton!
    @IBOutlet weak var financeButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    
    @IBOutlet weak var shotBuyView: UIView!
    @IBOutlet weak var payView: UIView!
    @IBOutlet weak var drawView: UIView!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //bottom item click event
        quickPayButton.addTarget(self, action:  #selector(buttonClicked(button:)), for: .touchUpInside)
        financeButton.addTarget(self, action:  #selector(buttonClicked(button:)), for: .touchUpInside)
        eventButton.addTarget(self, action:  #selector(buttonClicked(button:)), for: .touchUpInside)
        historyButton.addTarget(self, action:  #selector(buttonClicked(button:)), for: .touchUpInside)
        
        //main item click event
        let shotBuyGesture = UITapGestureRecognizer(target: self, action:  #selector(self.shotBuyClick))
        let payGesture = UITapGestureRecognizer(target: self, action:  #selector(self.payClick))
        let drawGesture = UITapGestureRecognizer(target: self, action:  #selector(self.drawClick))
        
        shotBuyView.addGestureRecognizer(shotBuyGesture)
        payView.addGestureRecognizer(payGesture)
        drawView.addGestureRecognizer(drawGesture)
        
        //add side menu
        menuView.frame = CGRect(x:0, y: 0, width: 180, height: self.view.frame.size.height)
        menuView.translatesAutoresizingMaskIntoConstraints = false
        menuView.alpha = 1

        self.view.addSubview(menuView)
        self.view.bringSubview(toFront: menuView)
        
        //swipe to show menu
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(showMenu))
        edgePan.edges = .right
        self.view.addGestureRecognizer(edgePan)
        
        //swipe to hide menu
        let swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,action: #selector(swipeHideMenu))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        //touch to hide menu
        let touchGesture = UITapGestureRecognizer(target: self, action:  #selector(touchHideMenu))
        bannerView.addGestureRecognizer(touchGesture)
        
        //menu position
        let trailingConstraint = NSLayoutConstraint(item: menuView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 180)
        let topConstraint = NSLayoutConstraint(item: menuView, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: menuView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 180)
        let heightConstraint = NSLayoutConstraint(item: menuView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.size.height)
        self.view.addConstraints([trailingConstraint, topConstraint, widthConstraint, heightConstraint])
        
        //menu click
        let accountGesture = UITapGestureRecognizer(target: self, action:  #selector(self.accountClick))
        let websiteGesture = UITapGestureRecognizer(target: self, action:  #selector(self.websiteClick))
        let facebookGesture = UITapGestureRecognizer(target: self, action:  #selector(self.facebookClick))
        let helpCenterGesture = UITapGestureRecognizer(target: self, action:  #selector(self.helpCenterClick))
        let feedBackGesture = UITapGestureRecognizer(target: self, action:  #selector(self.feedBackClick))
        let logoutGesture = UITapGestureRecognizer(target: self, action:  #selector(self.logoutClick))
        
        menuView.accountView.addGestureRecognizer(accountGesture)
        menuView.websiteView.addGestureRecognizer(websiteGesture)
        menuView.facebookView.addGestureRecognizer(facebookGesture)
        menuView.helpCenterView.addGestureRecognizer(helpCenterGesture)
        menuView.feedBackView.addGestureRecognizer(feedBackGesture)
        menuView.logoutView.addGestureRecognizer(logoutGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //hide menu anyway
        menuView.frame.origin.x = self.view.frame.size.width
        menuVisible = false
        
        //get login status
        isLogin = UserDefaults.standard.bool(forKey: "is_login")
        
        if isLogin   {
            menuView.logoutTextLabel.text = NSLocalizedString("text_logout", comment: "")
        } else {
            menuView.logoutTextLabel.text = NSLocalizedString("text_login", comment: "")
        }
    }
    
    @objc func buttonClicked(button: UIButton) {
        if button == quickPayButton {
            performSegue(withIdentifier: "segue_quickpay", sender: self)
        }
        
        if button == financeButton {
            performSegue(withIdentifier: "segue_finance", sender: self)
        }
        
        if button == eventButton {
            performSegue(withIdentifier: "segue_event", sender: self)
        }
        
        if button == historyButton {
            performSegue(withIdentifier: "segue_history", sender: self)
        }
    }
    
    //shot buy click
    @objc func shotBuyClick(sender : UITapGestureRecognizer) {
        if !self.menuVisible {
            if isLogin {
                performSegue(withIdentifier: "segue_shot_buy", sender: self)
            } else {
                performSegue(withIdentifier: "segue_login", sender: self)
            }
        } else {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
                self.menuView.frame.origin.x = self.view.frame.size.width
                self.menuVisible = false
            })
        }
    }
    
    //pay click
    @objc func payClick(sender : UITapGestureRecognizer) {
        if !self.menuVisible {
            if isLogin {
                performSegue(withIdentifier: "segue_pay", sender: self)
            } else {
                performSegue(withIdentifier: "segue_login", sender: self)
            }
        } else {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
                self.menuView.frame.origin.x = self.view.frame.size.width
                self.menuVisible = false
            })
        }
    }
    
    //draw click
    @objc func drawClick(sender : UITapGestureRecognizer) {
        if !self.menuVisible {
            if isLogin {
                performSegue(withIdentifier: "segue_draw", sender: self)
            } else {
                performSegue(withIdentifier: "segue_login", sender: self)
            }
        } else {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
                self.menuView.frame.origin.x = self.view.frame.size.width
                self.menuVisible = false
            })
        }
    }
    
    //account click
    @objc func accountClick(sender : UITapGestureRecognizer) {
        if isLogin {
            performSegue(withIdentifier: "segue_account", sender: self)
        } else {
            performSegue(withIdentifier: "segue_login", sender: self)
        }
    }
    
    //website click
    @objc func websiteClick(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "segue_website", sender: self)
    }
    
    //facebook click
    @objc func facebookClick(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "segue_facebook", sender: self)
    }
    
    //help center click
    @objc func helpCenterClick(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "segue_helpcenter", sender: self)
    }
    
    //feedback click
    @objc func feedBackClick(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "segue_feedback", sender: self)
    }
    
    //logout click
    @objc func logoutClick(sender : UITapGestureRecognizer) {
        if isLogin {
            UserDefaults.standard.set(false, forKey: "is_login")
            UserDefaults.standard.set("", forKey: "password")
            UserDefaults.standard.set("", forKey: "auth_key")
            UserDefaults.standard.set("", forKey: "default_card_number")
            UserDefaults.standard.set("", forKey: "brc_card_number")
            UserDefaults.standard.set("", forKey: "spc_card_number")
            UserDefaults.standard.set("", forKey: "id")
            UserDefaults.standard.set("", forKey: "id_code")
            UserDefaults.standard.set("", forKey: "member_id")
            UserDefaults.standard.set("", forKey: "member_type")
            UserDefaults.standard.set("", forKey: "user_id")
            
            UserDefaults.standard.set("", forKey: "address")
            UserDefaults.standard.set("", forKey: "day_pay_limit")
            UserDefaults.standard.set("", forKey: "email")
            UserDefaults.standard.set("", forKey: "name")
            UserDefaults.standard.set("", forKey: "pay_threshold")
            UserDefaults.standard.set("", forKey: "social_id")
            UserDefaults.standard.set("", forKey: "taiwang_id")
            UserDefaults.standard.set("", forKey: "vat")
            UserDefaults.standard.set("", forKey: "web_buy_limit")
            
            UserDefaults.standard.synchronize()
            
            let toast = Toast(text: NSLocalizedString("text_logout_success", comment: ""))
            ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
            toast.show()
        }
        
        performSegue(withIdentifier: "segue_login", sender: self)
    }
    
    //show menu
    @IBAction func menuClick(_ sender: Any) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
            if self.menuVisible {
                self.menuView.frame.origin.x = self.view.frame.size.width
                self.menuVisible = false
            } else {
                self.menuView.frame.origin.x = self.view.frame.size.width - 180
                self.menuVisible = true
            }
       })
    }
    
    //show menu
    @objc func showMenu(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            if self.menuVisible == false {
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
                    self.menuView.frame.origin.x = self.view.frame.size.width - 180
                    //self.menuView.frame.origin.x = self.view.frame.size.width
                    self.menuVisible = true
                })
            }
        }
    }
    
    //swipe hide menu
    @objc func swipeHideMenu(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            if self.menuVisible == true {
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
                    self.menuView.frame.origin.x = self.view.frame.size.width
                    self.menuVisible = false
                })
            }
        }
    }
    
    //touch hide menu
    @objc func touchHideMenu(sender : UITapGestureRecognizer) {
        if self.menuVisible == true {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
                self.menuView.frame.origin.x = self.view.frame.size.width
                self.menuVisible = false
            })
        }
    }
}

