
import UIKit
import Toaster

class BasicViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //dismiss keyboard when touch
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
