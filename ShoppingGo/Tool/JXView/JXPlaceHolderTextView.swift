//
//  JXPlaceHolderTextView.swift
//  ShoppingGo
//
//  Created by 杜进新 on 2017/8/4.
//  Copyright © 2017年 杜进新. All rights reserved.
//

import UIKit

class JXPlaceHolderTextView: UITextView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var placeHolderText : String = "" {
        didSet{
            self.placeHolderView.text = placeHolderText
        }
    }
    /// //UITextField 默认为R:0 G:0 B:0.1 A:0.22
    var placeHolderColor : UIColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0.1, alpha: 0.22) {
        didSet{
            self.placeHolderView.textColor = placeHolderColor
        }
    }
    /// 与文本字体大小一致
    //var placeHolderFont : UIFont!
    
    
    
    
    lazy var placeHolderView: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.font = self.font
        lab.textColor = self.placeHolderColor
        lab.text = self.placeHolderText
        lab.textAlignment = .left
        lab.sizeToFit()
     
        return lab
    }()
//    convenience init() {
//        self.init()
//        setPlaceHolderView()
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setPlaceHolderView()
//    }
    
    /// init method
    ///
    /// - Parameters:
    ///   - frame: view frame
    ///   - textContainer: text frame 会自动根据内容调整大小
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        setPlaceHolderView()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setPlaceHolderView()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.placeHolderView.frame = CGRect(origin: CGPoint(x: 8, y: 8), size: CGSize(width:frame.width - 8*2,height:0))
        self.placeHolderView.sizeToFit()
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    func setPlaceHolderView() {
        addSubview(self.placeHolderView)
        sendSubview(toBack: self.placeHolderView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(placeHolderTextChange(nofiy:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    func placeHolderTextChange(nofiy:Notification) {
        if placeHolderText.isEmpty == true {
            return
        }
        
        if self.text.isEmpty == true {
            self.placeHolderView.isHidden = false
        }else{
            self.placeHolderView.isHidden = true
        }
    }

}