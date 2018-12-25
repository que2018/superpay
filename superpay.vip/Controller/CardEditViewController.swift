
import UIKit
import Toaster
import Alamofire
import DLRadioButton
import FormTextField

class CardEditViewController: PopoutViewController {

    var card = Card()
    
    @IBOutlet var userInputView: UIView!
    
    @IBOutlet var cardNumberWrap: UIView!
    @IBOutlet var expireDateWrap: UIView!
    
    @IBOutlet var visaWrap: UIView!
    @IBOutlet var masterWrap: UIView!
    @IBOutlet var jbcWrap: UIView!
    @IBOutlet var ucardWrap: UIView!
    
    @IBOutlet var cardTypeImageView: UIImageView!
    
    @IBOutlet var confirmButton: LoadingButton!
    @IBOutlet var deleteButton: LoadingButton!
    
    var visaRadioButton: DLRadioButton = {
        let frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        let color = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        let radioButton = DLRadioButton(frame: frame)
        radioButton.titleLabel!.font = UIFont.systemFont(ofSize: 18)
        radioButton.setTitleColor(color, for: [])
        radioButton.iconColor = color
        radioButton.iconSize = 23
        radioButton.indicatorColor = color
        radioButton.iconStrokeWidth = 1
        radioButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        return radioButton
    }()
    
    var masterRadioButton: DLRadioButton = {
        let frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        let color = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        let radioButton = DLRadioButton(frame: frame)
        radioButton.titleLabel!.font = UIFont.systemFont(ofSize: 18)
        radioButton.setTitleColor(color, for: [])
        radioButton.iconColor = color
        radioButton.iconSize = 23
        radioButton.indicatorColor = color
        radioButton.iconStrokeWidth = 1
        radioButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        return radioButton
    }()
    
    var jbcRadioButton: DLRadioButton = {
        let frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        let color = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        let radioButton = DLRadioButton(frame: frame)
        radioButton.titleLabel!.font = UIFont.systemFont(ofSize: 18)
        radioButton.setTitleColor(color, for: [])
        radioButton.iconColor = color
        radioButton.iconSize = 23
        radioButton.indicatorColor = color
        radioButton.iconStrokeWidth = 1
        radioButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        return radioButton
    }()
    
    var ucardRadioButton: DLRadioButton = {
        let frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        let color = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        let radioButton = DLRadioButton(frame: frame)
        radioButton.titleLabel!.font = UIFont.systemFont(ofSize: 18)
        radioButton.setTitleColor(color, for: [])
        radioButton.iconColor = color
        radioButton.iconSize = 23
        radioButton.indicatorColor = color
        radioButton.iconStrokeWidth = 1
        radioButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        return radioButton
    }()
    
    lazy var cardNumberField: FormTextField = {
        let textField = FormTextField(frame: self.cardNumberWrap.frame)
        textField.inputType = .integer
        textField.formatter = CardNumberFormatter()
        textField.placeholder = "4000 0000 0000 0000"
        textField.font = .systemFont(ofSize: 18)
        
        let border = CALayer()
        let width = CGFloat(0.8)
        border.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
        border.frame = CGRect(x: 0, y: self.cardNumberWrap.frame.height - width, width: self.cardNumberWrap.frame.width, height: self.cardNumberWrap.frame.height)
        
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
        
        var validation = Validation()
        validation.maximumLength = 19
        validation.minimumLength = 19
        let characterSet = NSMutableCharacterSet.decimalDigit()
        characterSet.addCharacters(in: " ")
        validation.characterSet = characterSet as CharacterSet
        let inputValidator = InputValidator(validation: validation)
        textField.inputValidator = inputValidator
        
        return textField
    }()
    
