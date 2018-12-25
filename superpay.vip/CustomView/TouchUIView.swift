
import UIKit

class TouchUIView: UIView {
    
    var backgroundColorUntouched = UIColor.white
    var backgroundColorTouched = UIColor.white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = backgroundColorUntouched
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backgroundColor = backgroundColorTouched
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        backgroundColor = backgroundColorUntouched
    }
}
