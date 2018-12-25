
import UIKit
import Toaster
import Alamofire
import DLRadioButton
import FormTextField

class CardAddViewController: AuthGuardViewController {
    
    @IBOutlet var userInputView: UIView!
    
    @IBOutlet var cardNumberWrap: UIView!
    @IBOutlet var expireDateWrap: UIView!
    
    @IBOutlet var visaWrap: UIView!
    @IBOutlet var masterWrap: UIView!
    @IBOutlet var jbcWrap: UIView!
    @IBOutlet var ucardWrap: UIView!
    
    @IBOutlet var submitButton: LoadingButton!
    
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
        
        //add submit click
        submitButton.addTarget(self, action:  #selector(submitAddCard(button:)), for: .touchUpInside)
    
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
    }
    
    @objc func submitAddCard(button: UIButton) {
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
            self.submitButton.showLoading()
            
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
            
            var parameterString  = UserDefaults.standard.string(forKey: "name")! + ":"
            parameterString  +=  expirationDate![0] + ":"
            parameterString  += expirationDate![1] + ":"
            parameterString  += hashedNumber + ":"
            parameterString  += CONSTANT.PUBLISHER_DEFAULT + ":"
            parameterString  += type + ":"

           let headers = Auth.getPrivateAuthHeaders(method: "POST", apiName: "card", parameterString: parameterString)
            
            Alamofire.request(ADDR.CARD, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { response in
                self.submitButton.hideLoading()
                
                if let json = response.result.value {
                    let jsonData = json as! [String  : Any]
                    
                    //print(jsonData)
                    
                    let code = jsonData["code"] as! Int
                        
                    if code == 200 {
                        let card = Card()
                        card.cardNumber = cardNumber
                        card.hashedNumber = hashedNumber
                        CardTable.addCard(card: card)
                        
                        DispatchQueue.main.async {
                            let toast = Toast(text: "card add success")
                            ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
                            toast.show()
                        }
                        
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "Alert", message: "not able to add card", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } 
        }
    }
}


