
import Foundation

class Func {
    static func getTimeStamp(datetimeString: String) -> Int {
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="yyyy-MM-dd hh:mm:ss"
        let date = dfmatter.date(from: datetimeString)
        let dateStamp:TimeInterval = date!.timeIntervalSince1970
        let dateSt:Int = Int(dateStamp)
        return dateSt
    }
    
    static func getDateTime(datetimeString: String) -> Date {
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="yyyy-MM-dd hh:mm:ss"
        let datetime = dfmatter.date(from: datetimeString)
        return datetime!
    }
}

