//
//  UIFloatTextField.swift
//  SUB Chat
//
//  Created by Marius Ilie on 27/03/17.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation
import UIKit

enum UIPlaceholderDirection: String {
    case none = "None"
    case top = "Top"
    case left = "Left"
}

@IBDesignable class UIFloatTextField: UITextField {
    @IBInspectable var placeholderDirection: UIPlaceholderDirection = .left
    @IBInspectable var placeholderColor: UIColor = UIColor.lightGray
    @IBInspectable var cornerRadius: CGFloat = 3.0
    private var placeholderFontName: String = "HelveticaNeue-Light"
    private var placeholderFontSize: CGFloat = 17.0
    private var placeholderAlignment: NSTextAlignment = .natural
    
    private var placeholderLabel: UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let placeholderText = self.initFloatTextField()
        self.replaceWithPlaceholderLabel(text: placeholderText)
        
        NotificationCenter.default.addObserver(self, selector: #selector(screenRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc private func screenRotated() {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            placeholderDirection = .left
        }
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            placeholderDirection = .top
        }
        
        if self.placeholderLabel?.transform != CGAffineTransform.identity {
            placeholderAnimateOut()
            placeholderAnimateIn()
        }
    }
    
    @objc private func editingDidBegin() {
        
    }
    
    @objc private func editingChanged() {
        if self.text == "" {
            placeholderAnimateOut()
        } else if placeholderLabel?.transform == CGAffineTransform.identity {
            placeholderAnimateIn()
        }
    }
    
    @objc private func editingDidEnd() {
        if self.text == "" {
            print("gol")
        }
    }
    
    private func initFloatTextField() -> String? {
        let placeholderText = self.placeholder
        
        self.layer.masksToBounds = false
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        
        let attributes: [String : Any] = [
            NSForegroundColorAttributeName: placeholderColor,
            NSFontAttributeName: UIFont(
                name: self.font?.fontName ?? placeholderFontName,
                size: self.font?.pointSize ?? placeholderFontSize
                )!
        ]
        
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "Placeholder required", attributes:attributes)
        
        if self.borderStyle.rawValue == 0
        {
            self.layer.cornerRadius = cornerRadius
            self.leftViewMode = .always
            self.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 7, height: self.frame.size.height))
        }
        
        self.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        self.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
        self.addTarget(self, action: #selector(editingDidEnd), for: .touchUpOutside)
        self.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
        return placeholderText
    }
    
    private func replaceWithPlaceholderLabel(text placeholderText: String?) {
        placeholderLabel = UILabel()
        
        placeholderLabel?.numberOfLines = 1
        placeholderLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        placeholderLabel?.font = self.font
        placeholderLabel?.text = placeholderText
        placeholderLabel?.textColor = placeholderColor
        
        placeholderLabel?.sizeToFit()
        
        self.addSubview(placeholderLabel!)
        placeholderLabel?.frame = self.textRect(forBounds: self.bounds)
        placeholderLabel?.frame.size.width = placeholderText?.width(forFont: self.font!) ?? self.frame.width
        
        self.placeholder = ""
    }
    
    private func placeholderAnimateIn() {
        UIView.animate(withDuration: 0.23) {
            switch self.placeholderDirection {
            case .top: self.placeholderLabel?.transform = CGAffineTransform.init(translationX: 0, y: -((self.placeholderLabel?.frame.height)! - (self.placeholderLabel?.frame.origin.x)!/2.62))
            case .left:
                self.placeholderLabel?.transform = CGAffineTransform.init(translationX: -((self.placeholderLabel?.frame.width)! + (self.placeholderLabel?.frame.origin.x)!*2), y: 0)
            case .none: break
            }
        }
    }
    
    private func placeholderAnimateOut() {
        UIView.animate(withDuration: 0.23) {
            self.placeholderLabel?.transform = CGAffineTransform.identity
        }
    }
}
