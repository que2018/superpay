
import UIKit

class HelpCenterViewController: UIViewController {

    @IBOutlet var returnButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up background
        let bgImageView = UIImageView(frame: view.bounds)
        bgImageView.contentMode =  UIViewContentMode.scaleAspectFill
        bgImageView.clipsToBounds = true
        bgImageView.center = view.center
        bgImageView.image = UIImage(named: "bg_member_login")
        self.view.addSubview(bgImageView)
        self.view.sendSubview(toBack: bgImageView)
        
        //login
        returnButton.addTarget(self, action:  #selector(clickReturn(button:)), for: .touchUpInside)
    }
    
    @objc func clickReturn(button: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}
