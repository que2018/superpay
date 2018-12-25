
import Foundation
import Alamofire
import Toaster
import XLPagerTabStrip

class AllTransactionViewController: UITableViewController, IndicatorInfoProvider {
    
    let cellIdentifier = "AllTransactionCell"
    
    var transitions = [Transition]()
    var itemInfo = IndicatorInfo(title: "View")
    
    let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    init(style: UITableViewStyle, itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "AllTransactionCell", bundle: Bundle.main), forCellReuseIdentifier: cellIdentifier)
        tableView.estimatedRowHeight = 85
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        tableView.separatorStyle  = UITableViewCellSeparatorStyle.none
        
        if UserDefaults.standard.bool(forKey: "is_login") {
            DispatchQueue.main.async {
                self.loadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func loadData() {
        self.loadingIndicator.center = self.view.center
        self.loadingIndicator.hidesWhenStopped = true
        self.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(self.loadingIndicator)
        self.loadingIndicator.startAnimating()
        
        let  headers = Auth.getPrivateAuthHeaders(method: "GET", apiName: "transition", parameterString: "")
        
        Alamofire.request(ADDR.TRANSITION, headers: headers) .responseJSON { response in
            if let json = response.result.value {
                let jsonData = json as! [String  : Any]
                //print(jsonData)
                
                let code = jsonData["code"] as! Int

                if code == 200 {
                    let transitions = jsonData["object"] as? NSArray

                    if transitions != nil {
                        for transition in transitions! {
                            let transitionData = transition as! [String : Any]
                            let payeerName = transitionData["payeer_name"] as? String
                            let totalPay = transitionData["total_pay"] as! String
                            let updatedAt = transitionData["updated_at"] as! String
                            
                            let transition = Transition()
                            if payeerName == UserDefaults.standard.string(forKey: "name")! {
                                transition.type = 1
                            } else {
                                transition.type = 0
                            }
                            
                            transition.payeerName = (payeerName != nil) ? payeerName! : NSLocalizedString("text_unknown", comment: "")
                            transition.remitterName = NSLocalizedString("text_you", comment: "")
                            transition.totalPay = Double(totalPay)!.rounded(toPlaces: 2)
                            transition.updatedAt = updatedAt
                            self.transitions.append(transition)
                        }
                        
                        self.sortTransition()
                        self.loadingIndicator.stopAnimating()
                        self.tableView.reloadData()
                        
                    } else {
                        let toast = Toast(text: NSLocalizedString("text_logout_transaction_notice", comment: ""), duration: Delay.long)
                        ToastView.appearance().font = UIFont.systemFont(ofSize: 18)
                        toast.show()
                    }
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transitions.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let allTransactionCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AllTransationCell
        
        if transitions[indexPath.row].type == 1 {
            allTransactionCell.nameLabel.text = transitions[indexPath.row].remitterName
        } else {
            allTransactionCell.nameLabel.text = transitions[indexPath.row].payeerName
        }
        
        allTransactionCell.dateTimeLabel.text = transitions[indexPath.row].updatedAt
        allTransactionCell.amountLabel.text = "$" + String(transitions[indexPath.row].totalPay)
        
        if  transitions[indexPath.row].type == 1 {
            allTransactionCell.nameLabel.textColor = UIColor(red: 237/255, green: 0/255, blue: 18/255, alpha: 1.0)
            allTransactionCell.amountLabel.textColor = UIColor(red: 237/255, green: 0/255, blue: 18/255, alpha: 1.0)
        } else {
            allTransactionCell.nameLabel.textColor = UIColor(red: 255/255, green: 182/255, blue: 0/255, alpha: 1.0)
            allTransactionCell.amountLabel.textColor = UIColor(red: 255/255, green: 182/255, blue: 0/255, alpha: 1.0)
        }
        
        return allTransactionCell
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func sortTransition() {
        if transitions.count > 1 {
            for i in 0 ...  transitions.count - 2 {
                for j in 0 ...  transitions.count - 2 - i {
                    let datetime1 = transitions[j].updatedAt
                    let datetime2 = transitions[j+1].updatedAt
                    
                    if datetime1 < datetime2 {
                        let temp = transitions[j]
                        transitions[j] = transitions[j+1]
                        transitions[j+1] = temp
                    }
                }
            }
        }
    }
}