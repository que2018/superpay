
import UIKit
import Toaster
import Alamofire

class PayViewController: PasswordViewController,  UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var receiverIDButton: UIButton!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var receiverIDTextField: UITextField!
    @IBOutlet var receiverIDView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var message = ""
    var hashedNumber = ""
    var amount = ""
    var idCode = ""
    
    var cards = [Card]()
    var giftCard = GiftCard()
    var depositCard = DepositCard()
    var brcCard = BRCCard()
    var spcCard = SPCCard()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        amountTextField.delegate = self
        receiverIDTextField.delegate = self

        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle  = UITableViewCellSeparatorStyle.none
        tableView.register(UINib(nibName: "nDepositCardCell", bundle: Bundle.main), forCellReuseIdentifier: "nDepositCardCell")
        tableView.register(UINib(nibName: "nGiftCardCell", bundle: Bundle.main), forCellReuseIdentifier: "nGiftCardCell")
        tableView.register(UINib(nibName: "nCardCell", bundle: Bundle.main), forCellReuseIdentifier: "nCardCell")
        tableView.register(UINib(nibName: "nBRCCardCell", bundle: Bundle.main), forCellReuseIdentifier: "nBRCCardCell")
        tableView.register(UINib(nibName: "nSPCCardCell", bundle: Bundle.main), forCellReuseIdentifier: "nSPCCardCell")
        
        //reveal id event
        receiverIDButton.addTarget(self, action:  #selector(toggleReceiverID(button:)), for: .touchUpInside)
    
        loadData()
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
                        } else if (publisherId == 2001) && (type == 0)  {
                            self.brcCard.balance = Double(balance)!
                            self.brcCard.hashedNumber = hashedNumber
                        } else if (publisherId == 2002) && (type == 0)  {
                            self.spcCard.balance = Double(balance)!
                            self.spcCard.hashedNumber = hashedNumber
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
                    self.tableView.isHidden = false
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  amountTextField.text == "" {
            let alert = UIAlertController(title: "Alert", message: "amount can not be empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let amount = amountTextField.text!
            
            if indexPath.row == 0 {
                hashedNumber = depositCard.hashedNumber
                message = "There will be $" + amount + " charge when scanning this code"
            } else if indexPath.row == 1 {
                hashedNumber = giftCard.hashedNumber
                message = "There will be $" + amount + " charge when scanning this code"
            } else if indexPath.row == 2 {
                hashedNumber = brcCard.hashedNumber
                message = "There will be " + amount + " brc unit charge when scanning this code"
            } else if indexPath.row == 3 {
                hashedNumber = spcCard.hashedNumber
                message = "There will be " + amount + " spc unit charge when scanning this code"
            }  else {
                hashedNumber = cards[indexPath.row].hashedNumber
                message = "There will be $" + amount + " charge when scanning this code"
            }
            
            self.view.addSubview(blurEffectView)
            self.view.addSubview(passwordInput)
            self.view.bringSubview(toFront: passwordInput)
            
            let widthConstraint = NSLayoutConstraint(item: passwordInput, attribute: .width, relatedBy: .equal,toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.passwordInputWidth)
            let heightConstraint = NSLayoutConstraint(item: passwordInput, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.passwordInputHeight)
            let xConstraint = NSLayoutConstraint(item: passwordInput, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
            let yConstraint = NSLayoutConstraint(item: passwordInput, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
            self.view.addConstraints([xConstraint, yConstraint, widthConstraint, heightConstraint])

            print("ZZZZZ")
            
            passwordInput.confirmButton.addTarget(self, action:  #selector(passwordButtonClicked(button:)), for: .touchUpInside)

            UIView.animate(withDuration: 0.2) {
                self.passwordInput.alpha = 1
                self.passwordInput.transform = CGAffineTransform.identity
            }
        }
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
            
        } else if indexPath.row == 2 {
            let nBRCCardCell = tableView.dequeueReusableCell(withIdentifier: "nBRCCardCell", for: indexPath) as! nBRCCardCell
            nBRCCardCell.balanceLabel.text = String(format: "%.2f", brcCard.balance)
            nBRCCardCell.backgroundColor = .clear
            nBRCCardCell.selectionStyle = .none
            return nBRCCardCell
         
        } else if indexPath.row == 3 {
            let nSPCCardCell = tableView.dequeueReusableCell(withIdentifier: "nSPCCardCell", for: indexPath) as! nSPCCardCell
            nSPCCardCell.balanceLabel.text = String(format: "%.2f", spcCard.balance)
            nSPCCardCell.backgroundColor = .clear
            nSPCCardCell.selectionStyle = .none
            return nSPCCardCell
        
        } else {
            let nCardCell = tableView.dequeueReusableCell(withIdentifier: "nCardCell", for: indexPath) as! nCardCell
            nCardCell.backgroundColor = .clear
            nCardCell.selectionStyle = .none
            
            let cardRow = indexPath.row - 3
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var aSet = NSCharacterSet(charactersIn:"").inverted
        
        if textField == self.amountTextField {
            aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
        }
        
        if textField == self.receiverIDTextField {
            aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        }
        
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    
    @objc override func passwordButtonClicked(button: UIButton) {
        let password = passwordInput.passwordTextField.text
        
        if password ==  UserDefaults.standard.string(forKey: "password")! {
            amount  = amountTextField.text!
            amountTextField.text = ""
            self.passwordInput.passwordTextField.text = ""
            self.blurEffectView.removeFromSuperview()
            self.passwordInput.removeFromSuperview()
            performSegue(withIdentifier: "segue_pay_result", sender: self)
        } else {
            let toast = Toast(text: "password error")
            ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
            toast.show()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_pay_result" {
            if let payResultViewController = segue.destination as? PayResultViewController {
                payResultViewController.hashedNumber = hashedNumber
                payResultViewController.amount = amount
                payResultViewController.message = message
                payResultViewController.remitterPhoneNumber = receiverIDTextField.text!
                payResultViewController.idCode = UserDefaults.standard.string(forKey: "id_code")!
            }
        }
    }
    
    @objc func toggleReceiverID(button: UIButton) {
        let y = self.receiverIDView.frame.origin.y
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
            if y < 0 {
                self.receiverIDView.frame.origin.y = 0
                self.receiverIDTextField.text = ""
            } else {
                self.receiverIDView.frame.origin.y = -60
            }
        })
    }
}
