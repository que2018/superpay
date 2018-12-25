
import UIKit
import Toaster
import SwiftyJSON
import AVFoundation
import QRCodeReader

class ShotBuyViewController: AuthGuardViewController, QRCodeReaderViewControllerDelegate {
   
    var codeType = ""
    var goodsInfo = ""
    var amount = ""
    var remitterNumber = ""
    
    @IBOutlet weak var previewView: QRCodeReaderView! {
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
            //print(result.value)
            let rawResult = result.value
            
            do {
                let dataFromRawResult = rawResult.data(using: .utf8, allowLossyConversion: false)!
                let jsonRawResult = try JSON(data: dataFromRawResult)
                self.codeType = jsonRawResult["code_type"].stringValue
                self.goodsInfo = jsonRawResult["goods_info"].stringValue
                self.amount = jsonRawResult["amount"].stringValue
                self.remitterNumber = jsonRawResult["remitter_number"].stringValue
                self.performSegue(withIdentifier: "segue_shotbuy_result", sender: self)
            } catch {
                let toast = Toast(text: NSLocalizedString("error_prase_item_info", comment: ""))
                ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
                toast.show()
                
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
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
        if segue.identifier == "segue_shotbuy_result" {
            if let shotBuyResultViewController = segue.destination as? ShotBuyResultViewController {
                shotBuyResultViewController.codeType = codeType
                shotBuyResultViewController.goodsInfo = goodsInfo
                shotBuyResultViewController.amount = amount
                shotBuyResultViewController.remitterNumber = remitterNumber
            }
        }
    }
}

