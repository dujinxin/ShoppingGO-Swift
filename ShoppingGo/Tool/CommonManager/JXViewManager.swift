//
//  JXViewManager.swift
//  ShoppingGo
//
//  Created by 杜进新 on 2017/8/4.
//  Copyright © 2017年 杜进新. All rights reserved.
//

import UIKit

import MBProgressHUD

class JXViewManager {
    static let manager = JXViewManager()
    
    var hud : MBProgressHUD?
    var noticeView : JXNoticeView?
    
    
    private init() {
        
    }

}


extension JXViewManager {
    
    ///MBProgressHUD loading view
    func showMBProgressHUD(view:UIView) {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        
    }
    func hideMBProgressHUD(view:UIView) {
        //MBProgressHUD.hide(for: view, animated: true)
        
        if let hud = hud {
            //hud.hide(animated: true)
            hud.hide(animated: true, afterDelay: 2)
        }
    }
    
    ///JXNoticeView 
    
    func showJXNoticeView(notice:String) {
        
        if let hud = hud {
            hud.hide(animated: true)
        }
        noticeView = nil
        
        noticeView = JXNoticeView(text: notice)
        noticeView?.show()
    }
}
