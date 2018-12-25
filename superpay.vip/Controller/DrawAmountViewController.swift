
import UIKit
import Alamofire

class DrawAmountViewController: BasicViewController,  UITextFieldDelegate {
   
    var success = false
    var message = ""
    var amount = 0.0
    var verifyCode = ""
    var cardNumber = ""
    
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var confirmButton: LoadingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountTextField.delegate = self

        //add edit event
        confirmButton.addTarget(self, action:  #selector(confirmDraw(button:)), for: .touchUpInside)
    }
    
    @objc func confirmDraw(button: UIButton) {
        self.view.endEditing(true)
        self.confirmButton.showLoading()

        let parameters:[String: String] = [
            "total_pay": String(amountTextField.text!),
            "card_number_hash_remitter": UserDefaults.standard.string(forKey: "default_card_hashed_number")!,
            "time_code": String(Int64((NSDate().timeIntervalSince1970))),
            "card_number_hash_payeer": cardNumber,
            "verifey_code": verifyCode
        ]
        
        var parameterString  = cardNumber + ":"
        parameterString  +=  UserDefaults.standard.string(forKey: "default_card_hashed_number")! + ":"
        parameterString  += String(Int64((NSDate().timeIntervalSince1970))) + ":"
        parameterString  += String(amountTextField.text!) + ":"
        parameterString  += verifyCode + ":"
        
        let headers = Auth.getPrivateAuthHeaders(method: "POST", apiName: "transition", parameterString: parameterString)

        Alamofire.request(ADDR.TRANSITION, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { response in
            self.confirmButton.hideLoading()
            self.amountTextField.isUserInteractionEnabled = true
            
            if let json = response.result.value {
                let jsonData = json as! [String  : Any]
                let code = jsonData["code"] as! Int
                
                if code == 200 {
                    self.success = true
                    self.amount = Double(self.amountTextField.text!)!
                } else {
                    self.success = false
                    //self.message = jsonData["detail"] as! String
                    self.message = "something is wrong"
                }
                
                self.performSegue(withIdentifier: "segue_draw_result_amount", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_draw_result_amount" {
            if let drawResultViewController = segue.destination as? DrawResultViewController {
                drawResultViewController.success = success
                drawResultViewController.amount = amount
                drawResultViewController.message = message
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
}
