//
//  ImageViewerViewController.swift
//  EasyChat
//
//  Created by Atulya Shetty on 03/22/20.
//  Copyright © 2020 Atulya Shetty. All rights reserved.
//

import UIKit
import SDWebImage

class ImageViewerViewController: UIViewController {

    
    private let url : URL
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    init(with url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo"
        view.backgroundColor = .black
        navigationItem.largeTitleDisplayMode = .never
        view.addSubview(imageView)
        self.imageView.sd_setImage(with: self.url, completed: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

