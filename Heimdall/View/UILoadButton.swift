//
//  UILoadButton.swift
//  SUB Chat
//
//  Created by Marius Ilie on 28/03/17.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class UILoadButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 3.0
    var spinnerView: UIActivityIndicatorView?
    var buttonTitleLabel: UILabel?
    
    private enum SpinnerStatusCases {
        case inactive
        case active
    }
    private var spinnerStatus: SpinnerStatusCases = .inactive
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = cornerRadius
        
        self.titleLabel?.frame.size.width = self.frame.size.width
        self.titleLabel?.frame.size.height = self.frame.size.height
        
        self.buttonTitleLabel = UILabel()
        
        self.buttonTitleLabel?.frame.size.width = self.frame.size.width
        self.buttonTitleLabel?.frame.size.height = self.frame.size.height
        self.buttonTitleLabel?.frame.origin.x = 0
        self.buttonTitleLabel?.frame.origin.y = 0
        self.buttonTitleLabel?.textAlignment = .center
        self.buttonTitleLabel?.baselineAdjustment = .alignCenters
        self.buttonTitleLabel?.font = self.titleLabel?.font
        self.buttonTitleLabel?.textColor = self.titleLabel?.textColor
        self.buttonTitleLabel?.text = self.titleLabel?.text
        
        self.addSubview(self.buttonTitleLabel!)
        self.titleLabel?.removeFromSuperview()
        
        self.spinnerView = UIActivityIndicatorView()
        self.spinnerView?.activityIndicatorViewStyle = .white
        self.spinnerView?.frame.origin.x = self.frame.width/2
        self.spinnerView?.frame.origin.y = self.frame.height/2
        self.spinnerView?.alpha = 0
        
        self.addSubview(self.spinnerView!)
        
        self.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    }
    
    @objc private func touchUpInside() {
        if spinnerStatus == .inactive {
            spinnerStatus = .active
            animateIn()
        } else {
            spinnerStatus = .inactive
            animateOut()
        }
    }
    
    func animateIn() {
        self.spinnerView?.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        self.spinnerView?.startAnimating()
        
        UIView.animate(withDuration: 0.1) {
            self.buttonTitleLabel?.alpha = 0
            self.spinnerView?.alpha = 1
            self.spinnerView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
    }
    
    func animateOut() {
        self.buttonTitleLabel?.transform = CGAffineTransform.init(scaleX: 2, y: 2)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.buttonTitleLabel?.transform = CGAffineTransform.identity
            self.buttonTitleLabel?.alpha = 1
            self.spinnerView?.alpha = 0
            self.spinnerView?.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        }) { _ in
            self.spinnerView?.stopAnimating()
        }
    }
}