    lazy var cardExpirationDateField: FormTextField = {
        let textField = FormTextField(frame: self.expireDateWrap.frame)
        textField.inputType = .integer
        textField.placeholder = "(MM/YY)"
        textField.formatter = CardExpirationDateFormatter()
        textField.font = .systemFont(ofSize: 18)
        
        let border = CALayer()
        let width = CGFloat(0.8)
        border.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
        border.frame = CGRect(x: 0, y: self.expireDateWrap.frame.height - width, width: self.expireDateWrap.frame.width, height: self.expireDateWrap.frame.height)
        
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
        
        var validation = Validation()
        validation.minimumLength = 1
        let inputValidator = CardExpirationDateInputValidator(validation: validation)
        textField.inputValidator = inputValidator
        
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var otherButtons : [DLRadioButton] = [];
        otherButtons.append(masterRadioButton)
        otherButtons.append(jbcRadioButton)
        otherButtons.append(ucardRadioButton)
        visaRadioButton.otherButtons = otherButtons;
        
        visaWrap.addSubview(visaRadioButton)
        masterWrap.addSubview(masterRadioButton)
        jbcWrap.addSubview(jbcRadioButton)
        ucardWrap.addSubview(ucardRadioButton)
        
        //add edit event
        confirmButton.addTarget(self, action:  #selector(confirmEditCard(button:)), for: .touchUpInside)
        
        //add delete event
        deleteButton.addTarget(self, action:  #selector(confirmDeleteCard(button:)), for: .touchUpInside)
        
        //arounded user input area
        userInputView.backgroundColor = UIColor.white
        userInputView.layer.cornerRadius = 4.0
        userInputView.layer.borderColor = UIColor(white: 1, alpha: 0).cgColor
        userInputView.layer.borderWidth = 0
        userInputView.clipsToBounds = true
        
        cardNumberField.frame =  CGRect(x:0, y: 2, width:cardNumberWrap.frame.width, height: cardNumberWrap.frame.height)
        cardExpirationDateField.frame =  CGRect(x:0, y: 0, width:expireDateWrap.frame.width, height: expireDateWrap.frame.height)
        
        cardNumberWrap.addSubview(cardNumberField)
        expireDateWrap.addSubview(cardExpirationDateField)
        
        //set value
        if card.type == 2 {
            visaRadioButton.isSelected = true
            cardTypeImageView.image = UIImage(named: "visa")!
        } else if card.type == 3 {
            masterRadioButton.isSelected = true
            cardTypeImageView.image = UIImage(named: "master")!
        } else if card.type == 4  {
            jbcRadioButton.isSelected = true
            cardTypeImageView.image = UIImage(named: "jbc")!
        } else if card.type == 5 {
            ucardRadioButton.isSelected = true
            cardTypeImageView.image = UIImage(named: "ucard")!
        }
        
        cardNumberField.isSecureTextEntry = true
        cardNumberField.text = card.cardNumber

        if card.expDateMonth > 10 {
            cardExpirationDateField.text = String(card.expDateMonth) + "/" + String(card.expDateYear)
        } else {
            cardExpirationDateField.text = "0" + String(card.expDateMonth) + "/" + String(card.expDateYear)
        }
    }
    
    @objc func confirmEditCard(button: UIButton) {
        self.view.endEditing(true)
        
        var messages = ""
        
        if (visaRadioButton.selected() == nil) && (masterRadioButton.selected() == nil) && (jbcRadioButton.selected() == nil) && (ucardRadioButton.selected() == nil) {
            messages += "\ncard type is not selected"
        }
        
        if cardNumberField.text == "" {
            messages = "card number is empty"
        }
        
        if cardExpirationDateField.text == "" {
            messages += "\nexpiration date is empty"
        }
        
        if messages != "" {
            let alert = UIAlertController(title: "Alert", message: messages, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            self.confirmButton.showLoading()
            
            //type data
            var type = ""
            
            if visaRadioButton.isSelected {
                type = "2"
            } else if masterRadioButton.isSelected {
                type = "3"
            } else if jbcRadioButton.isSelected {
                type = "4"
            } else if ucardRadioButton.isSelected {
                type = "5"
            }
            
            //card number data
            let cardNumber = cardNumberField.text!
            let cardNumberDashed = cardNumber.replacingOccurrences(of: " ", with: "-")
            let hashedNumber = Auth.createHaashedCode(string: cardNumberDashed)
            
            //expiration data
            let expirationDate = cardExpirationDateField.text?.components(separatedBy: "/")
            
            let parameters:[String: String] = [
                "customer_name": UserDefaults.standard.string(forKey: "name")!,
                "hashed_number": hashedNumber,
                "type": type,
                "exp_date_month": expirationDate![0],
                "exp_date_year": expirationDate![1],
                "publisher_id": CONSTANT.PUBLISHER_DEFAULT
            ]
            
            let url = ADDR.CARD + "/" + card.id
            
            var parameterString  = expirationDate![1] + ":"
            parameterString  += CONSTANT.PUBLISHER_DEFAULT + ":"
            parameterString  +=  hashedNumber + ":"
            parameterString  += type + ":"
            parameterString  += expirationDate![0] + ":"
            parameterString  += UserDefaults.standard.string(forKey: "name")! + ":"
            
            let headers = Auth.getPrivateAuthHeaders(method: "PUT", apiName: "card", parameterString: parameterString)
            
            Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                self.confirmButton.hideLoading()
                
                if let json = response.result.value {
                    let jsonData = json as! [String  : Any]
                    let code = jsonData["code"] as! Int
                    
                    if code == 200 {
                        let card = Card()
                        card.localId = self.card.localId
                        card.cardNumber = cardNumber
                        card.hashedNumber = hashedNumber
                        let success = CardTable.editCard(card: card)
                        
                        if success {
                            let toast = Toast(text: "card edit success")
                            ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
                            toast.show()
                        
                            self.navigationController?.popViewController(animated: true)
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            let alert = UIAlertController(title: "Alert", message: "app error: not able to edit card", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        let alert = UIAlertController(title: "Alert", message: "sever error: not able to edit card", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @objc func confirmDeleteCard(button: UIButton) {
        self.view.addSubview(blurEffectView)
        self.view.addSubview(passwordInput)
        self.view.bringSubview(toFront: passwordInput)
        
        let widthConstraint = NSLayoutConstraint(item: passwordInput, attribute: .width, relatedBy: .equal,toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.passwordInputWidth)
        let heightConstraint = NSLayoutConstraint(item: passwordInput, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.passwordInputHeight)
        let xConstraint = NSLayoutConstraint(item: passwordInput, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: passwordInput, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        self.view.addConstraints([xConstraint, yConstraint, widthConstraint, heightConstraint])
        
        UIView.animate(withDuration: 0.2) {
            self.passwordInput.alpha = 1
            self.passwordInput.transform = CGAffineTransform.identity
        }
    }
    
    @objc override func passwordButtonClicked(button: UIButton) {
        let password = passwordInput.passwordTextField.text

        if password ==  UserDefaults.standard.string(forKey: "password")! {
            self.passwordInput.passwordTextField.text = ""
            self.blurEffectView.removeFromSuperview()
            self.passwordInput.removeFromSuperview()
            commitDeleteCard()
        } else {
            let toast = Toast(text: "password error")
            ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
            toast.show()
        }
    }
    
    func commitDeleteCard() {
        self.deleteButton.showLoading()

        let url = ADDR.CARD + "/" +  card.id
        let  headers = Auth.getPrivateAuthHeaders(method: "DELETE", apiName: "card", parameterString: "")
        
        Alamofire.request(url, method: .delete, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            self.deleteButton.hideLoading()
            
            if let json = response.result.value {
                let jsonData = json as! [String  : Any]
                let code = jsonData["code"] as! Int
                
                if code == 200 {
                    let success = CardTable.deleteCard(card: self.card)
                    
                    if success {
                        let toast = Toast(text: "card delete success")
                        ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
                        toast.show()
                        
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "Alert", message: "app error: not able to delete card", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: "Alert", message: "sever error: not able to delete card", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}





