//
//  RichEditorToolbar.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit

/// RichEditorToolbarDelegate is a protocol for the RichEditorToolbar.
/// Used to receive actions that need extra work to perform (eg. display some UI)
@objc public protocol RichEditorToolbarDelegate: class {
    
    /// Called when the Text Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar)
    
    /// Called when the Background Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar)
    
    /// Called when the Insert Image toolbar item is pressed.
    @objc optional func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar)
    
    /// Called when the Insert Link toolbar item is pressed.
    @objc optional func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar)
}

/// RichBarButtonItem is a subclass of UIBarButtonItem that takes a callback as opposed to the target-action pattern
@objcMembers open class RichBarButtonItem: UIBarButtonItem {
    open var actionHandler: (() -> Void)?
    open var optionTitle: String = ""
    let optionsExcludedForHighlight = ["Clear", "Undo", "Redo", "Indent", "Outdent", "Image", "Link", "HideKeyboard"]
    let inactiveOptionColor: UIColor = UIColor.darkGray
    let activeOptionColor: UIColor = UIColor.orange
    
    public convenience init(image: UIImage? = nil, imgTitle: String = "", handler: (() -> Void)? = nil) {
        self.init(image: image, style: .plain, target: nil, action: nil)
        self.width = 33
        target = self
        action = #selector(RichBarButtonItem.buttonWasTapped)
        actionHandler = handler
        optionTitle = imgTitle
    }
    
    public convenience init(title: String = "", handler: (() -> Void)? = nil) {
        self.init(title: title, style: .plain, target: nil, action: nil)
        self.width = 33
        target = self
        action = #selector(RichBarButtonItem.buttonWasTapped)
        actionHandler = handler
        optionTitle = title
    }
    
    /* Change color of option when pressed (excluding options listed in optionsExcluded) */
    @objc func buttonWasTapped() {
        actionHandler?()
        //        if(!optionsExcludedForHighlight.contains(self.optionTitle)) {
        //            if(self.tintColor!.isEqual(activeOptionColor)) {
        //                self.tintColor = inactiveOptionColor
        //            } else {
        //                self.tintColor = activeOptionColor
        //            }
        //        }
    }
    
    /* Change color of option depending if current text contains applied option */
    func updateColor(applied: Bool) {
        if(applied) {
            self.tintColor = activeOptionColor
        } else {
            self.tintColor = inactiveOptionColor
        }
    }
}

/// RichEditorToolbar is UIView that contains the toolbar for actions that can be performed on a RichEditorView
@objcMembers open class RichEditorToolbar: UIView {

    /* Toolbar and toolbar icon's measurements */
    let toolbarHeight: CGFloat = 44
    let defaultIconWidth: CGFloat = 33
    let barButtonItemMargin: CGFloat = 11
    
    /// The delegate to receive events that cannot be automatically completed
    open weak var delegate: RichEditorToolbarDelegate?
    
    /// A reference to the RichEditorView that it should be performing actions on
    open weak var editor: RichEditorView?
    
    open var doubleRows:Bool = false {
        didSet {
            if(doubleRows) {
                updateSecondaryToolbar()
            }
        }
    }
    
    /// The list of options to be displayed on the toolbar
    open var options: [RichEditorOption] = [] {
        didSet {
            updateToolbar()
        }
    }
    
    open var secondaryOptions: [RichEditorOption] = [] {
        didSet {
            if(doubleRows) {
                updateSecondaryToolbar()
            }
        }
    }
    
    /// The tint color to apply to the toolbar background.
    open var barTintColor: UIColor? {
        get { return backgroundToolbar.barTintColor }
        set { backgroundToolbar.barTintColor = newValue }
    }
    
    private var toolbarScroll: UIScrollView
    private var toolbar: UIToolbar
    private var secondaryToolbar:UIToolbar
    private var backgroundToolbar: UIToolbar
    
    public override init(frame: CGRect) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        secondaryToolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        secondaryToolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        autoresizingMask = .flexibleWidth
        backgroundColor = .clear
        
