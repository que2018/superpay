
import UIKit
import QRCode
import CryptoSwift
import Foundation

class QuickPaySPCViewController: UIViewController {

    @IBOutlet var userIdLabel: UILabel!
    @IBOutlet var qrcodeImageView: UIImageView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingIndicator.isHidden = true
        
        if UserDefaults.standard.bool(forKey: "is_login") {
            let userId = UserDefaults.standard.string(forKey: "user_id")!
            userIdLabel.text = "ID: " + userId
            
            if (UserDefaults.standard.string(forKey: "spc_card_hashed_number") != nil) {
                self.loadingIndicator.isHidden = false
                self.loadingIndicator.startAnimating()
                
                DispatchQueue.main.async {
                    let qrcodeText = self.getQRcodeText()
                    let qrCode = QRCode(qrcodeText)
                    
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                    self.qrcodeImageView.image = qrCode?.image
                }
            }
        }  else {
            userIdLabel.text = "ID:  -----"
        }
    }
    
    private func getQRcodeText() -> String {
        let message = getEncyptedText()
        let jsonText = "{\"code_type\":2,\"message\":\""  + message + "\"}"
        
        return jsonText
    }
    
    private func getEncyptedText() -> String {
        let idCode = UserDefaults.standard.string(forKey: "id_code")!
        let remitterNumber = UserDefaults.standard.string(forKey: "user_id")!
        let payerCardNumber = UserDefaults.standard.string(forKey: "spc_card_hashed_number")!
        let verifyCodeRaw = idCode + ":" + payerCardNumber + ":"
        let verifyCode = Auth.createHaashedCode(string: verifyCodeRaw)
        
        var encyptedText = ""
        
        do {
            let jsonText = "{\"verify_code\":\"" + verifyCode + "\",\"remitter_number\":\"" + remitterNumber + "\",\"card_number\":\"" + payerCardNumber + "\"}"
            //print(jsonText)
            let aes = try AES(key: Array(CONSTANT.AES_KEY.utf8), blockMode: CBC(iv: Array(CONSTANT.AES_IV.utf8)), padding: .pkcs7)
            let ciphertext = try aes.encrypt(Array(jsonText.utf8))
            let data = NSData(bytes: ciphertext, length: ciphertext.count)
            encyptedText = data.base64EncodedString()
            //print(encyptedText)
        } catch let myJSONError {
            print(myJSONError)
        }
        
        return encyptedText
    }
}
