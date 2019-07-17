//
//  ZappHookErrorViewController.swift
//  Zapp-App
//
//  Created by user on 18/12/2018.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

import Foundation
import UIKit
import ZappPlugins

open class ZappHookErrorViewController: UIViewController {
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    var zappStyleKey: String?
    var errorMessage: String?
    var backgroundColor: String?
    
    // this is a convenient way to create this view controller without a imageURL
    convenience init() {
        self.init(backgroundColor: nil, errorMessage: nil, zappStyleKey: nil)
    }
    
    init(backgroundColor: String?, errorMessage: String?, zappStyleKey: String?) {
        super.init(nibName: nil, bundle: nil)
        self.errorMessage = errorMessage
        self.backgroundColor = backgroundColor
        self.zappStyleKey = zappStyleKey
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        //        ZAAppConnector.sharedInstance().layoutsStylesDelegate.setLabelStyle(errorMessageLabel, withKeys:[:])
        //
        //        view.backgroundColor = GAUICustomizationHelper.color(forKey: AppLoadingBGColor)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.errorMessageLabel.text = errorMessage
        self.errorMessageLabel.backgroundColor = UIColor.init(hex: backgroundColor)
        self.errorMessageLabel.numberOfLines = 0
        self.view.backgroundColor = UIColor.init(hex: "00000000")
        
        ZAAppConnector.sharedInstance().layoutsStylesDelegate.setLabelStyle?(self.errorMessageLabel, withKeys: [kZappLayoutStylesFontKey:zappStyleKey as Any])
        
        
    }
}
