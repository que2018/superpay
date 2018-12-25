
import UIKit
import AVFoundation
import QRCodeReader
import Alamofire
import CryptoSwift
import SwiftyJSON

class DrawViewController: AuthGuardViewController, QRCodeReaderViewControllerDelegate {
    
    var success = true
    var amount = 0.0
    var message = ""
    var cardNumber = ""
    var verifyCode = ""
    
    @IBOutlet var previewView: QRCodeReaderView! {
        didSet {
            previewView.setupComponents(showCancelButton: false, showSwitchCameraButton: false, showTorchButton: false, showOverlayView: true, reader: reader)
        }
    }
    
    lazy var reader: QRCodeReader = QRCodeReader()
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader  = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton  = true
            $0.preferredStatusBarStyle = .lightContent
            $0.reader.stopScanningWhenCodeIsFound = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard checkScanPermissions(), !reader.isRunning else { return }
        
        DispatchQueue.main.async {
            self.reader.startScanning()
        }
        
        reader.didFindCode = { result in
            let rawResult = result.value
            var message = ""
        
            //retrive message
            do {
                let dataFromRawResult = rawResult.data(using: .utf8, allowLossyConversion: false)!
                let jsonRawResult = try JSON(data: dataFromRawResult)
                message = jsonRawResult["message"].stringValue
            } catch {
                self.success = false
                self.message = "error_json_decode"
            }
            
            var jsonResult : JSON = JSON()
            
            //aes decrypt
            if self.success {
                do {
                    let data = Data(base64Encoded: message)
                    let decrypted = try AES(key: Array(CONSTANT.AES_KEY.utf8), blockMode: CBC(iv: Array(CONSTANT.AES_IV.utf8)), padding: .pkcs5).decrypt([UInt8](data!))
                    let decryptResult = String(bytes: Data(decrypted).bytes, encoding: .utf8)!
                    
                    if let dataFromString = decryptResult.data(using: .utf8, allowLossyConversion: false) {
                        jsonResult = try JSON(data: dataFromString)
                        //print(jsonResult)
                    }
                } catch {
                    self.success = false
                    self.message = "aes_decrpytion_decode"
                }
            }
            
            //fail at decoding
            if !self.success {
                self.performSegue(withIdentifier: "segue_draw_result", sender: self)
                
            //success at decoding
            } else {
                //receiver not the current user
                if (jsonResult["amount"] != JSON.null) && (jsonResult["remitter_number"] != JSON.null) && (jsonResult["remitter_number"].stringValue != UserDefaults.standard.string(forKey: "user_id")!)
                {
                    self.success = false
                    self.message = "RECEIVER INVALID"
                    self.performSegue(withIdentifier: "segue_draw_result", sender: self)
                }
                //credit card mode(no receiver && no amount)
                else if (jsonResult["card_number_hash_remitter"] == JSON.null) && (jsonResult["amount"] == JSON.null)
                {
                    self.cardNumber = jsonResult["card_number"].stringValue
                    self.verifyCode = jsonResult["verify_code"].stringValue
                    self.performSegue(withIdentifier: "segue_draw_amount", sender: self)
                }
                else
                {
                    let parameters:[String: String] = [
                        "total_pay": jsonResult["amount"].stringValue,
                        "phone_number_remitter": UserDefaults.standard.string(forKey: "user_id")!,
                        "time_code": jsonResult["request_time"].stringValue,
                        "card_number_hash_payeer": jsonResult["card_number"].stringValue,
                        "verifey_code": jsonResult["verify_code"].stringValue
                    ]
                    
                    var parameterString = jsonResult["card_number"].stringValue + ":"
                    parameterString += UserDefaults.standard.string(forKey: "user_id")! + ":"
                    parameterString += jsonResult["request_time"].stringValue + ":"
                    parameterString += jsonResult["amount"].stringValue + ":"
                    parameterString += jsonResult["verify_code"].stringValue + ":"
                    
                    let headers = Auth.getPrivateAuthHeaders(method: "POST", apiName: "transition", parameterString: parameterString)
                
                    Alamofire.request(ADDR.TRANSITION, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { response in
                        if let json = response.result.value {
                            let jsonData = json as! [String  : Any]
                            let code = jsonData["code"] as! Int
                            
                            if code == 200 {
                                self.success = true
                                self.amount = jsonResult["amount"].doubleValue
                            } else {
                                self.success = false
                                //self.message = jsonData["detail"] as! String
                            }
                            
                            self.performSegue(withIdentifier: "segue_draw_result", sender: self)
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.reader.startScanning()
        }
    }
    
    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(settingsURL)
                        }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            default:
                alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            
            present(alert, animated: true, completion: nil)
            
            return false
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true) { [weak self] in
            let alert = UIAlertController(
                title: "QRCodeReader",
                message: String (format:"%@ (of type %@)", result.value, result.metadataType),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        print("Switching capturing to: \(newCaptureDevice.device.localizedName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_draw_result" {
            if let drawResultViewController = segue.destination as? DrawResultViewController {
                drawResultViewController.success = success
                drawResultViewController.amount = amount
                drawResultViewController.message = message
            }
        }
        
        if segue.identifier == "segue_draw_amount" {
            if let drawAmountViewController = segue.destination as? DrawAmountViewController {
                drawAmountViewController.cardNumber = cardNumber
                drawAmountViewController.verifyCode = verifyCode
            }
        }
    }
}

