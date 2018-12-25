
import UIKit
import Alamofire

class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
     var banners = [Banner]()
 
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle  = UITableViewCellSeparatorStyle.none
        
        tableView.register(UINib(nibName: "BannerCell", bundle: Bundle.main), forCellReuseIdentifier: "BannerCell")
        tableView.register(UINib(nibName: "BannerHeaderCell", bundle: Bundle.main), forCellReuseIdentifier: "BannerHeaderCell")
        
        loadData()
    }
    
   func loadData() {
        let  headers = Auth.getPublicAuthHeaders(method: "GET", apiName: "promotion", parameterString: "")
        
        Alamofire.request(ADDR.PROMOTION, headers: headers) .responseJSON { response in
            if let json = response.result.value {
                let jsonData = json as! [String  : Any]
                
                let objectsJson = jsonData["object"] as! NSArray
                
                var i = 0
                
                for objectJson in objectsJson {
                    if i > 0 {
                        let objectData = objectJson as! [String : Any]
                        let thumbnail = objectData["thumbnail"] as! String
                        
                        let banner = Banner()
                        banner.imageUrl = thumbnail
                        self.banners.append(banner)
                        
                        print(thumbnail)
                    }
                    
                    i = i + 1
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return banners.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        if indexPath.row == 0 {
            return screenWidth * 236 / 720
         } else {
            return screenWidth
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let bannerHeaderCell = tableView.dequeueReusableCell(withIdentifier: "BannerHeaderCell", for: indexPath) as! BannerHeaderCell
            
            let banner = self.banners[indexPath.row]
            let imageUrl = URL(string: banner.imageUrl)!
            
            let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async() {
                    bannerHeaderCell.bannerView.image = UIImage(data: data)
                }
            }
            
            task.resume()
            
            return bannerHeaderCell
            
        } else {
            let bannerCell = tableView.dequeueReusableCell(withIdentifier: "BannerCell", for: indexPath) as! BannerCell
            
            let banner = self.banners[indexPath.row]
            let imageUrl = URL(string: banner.imageUrl)!
            
            let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async() {
                    bannerCell.bannerView.image = UIImage(data: data)
                }
            }
            
            task.resume()
            
            return bannerCell
        }
    }
}

