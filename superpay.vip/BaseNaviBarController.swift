//
//  BaseNaviBarController.swift
//  superpay.vip
//
//  Created by Yan Geng on 8/13/18.
//  Copyright © 2018 Jiusite.com. All rights reserved.
//

import UIKit

class BaseNaviBarController: UINavigationBar {
    @IBOutlet weak var baseNaviBar: UINavigationItem!
    
    func getNaviBar() -> UINavigationItem {
        return baseNaviBar
    }

}
