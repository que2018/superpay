
import UIKit
import Toaster
import Alamofire

class FinanceViewController: PopoutViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cardTableView: UITableView!
    
    var cardIndex = 0
    
    var cards = [Card]()
    var giftCard = GiftCard()
    var brcCard = BRCCard()
    var spcCard = SPCCard()
    var depositCard = DepositCard()
    
    let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        cardTableView.dataSource = self
        cardTableView.delegate = self
        
        cardTableView.backgroundColor = .clear
        cardTableView.showsVerticalScrollIndicator = false
        cardTableView.separatorStyle  = UITableViewCellSeparatorStyle.none
        cardTableView.register(UINib(nibName: "CardCell", bundle: Bundle.main), forCellReuseIdentifier: "CardCell")
        cardTableView.register(UINib(nibName: "DepositCardCell", bundle: Bundle.main), forCellReuseIdentifier: "DepositCardCell")
        cardTableView.register(UINib(nibName: "GiftCardCell", bundle: Bundle.main), forCellReuseIdentifier: "GiftCardCell")
        cardTableView.register(UINib(nibName: "BRCCardCell", bundle: Bundle.main), forCellReuseIdentifier: "BRCCardCell")
        cardTableView.register(UINib(nibName: "SPCCardCell", bundle: Bundle.main), forCellReuseIdentifier: "SPCCardCell")
        
        let addCardButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCardClick))
        self.navigationItem.setRightBarButtonItems([addCardButton], animated: true)
        
        payPalInput.confirmButton.addTarget(self, action:  #selector(confirmDeposit(button:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "is_login") {
            loadData()
        }
    }
    
    func loadData() {
        cards.removeAll()
        
        self.loadingIndicator.center = self.view.center
        self.loadingIndicator.hidesWhenStopped = true
        self.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(self.loadingIndicator)
        self.loadingIndicator.startAnimating()
        
        let  headers = Auth.getPrivateAuthHeaders(method: "GET", apiName: "card", parameterString: "")

        Alamofire.request(ADDR.CARD, headers: headers) .responseJSON { response in
            self.loadingIndicator.stopAnimating()

            if let json = response.result.value {
                let jsonData = json as! [String  : Any]                
                let code = jsonData["code"] as! Int
                
                //get card success
                if code == 200 {
                    let cardsJson = jsonData["object"] as? NSArray
                    
                    if cardsJson != nil {
                        self.validateCards(cardsJson: cardsJson)
                    }
                    
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                        self.cardTableView.reloadData()
                        self.cardTableView.isHidden = false
                    }                
                } else {
                    let toast = Toast(text: NSLocalizedString("text_logout_card_notice", comment: ""), duration: Delay.long)
                    ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
                    toast.show()
                }
            }
        }
    }
    
    func validateCards(cardsJson: NSArray!) {
        var cardsServer = [Card]()
        
        for cardJson in cardsJson {
            let cardData = cardJson as! [String : Any]
            let publisherId = cardData["publisher_id"] as! Int
            let type = cardData["type"] as! Int
            let id = cardData["id"] as! String
            let hashedNumber = cardData["hashed_number"] as! String
            let balance = cardData["balance"] as! String
            
            if (publisherId == 1000) && (type == 0) {
                self.depositCard.balance = Double(balance)!
                //store default card id
                UserDefaults.standard.set(hashedNumber, forKey: "default_card_hashed_number")
                UserDefaults.standard.synchronize()
            } else if (publisherId == 1000) && (type == 1)  {
                self.giftCard.balance = Double(balance)!
            } else if (publisherId == 2001) && (type == 0)  {
                //store brc card id
                UserDefaults.standard.set(hashedNumber, forKey: "brc_card_hashed_number")
                UserDefaults.standard.synchronize()
                self.brcCard.balance = Double(balance)!
            }  else if (publisherId == 2002) && (type == 0)  {
                //store spc card id
                UserDefaults.standard.set(hashedNumber, forKey: "spc_card_hashed_number")
                UserDefaults.standard.synchronize()
                self.spcCard.balance = Double(balance)!
            }  else {
                let expDateMonth = cardData["exp_date_month"] as! Int
                let expDateYear = cardData["exp_date_year"] as! Int
                let type = cardData["type"] as! Int
                
                let card = Card()
                card.balance = Double(balance)!
                card.expDateMonth = expDateMonth
                card.expDateYear = expDateYear
                card.hashedNumber = hashedNumber
                card.id = id
                card.type = type
                cardsServer.append(card)
            }
        }
        
        let cardsLocal = CardTable.getCards()
        
        if cardsLocal != nil {
            for cardLocal in cardsLocal {
                var find = false
                var cardServerTarget = Card()
                let hashedNumber = cardLocal.hashedNumber
                
                for  cardServer in cardsServer {
                    if cardServer.hashedNumber == hashedNumber {
                        find = true
                        cardServerTarget = cardServer
                        break
                    }
                }
                
                if find {
                    let card = cardServerTarget
                    card.localId = cardLocal.localId
                    card.cardNumber = cardLocal.cardNumber
                    self.cards.append(card)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count + 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.modelSize == "l" {
            return 85
        } else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let depositCardCell = tableView.dequeueReusableCell(withIdentifier: "DepositCardCell", for: indexPath) as! DepositCardCell
            depositCardCell.balanceLabel.text = "$" + String(format: "%.2f", depositCard.balance)
            depositCardCell.backgroundColor = .clear
            depositCardCell.selectionStyle = .none
            
            let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(self.showDeposit))
            depositCardCell.editGroup.addGestureRecognizer(tapGesture)
            
            return depositCardCell
            
        } else if indexPath.row == 1 {
            let giftCardCell = tableView.dequeueReusableCell(withIdentifier: "GiftCardCell", for: indexPath) as! GiftCardCell
            giftCardCell.balanceLabel.text = "$" + String(format: "%.2f", giftCard.balance)
            giftCardCell.backgroundColor = .clear
            giftCardCell.selectionStyle = .none
            return giftCardCell
    
        } else if indexPath.row == 2 {
            let brcCardCell = tableView.dequeueReusableCell(withIdentifier: "BRCCardCell", for: indexPath) as! BRCCardCell
            brcCardCell.balanceLabel.text = String(format: "%.2f", brcCard.balance)
            brcCardCell.backgroundColor = .clear
            brcCardCell.selectionStyle = .none
            return brcCardCell
        
        } else if indexPath.row == 3 {
            let spcCardCell = tableView.dequeueReusableCell(withIdentifier: "SPCCardCell", for: indexPath) as! SPCCardCell
            spcCardCell.balanceLabel.text = String(format: "%.2f", spcCard.balance)
            spcCardCell.backgroundColor = .clear
            spcCardCell.selectionStyle = .none
            return spcCardCell
            
        } else {
            let cardCell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as! CardCell
            cardCell.backgroundColor = .clear
            cardCell.selectionStyle = .none
            cardCell.editGroup.tag = indexPath.row
            
            let cardRow = indexPath.row - 4
            
            let cardNumber = cards[cardRow].cardNumber
            let cardNumberMask = cardNumber.suffix(4)
            cardCell.cardNumber.text = "" + cardNumberMask
        
            if cards[cardRow].type == 2 {
                let image: UIImage = UIImage(named: "visa")!
                cardCell.cardImage.image = image
            }
        
            if cards[cardRow].type == 3 {
                let image: UIImage = UIImage(named: "master")!
                cardCell.cardImage.image = image
            }
        
            if cards[cardRow].type == 4 {
                let image: UIImage = UIImage(named: "jbc")!
                cardCell.cardImage.image = image
            }
            
            if cards[cardRow].type == 5 {
                let image: UIImage = UIImage(named: "ucard")!
                cardCell.cardImage.image = image
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(self.editCardClick))
            cardCell.editGroup.addGestureRecognizer(tapGesture)
            
             return cardCell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_card_edit" {
            if let cardEditViewController = segue.destination as? CardEditViewController {
                let card = self.cards[cardIndex]
                cardEditViewController.card = card
            }
        }
    }
    
    @objc func addCardClick(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "segue_card_add", sender: self)
    }
    
    @objc func editCardClick(sender : UITapGestureRecognizer) {
        let editGroup = sender.view!
        self.cardIndex = editGroup.tag - 4
        performSegue(withIdentifier: "segue_card_edit", sender: self)
    }
    
    @objc func showDeposit(sender : UITapGestureRecognizer) {
        if UserDefaults.standard.bool(forKey: "is_login") {
            let screenSzie = UIScreen.main.bounds
            let screenWidth = screenSzie.width
            let screenHeight = screenSzie.height
            let width = screenWidth * 0.6
            let height = screenHeight * 0.2
            payPalInput.alpha = 1
            
            self.view.addSubview(blurEffectView)
            self.view.addSubview(payPalInput)
            self.view.bringSubview(toFront: payPalInput)
        
            let widthConstraint = NSLayoutConstraint(item: payPalInput, attribute: .width, relatedBy: .equal,toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width)
            let heightConstraint = NSLayoutConstraint(item: payPalInput, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height)
            let xConstraint = NSLayoutConstraint(item: payPalInput, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
            let yConstraint = NSLayoutConstraint(item: payPalInput, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 20)
            self.view.addConstraints([xConstraint, yConstraint, widthConstraint, heightConstraint])
            
            self.payPalInput.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                self.payPalInput.transform = CGAffineTransform.identity
            }, completion: nil)
        } else {
            let toast = Toast(text: NSLocalizedString("text_login_deposit_notice", comment: ""), duration: Delay.short)
            ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
            toast.show()
        }
    }
    
    @objc func confirmDeposit(button: UIButton) {
        self.payPalInput.confirmButton.showLoading()
        
        let parameters:[String: Any] = [
            "card_number_hash": UserDefaults.standard.string(forKey: "default_card_number")!,
            "amount": 100,
            "currency_code": "USD"
        ]
        
        var parameterString  = UserDefaults.standard.string(forKey: "default_card_number")! + ":"
        parameterString += "100:"
        parameterString +=  "USD:"
        
        let headers = Auth.getPrivateAuthHeaders(method: "POST", apiName: "deposit", parameterString: parameterString)
        
        Alamofire.request(ADDR.DEPOSIT, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { response in
            self.payPalInput.confirmButton.hideLoading()
            self.payPalInput.removeFromSuperview()
            self.blurEffectView.removeFromSuperview()

            if let json = response.result.value {
                let jsonData = json as! [String  : Any]
                let code = jsonData["code"] as! Int
                
                if code == 200 {
                    let object = jsonData["object"] as! [String  : String]
                    let payPalUrl = object["url"] as! String
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let payPalWebViewController = storyBoard.instantiateViewController(withIdentifier: "paypal_webview_controller") as! PayPalWebViewController
                    payPalWebViewController.url = payPalUrl
                    self.navigationController?.pushViewController(payPalWebViewController, animated: true)
                }
            }
        }
    }
}

