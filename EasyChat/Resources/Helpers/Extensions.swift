//
//  Extensions.swift
//  EasyChat
//
//  Created by Atulya Shetty on 6/26/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    public var width:CGFloat {
        return frame.size.width
    }
    
    public var height:CGFloat {
           return frame.size.height
    }
    
    public var top:CGFloat {
             return frame.origin.y
    }
    
    public var bottom:CGFloat {
        return frame.size.height + frame.origin.y
     }
    
    public var left:CGFloat {
             return frame.origin.x
    }
    
    public var right:CGFloat {
        return frame.size.width + frame.origin.x
     }
}
extension UITextField {
    func addBottomBorder() {
        let border = CALayer()
        let width = CGFloat(0.7)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

extension Notification.Name {
    static let didLoginNotification = Notification.Name("didLoginNotification")
}
