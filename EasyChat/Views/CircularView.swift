//
//  CircularView.swift
//  EasyChat
//
//  Created by Atulya Shetty on 7/13/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import UIKit

@IBDesignable class CircularView: UIView {
    weak var delegate : CircularButtonDelegate?
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        print("Closed")
        delegate?.closeButtonClicked()
    }
    
    override func awakeFromNib() {
       super.awakeFromNib()
       //custom logic goes here
        didLoad()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        didLoad()
    }
    func didLoad() {
        layer.cornerRadius = height/2
        layer.masksToBounds = true
    }
    
}


protocol CircularButtonDelegate: AnyObject {
    func closeButtonClicked()
}
