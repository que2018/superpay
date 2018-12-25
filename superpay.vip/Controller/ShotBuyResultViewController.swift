
import UIKit
import Alamofire

class ShotBuyResultViewController: PopoutViewController,  UITableViewDelegate, UITableViewDataSource {

    var codeType = ""
    var goodsInfo = ""
    var amount = ""
    var remitterNumber = ""
    var cardNumberHashPayeer = ""
    var cardIndex = 0

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var receiverTextField: BottomBorderTextField!
    @IBOutlet var addressTextField: BottomBorderTextField!
    @IBOutlet var unicodeTextField: BottomBorderTextField!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var minButton: UIButton!
    @IBOutlet var tableView: UITableView!

    var cards = [Card]()
    var giftCard = GiftCard()
    var depositCard = DepositCard()
    var brcCard = BRCCard()
    
    var shotBuyConfirm: ShotBuyConfirm = ShotBuyConfirm()
    var shotBuySuccess: ShotBuySuccess = ShotBuySuccess()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle  = UITableViewCellSeparatorStyle.none
        tableView.register(UINib(nibName: "nDepositCardCell", bundle: Bundle.main), forCellReuseIdentifier: "nDepositCardCell")
        tableView.register(UINib(nibName: "nGiftCardCell", bundle: Bundle.main), forCellReuseIdentifier: "nGiftCardCell")
        tableView.register(UINib(nibName: "nCardCell", bundle: Bundle.main), forCellReuseIdentifier: "nCardCell")

        titleLabel.text = goodsInfo
        priceLabel.text = "$" + amount
        totalLabel.text = "$" + amount
        receiverTextField.text =  UserDefaults.standard.string(forKey: "name")!
        
