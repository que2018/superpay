
import UIKit

class DrawResultViewController: UIViewController {

    var success = false
    var amount = 0.0
    var message = ""
    
    let successAlert: SuccessAlert = SuccessAlert()
    let failAlert: FailAlert = FailAlert()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let width = screenWidth * 0.8
        let height = width * 155 / 232
        
        if success  {
            successAlert.frame = CGRect(x:0, y: 0, width: width, height: height)
            successAlert.translatesAutoresizingMaskIntoConstraints = false
            successAlert.alpha = 1
            successAlert.amountLabel.text = String(amount) + " unit"
            successAlert.returnButton.addTarget(self, action:  #selector(returnToHome(button:)), for: .touchUpInside)
            
            self.view.addSubview(successAlert)
            self.view.bringSubview(toFront: successAlert)
            
            successAlert.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            successAlert.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
                self.successAlert.alpha = 1
                self.successAlert.transform = CGAffineTransform.identity
            }
            
            let centerX = NSLayoutConstraint(item: successAlert, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            let centerY = NSLayoutConstraint(item: successAlert, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: successAlert, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: width)
            let heightConstraint = NSLayoutConstraint(item: successAlert, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: height)
            
            self.view.addConstraints([centerX, centerY, heightConstraint, widthConstraint])
        }
        else
        {
            failAlert.frame = CGRect(x:0, y: 0, width: width, height: height)
            failAlert.translatesAutoresizingMaskIntoConstraints = false
            failAlert.alpha = 1
            failAlert.messageLabel.text = NSLocalizedString(message, comment: "")
            failAlert.backButton.addTarget(self, action:  #selector(backToScan(button:)), for: .touchUpInside)
            
            self.view.addSubview(failAlert)
            self.view.bringSubview(toFront: failAlert)
            
            failAlert.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            failAlert.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
                self.failAlert.alpha = 1
                self.failAlert.transform = CGAffineTransform.identity
            }
            
            let centerX = NSLayoutConstraint(item: failAlert, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            let centerY = NSLayoutConstraint(item: failAlert, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: failAlert, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: width)
            let heightConstraint = NSLayoutConstraint(item: failAlert, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: height)
            
            self.view.addConstraints([centerX, centerY, heightConstraint, widthConstraint])
        }
    }
    
    @objc func returnToHome(button: UIButton) {
        var navigationArray = self.navigationController?.viewControllers
       
        navigationArray!.remove(at: 1)
        navigationArray!.remove(at: 1)

        self.navigationController?.viewControllers = navigationArray!
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func backToScan(button: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)   
    }
}
