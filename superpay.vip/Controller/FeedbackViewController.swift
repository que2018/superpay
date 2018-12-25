
import UIKit
import Toaster

class FeedbackViewController: BasicViewController {

    @IBOutlet var submitButton: LoadingButton!
    
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
        
        //add submit event
        submitButton.addTarget(self, action:  #selector(submitComment(button:)), for: .touchUpInside)
    }
    
    @objc func submitComment(button: UIButton) {
        let toast = Toast(text: "submit success")
        ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
        toast.show()
    }
}