        receiverTextField.setBottomBorder(borderColor: UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0))
        addressTextField.setBottomBorder(borderColor: UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0))
        unicodeTextField.setBottomBorder(borderColor: UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0))

        //go to register
        addButton.addTarget(self, action:  #selector(addQuantity(button:)), for: .touchUpInside)
        minButton.addTarget(self, action:  #selector(minQuantity(button:)), for: .touchUpInside)
        
        loadData()
    }
    
    @objc func addQuantity(button: UIButton) {
        let quantity = Int(self.quantityTextField.text!)!
        let newQuantity = quantity + 1
        let total = newQuantity * Int(amount)!
        self.amountTextField.text = String(newQuantity)
        self.totalLabel.text = "$" + String(total)
    }
    
    @objc func minQuantity(button: UIButton) {
        let quantity = Int(self.quantityTextField.text!)!
        
        if quantity > 1 {
            let newQuantity = quantity - 1
            let total = newQuantity * Int(amount)!
            self.amountTextField.text = String(newQuantity)
            self.totalLabel.text = "$" + String(total)
        }
    }
    
    func loadData() {
        cards.removeAll()
        
        let  headers = Auth.getPrivateAuthHeaders(method: "GET", apiName: "card", parameterString: "")
        
        Alamofire.request(ADDR.CARD, headers: headers) .responseJSON { response in
            if let json = response.result.value {
                let jsonData = json as! [String  : Any]
                let cardsJson = jsonData["object"] as? NSArray
                
                if cardsJson != nil {
                    var cardsServer = [Card]()
                    
                    for cardJson in cardsJson! {
                        let cardData = cardJson as! [String : Any]
                        let publisherId = cardData["publisher_id"] as! Int
                        let type = cardData["type"] as! Int
                        let id = cardData["id"] as! String
                        let hashedNumber = cardData["hashed_number"] as! String
                        let balance = cardData["balance"] as! String
                        
                        if (publisherId == 1000) && (type == 0) {
                            self.depositCard.balance = Double(balance)!
                            self.depositCard.hashedNumber = hashedNumber
                            //store default card id
                            UserDefaults.standard.set(hashedNumber, forKey: "default_card_hashed_number")
                            UserDefaults.standard.synchronize()
                        } else if (publisherId == 1000) && (type == 1)  {
                            self.giftCard.balance = Double(balance)!
                            self.giftCard.hashedNumber = hashedNumber
                        } else {
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
                                card.cardNumber = cardLocal.cardNumber
                                self.cards.append(card)
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count + 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let screenSzie = UIScreen.main.bounds
        let screenWidth = screenSzie.width
        let screenHeight = screenSzie.height
        let width = screenWidth * 0.9
        let height = screenHeight * 0.8
        shotBuyConfirm.frame = CGRect(x:0, y: 0, width: width, height: height)
        shotBuyConfirm.translatesAutoresizingMaskIntoConstraints = false
        shotBuyConfirm.alpha = 1
        
        shotBuyConfirm.titleLabel.text = self.titleLabel.text
        shotBuyConfirm.receiverLabel.text = self.receiverTextField.text
        shotBuyConfirm.priceLabel.text = self.priceLabel.text
        shotBuyConfirm.quantityLabel.text = self.quantityTextField.text
        shotBuyConfirm.addressLabel.text = self.addressTextField.text
        shotBuyConfirm.unicodeLabel.text = self.unicodeTextField.text
        shotBuyConfirm.totalLabel.text = self.totalLabel.text
        
        shotBuyConfirm.returnButton.addTarget(self, action:  #selector(back(button:)), for: .touchUpInside)
        shotBuyConfirm.confirmButton.addTarget(self, action:  #selector(confirm(button:)), for: .touchUpInside)

         if indexPath.row == 0 {
            self.cardNumberHashPayeer = depositCard.hashedNumber
            shotBuyConfirm.cardView.backgroundColor = UIColor(red: 255/255, green: 182/255, blue: 0/255, alpha: 1.0)
            shotBuyConfirm.cardImage.image = UIImage(named:"dollar")
            shotBuyConfirm.cardBalanceLabel.text = "$" + String(format: "%.2f", depositCard.balance)
         } else if indexPath.row == 1 {
            self.cardNumberHashPayeer = giftCard.hashedNumber
            shotBuyConfirm.cardView.backgroundColor = UIColor(red: 246/255, green: 54/255, blue: 119/255, alpha: 1.0)
            shotBuyConfirm.cardImage.image = UIImage(named:"gift")
            shotBuyConfirm.cardBalanceLabel.text = "$" + String(format: "%.2f", giftCard.balance)
         } else {
            shotBuyConfirm.cardView.backgroundColor = UIColor(red: 0/255, green: 78/255, blue: 153/255, alpha: 1.0)
            let cardRow = indexPath.row - 2
            self.cardNumberHashPayeer = cards[cardRow].hashedNumber
            let cardNumber = cards[cardRow].cardNumber
            let cardNumberMask = cardNumber.suffix(4)
             shotBuyConfirm.cardBalanceLabel.text = "" + cardNumberMask
            
            if cards[cardRow].type == 2 {
                shotBuyConfirm.cardImage.image = UIImage(named: "visa")!
            }
            
            if cards[cardRow].type == 3 {
                shotBuyConfirm.cardImage.image = UIImage(named: "master")!
            }
            
            if cards[cardRow].type == 4 {
                shotBuyConfirm.cardImage.image = UIImage(named: "jbc")!
            }
            
            if cards[cardRow].type == 5 {
                shotBuyConfirm.cardImage.image = UIImage(named: "ucard")!
            }
        }
        
        self.view.addSubview(blurEffectView)
        self.view.addSubview(shotBuyConfirm)
        self.view.bringSubview(toFront: shotBuyConfirm)
        
        self.shotBuyConfirm.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.shotBuyConfirm.transform = CGAffineTransform.identity
        }, completion: nil)
        
        let widthConstraint = NSLayoutConstraint(item: shotBuyConfirm, attribute: .width, relatedBy: .equal,toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width)
        let heightConstraint = NSLayoutConstraint(item: shotBuyConfirm, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height)
        let xConstraint = NSLayoutConstraint(item: shotBuyConfirm, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: shotBuyConfirm, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 20)
        self.view.addConstraints([xConstraint, yConstraint, widthConstraint, heightConstraint])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let nDepositCardCell = tableView.dequeueReusableCell(withIdentifier: "nDepositCardCell", for: indexPath) as! nDepositCardCell
            nDepositCardCell.balanceLabel.text = "$" + String(format: "%.2f", depositCard.balance)
            nDepositCardCell.backgroundColor = .clear
            nDepositCardCell.selectionStyle = .none
            return nDepositCardCell
            
        } else if indexPath.row == 1 {
            let nGiftCardCell = tableView.dequeueReusableCell(withIdentifier: "nGiftCardCell", for: indexPath) as! nGiftCardCell
            nGiftCardCell.balanceLabel.text = "$" + String(format: "%.2f", giftCard.balance)
            nGiftCardCell.backgroundColor = .clear
            nGiftCardCell.selectionStyle = .none
            return nGiftCardCell
        
        } else {
            let nCardCell = tableView.dequeueReusableCell(withIdentifier: "nCardCell", for: indexPath) as! nCardCell
            nCardCell.backgroundColor = .clear
            nCardCell.selectionStyle = .none
            
            let cardRow = indexPath.row - 2
            let cardNumber = cards[cardRow].cardNumber
            let cardNumberMask = cardNumber.suffix(4)
            nCardCell.cardNumberLabel.text = "" + cardNumberMask
            
            if cards[cardRow].type == 2 {
                let image: UIImage = UIImage(named: "visa")!
                nCardCell.cardImage.image = image
            }
            
            if cards[cardRow].type == 3 {
                let image: UIImage = UIImage(named: "master")!
                nCardCell.cardImage.image = image
            }
            
            if cards[cardRow].type == 4 {
                let image: UIImage = UIImage(named: "jbc")!
                nCardCell.cardImage.image = image
            }
            
            if cards[cardRow].type == 5 {
                let image: UIImage = UIImage(named: "ucard")!
                nCardCell.cardImage.image = image
            }
            
            return nCardCell
        }
    }
    
    @objc func back(button: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            self.shotBuyConfirm.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.shotBuyConfirm.alpha = 0
        }) { (success:Bool) in
            self.blurEffectView.removeFromSuperview()
            self.shotBuyConfirm.removeFromSuperview()
        }
    }
    
    @objc func confirm(button: LoadingButton) {
        self.view.endEditing(true)
        
        button.showLoading()
        
        self.quantityTextField.isUserInteractionEnabled = false
        self.receiverTextField.isUserInteractionEnabled = false
        self.addressTextField.isUserInteractionEnabled = false
        self.unicodeTextField.isUserInteractionEnabled = false

        let quantity = self.quantityTextField.text!
        var totalPay = self.totalLabel.text!
        totalPay = totalPay.replacingOccurrences(of: "$", with: "")
        let receiver = self.receiverTextField.text!
        //let address = self.addressTextField.text!
        //let unicode = self.unicodeTextField.text!

        let parameters:[String: String] = [
            "total_pay": totalPay,
            "quantity": quantity,
            "transmit_name": "type1",
            "card_number_hash_payeer": self.cardNumberHashPayeer,
            "receiver_name": receiver,
            "phone_number_remitter": self.remitterNumber,
            "info": self.goodsInfo
        ]
        
        var parameterString  = self.cardNumberHashPayeer + ":"
        parameterString += self.goodsInfo + ":"
        parameterString += remitterNumber + ":"
        parameterString += quantity + ":"
        parameterString += receiver + ":"
        parameterString += totalPay + ":"
        parameterString += "type1:"

        let headers = Auth.getPrivateAuthHeaders(method: "POST", apiName: "transition", parameterString: parameterString)
        
        Alamofire.request(ADDR.TRANSITION, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { response in
            button.hideLoading()
            
            self.quantityTextField.isUserInteractionEnabled = false
            self.receiverTextField.isUserInteractionEnabled = false
            self.addressTextField.isUserInteractionEnabled = false
            self.unicodeTextField.isUserInteractionEnabled = false
            
            if let json = response.result.value {
                let jsonData = json as! [String  : Any]
                let code = jsonData["code"] as! Int
                
                if code == 200 {
                    self.shotBuyConfirm.removeFromSuperview()
                        
                    let screenSzie = UIScreen.main.bounds
                    let screenWidth = screenSzie.width
                    let screenHeight = screenSzie.height
                    let width = screenWidth * 0.9
                    let height = screenHeight * 0.8
                    self.shotBuySuccess.frame = CGRect(x:0, y: 0, width: width, height: height)
                    self.shotBuySuccess.translatesAutoresizingMaskIntoConstraints = false
                    self.shotBuySuccess.alpha = 1
                    self.shotBuySuccess.returnHomeButton.addTarget(self, action:  #selector(self.returnHome(button:)), for: .touchUpInside)

                    self.shotBuySuccess.titleLabel.text =  self.titleLabel.text
                    self.shotBuySuccess.priceLabel.text =  self.priceLabel.text
                    self.shotBuySuccess.quantityLabel.text =  self.quantityTextField.text
                    self.shotBuySuccess.receiverLabel.text =  self.receiverTextField.text
                    self.shotBuySuccess.addressLabel.text =  self.addressTextField.text
                    self.shotBuySuccess.unicodeLabel.text =  self.unicodeTextField.text
                    self.shotBuySuccess.totalLabel.text =  self.totalLabel.text

                    self.view.addSubview(self.blurEffectView)
                    self.view.addSubview(self.shotBuySuccess)
                    self.view.bringSubview(toFront: self.shotBuySuccess)
                    
                    let widthConstraint = NSLayoutConstraint(item: self.shotBuySuccess, attribute: .width, relatedBy: .equal,toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width)
                    let heightConstraint = NSLayoutConstraint(item: self.shotBuySuccess, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height)
                    let xConstraint = NSLayoutConstraint(item: self.shotBuySuccess, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
                    let yConstraint = NSLayoutConstraint(item: self.shotBuySuccess, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 20)
                    self.view.addConstraints([xConstraint, yConstraint, widthConstraint, heightConstraint])
                    
                    self.shotBuySuccess.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)

                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                        self.shotBuySuccess.transform = CGAffineTransform.identity
                    }, completion: nil)
                } else {
                    self.blurEffectView.removeFromSuperview()
                    self.shotBuyConfirm.removeFromSuperview()
                    
                    let detail = jsonData["detail"] as! String
                    let message = NSLocalizedString(detail.lowercased(), comment: "")
                    let alert = UIAlertController(title: NSLocalizedString("text_alert", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("button_ok", comment: ""), style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func returnHome(button: UIButton) {
        var navigationArray = self.navigationController?.viewControllers
        navigationArray!.remove(at: 1)
        
        self.navigationController?.viewControllers = navigationArray!
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}
