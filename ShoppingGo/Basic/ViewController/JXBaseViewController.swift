//
//  JXBaseViewController.swift
//  ShoppingGo-Swift
//
//  Created by 杜进新 on 2017/6/6.
//  Copyright © 2017年 杜进新. All rights reserved.
//

import UIKit

class JXBaseViewController: UIViewController {
    
    //MARK: - custom NavigationBar
    //自定义导航栏
    lazy var customNavigationBar : JXNavigationBar = {
        let navigationBar = JXNavigationBar(frame:CGRect(x: 0, y: 0, width: kScreenWidth, height: kNavStatusHeight))
        navigationBar.isTranslucent = true
        navigationBar.barStyle = .blackTranslucent
        navigationBar.barTintColor = UIColor.orange//导航条颜色
        navigationBar.tintColor = UIColor.white //item图片文字颜色
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.red,NSFontAttributeName:UIFont.systemFont(ofSize: 20)]//标题设置
        return navigationBar
    }()
    lazy var customNavigationItem: UINavigationItem = {
        let item = UINavigationItem()
        return item
    }()
    //重写title的setter方法
    override var title: String?{
        didSet {
            customNavigationItem.title = title
        }
    }
    
    //MARK: - default view info
    
    /// default view
    lazy var defaultView: JXDefaultView = {
        let v = JXDefaultView()
        v.backgroundColor = UIColor.randomColor
        return v
    }()
    var defaultInfo : [String:String]?
    
    //log state
    var isLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        view.backgroundColor = UIColor.rgbColor(rgbValue: 0xf1f1f1)
        //view.backgroundColor = UIColor.rgbColor(from: 200, 200, 200)
        //view.backgroundColor = UIColor.randomColor
        
        
        UserManager.default.isLogin ? setUpMainView() : setUpDefaultView()
        
        //FIXME:iOS11,这种方法有问题，navigationbar 的backgroundview， contentview默认为44,且y位于0处，
        setCustomNavigationBar()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension JXBaseViewController {
    func setCustomNavigationBar() {
        //隐藏navigationBar
        //1.自定义view代替NavigationBar,需要自己实现手势返回;
        //2.自定义navigatioBar代替系统的，手势返回不用自己实现
        view.addSubview(customNavigationBar)
        customNavigationBar.items = [customNavigationItem]
    }
//    func setNavigatioinBar(title:String,backGroundColor:UIColor,leftItem:UIView,rightItem:UIView) -> UIView {
//        let navightionView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kNavStatusHeight))
//        navightionView.backgroundColor = UIColor.clear
////        
//    }

}
//MARK: - subviewController need override
extension JXBaseViewController {
    
    /// request data
    func requestData() {
        
    }
    func setUpMainView() {
        //
    }
    /// add default view eg:no data,no network,no login
    func setUpDefaultView() {
        defaultView.frame = view.bounds
        view.addSubview(defaultView)
        defaultView.info = defaultInfo
        defaultView.tapBlock = {()->() in
            self.requestData()
        }
    }
    func updateMainView() {
        
    }
    
    /// loading view
    func showLoadView() {
        JXViewManager.manager.showMBProgressHUD(view: self.view)
    }
    func hideLoadView() {
        JXViewManager.manager.hideMBProgressHUD(view: self.view)
    }
    /// notice view
    func showNotice(notice:String) {
        JXViewManager.manager.showJXNoticeView(notice: notice)
    }
}

extension JXBaseViewController {
    
}