        backgroundToolbar.frame = bounds
        backgroundToolbar.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        toolbar.autoresizingMask = .flexibleWidth
        toolbar.backgroundColor = .clear
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        secondaryToolbar.autoresizingMask = .flexibleWidth
        secondaryToolbar.backgroundColor = .clear
        secondaryToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        secondaryToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        toolbarScroll.frame = bounds
        toolbarScroll.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        toolbarScroll.showsHorizontalScrollIndicator = false
        toolbarScroll.showsVerticalScrollIndicator = false
        toolbarScroll.backgroundColor = .clear
        
        toolbarScroll.addSubview(toolbar)
        toolbarScroll.addSubview(secondaryToolbar)
        
        addSubview(backgroundToolbar)
        addSubview(toolbarScroll)
        updateToolbar()
    }
    
    private func updateToolbar() {
        var buttons = [UIBarButtonItem]()
        for option in options {
            let handler = { [weak self] in
                if let strongSelf = self {
                    option.action(strongSelf)
                }
            }
            
            let title = option.title
            if let image = option.image {
                let button = RichBarButtonItem(image: image, imgTitle: title, handler: handler)
                button.tintColor = UIColor.darkGray
                buttons.append(button)
            } else {
                let button = RichBarButtonItem(title: title, handler: handler)
                button.tintColor = UIColor.darkGray
                buttons.append(button)
            }
        }
        toolbar.items = buttons
        
        let width: CGFloat = buttons.reduce(0) {sofar, new in
            if let view = new.value(forKey: "view") as? UIView {
                return sofar + view.frame.size.width + barButtonItemMargin
            } else {
                return sofar + (defaultIconWidth + barButtonItemMargin)
            }
        }
        
        if width < frame.size.width {
            toolbar.frame.size.width = frame.size.width
        } else {
            toolbar.frame.size.width = width
        }
        toolbar.frame.size.height = toolbarHeight
        toolbarScroll.contentSize.width = width
    }
    
    /* Updates the toolbar by highlighting the options according to the currently applied styles  */
    public func updateToolbar(appliedStyles: [String]) {
        var buttons = [UIBarButtonItem]()
        for option in options {
            let handler = { [weak self] in
                if let strongSelf = self {
                    option.action(strongSelf)
                }
            }
            
            let title: String = option.title
            let isButtonApplied: Bool = appliedStyles.contains(title)
            
            if let image = option.image {
                let button = RichBarButtonItem(image: image, imgTitle: title, handler: handler)
                button.updateColor(applied: isButtonApplied)
                buttons.append(button)
            } else {
                let button = RichBarButtonItem(title: title, handler: handler)
                button.updateColor(applied: isButtonApplied)
                buttons.append(button)
            }
        }
        toolbar.items = buttons
        
        let width: CGFloat = buttons.reduce(0) {sofar, new in
            if let view = new.value(forKey: "view") as? UIView {
                return sofar + view.frame.size.width + barButtonItemMargin
            } else {
                return sofar + (defaultIconWidth + barButtonItemMargin)
            }
        }
        
        if width < frame.size.width {
            toolbar.frame.size.width = frame.size.width
        } else {
            toolbar.frame.size.width = width
        }
        toolbar.frame.size.height = toolbarHeight
        toolbarScroll.contentSize.width = width
    }
    
    private func updateSecondaryToolbar() {
        var secondaryButtons = [UIBarButtonItem]()
        for option in secondaryOptions {
            let handler = { [weak self] in
                if let strongSelf = self {
                    option.action(strongSelf)
                }
            }
            
            let title = option.title
            if let image = option.image {
                let button = RichBarButtonItem(image: image, imgTitle: title, handler: handler)
                secondaryButtons.append(button)
            } else {
                let button = RichBarButtonItem(title: title, handler: handler)
                secondaryButtons.append(button)
            }
        }
        secondaryToolbar.items = secondaryButtons
        
        let defaultIconWidth: CGFloat = 22
        let barButtonItemMargin: CGFloat = 11
        let width: CGFloat = secondaryButtons.reduce(0) {sofar, new in
            if let view = new.value(forKey: "view") as? UIView {
                return sofar + view.frame.size.width + barButtonItemMargin
            } else {
                return sofar + (defaultIconWidth + barButtonItemMargin)
            }
        }
        
        if width < frame.size.width {
            secondaryToolbar.frame.size.width = frame.size.width
        } else {
            secondaryToolbar.frame.size.width = width
        }
        secondaryToolbar.frame.size.height = toolbarHeight
        secondaryToolbar.frame.origin.y = 44
    }
}
