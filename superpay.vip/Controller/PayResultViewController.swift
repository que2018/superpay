
import UIKit
import QRCode
import CryptoSwift
import Foundation
import SRCountdownTimer

class PayResultViewController: UIViewController, SRCountdownTimerDelegate {

    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var countdownTimer: SRCountdownTimer!
    @IBOutlet var qrcodeImageView: UIImageView!
    
    var idCode = ""
    var amount = ""
    var message = ""
    var hashedNumber = ""
    var remitterPhoneNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countdownTimer.delegate = self
        self.messageLabel.text = message
        self.loadingIndicator.startAnimating()
        
        DispatchQueue.main.async {
            let qrcodeText = self.getQRcodeText()
            let qrCode = QRCode(qrcodeText)
            
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.isHidden = true
            self.qrcodeImageView.image = qrCode?.image
            
            self.countdownTimer.lineWidth = 16
            self.countdownTimer.lineColor = UIColor(red: 21/255, green: 49/255, blue: 93/255, alpha: 1.0)
            self.countdownTimer.labelTextColor = UIColor(red: 255/255, green: 182/255, blue: 0, alpha: 1.0)
            self.countdownTimer.labelFont = UIFont.boldSystemFont(ofSize: 22)
            self.countdownTimer.start(beginingValue: 100, interval: 1)
        }
    }
    
    func timerDidEnd() {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func getQRcodeText() -> String {
        let message = getEncyptedText()
        let jsonText = "{\"code_type\":3,\"message\":\""  + message + "\"}"
        
        return jsonText
    }
    
    private func getEncyptedText() -> String {
        let timeCode = String(Int64((NSDate().timeIntervalSince1970)))
        let verifyCodeRaw = idCode + ":" + hashedNumber + ":" + timeCode
        let verifyCode = Auth.createHaashedCode(string: verifyCodeRaw)
        var encyptedText = ""
        
        do {
            var jsonText = "{\"verify_code\":\"" + verifyCode
            jsonText += "\",\"card_number\":\"" + hashedNumber
            
            if remitterPhoneNumber != "" {
                jsonText += "\",\"remitter_number\":\"" + remitterPhoneNumber
            }
            
            jsonText += "\",\"amount\":\"" + amount
            jsonText +=  "\",\"request_time\":\"" + timeCode + "\"}"
            
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
