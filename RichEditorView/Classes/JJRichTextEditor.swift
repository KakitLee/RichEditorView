//
//  JJRichTextEditor.swift
//  RichEditorViewSample
//
//  Created by Jack on 28/8/17.
//  Copyright © 2017 Caesar Wirth. All rights reserved.
//
import UIKit
import IGColorPicker
import RichEditorView
import SCLAlertView

enum ColorEditMode {
    case background
    case text
}

open class JJRichTextEditor: UIView {
    
    open var maxImageSize: Int = 1000000;
    
    //Editor
    public var editorView: RichEditorView! {
        didSet {
            //Init editor
            editorView.delegate = self
            editorView.inputAccessoryView = self
            
            //Init toolbar
            toolbar.delegate = self
            toolbar.editor = editorView
            self.addSubview(toolbar)
            
            //Init Color Pickers
            textColorPickerView.layoutDelegate = self
            textColorPickerView.delegate = self
            backgroundColorPickerView.layoutDelegate = self
            backgroundColorPickerView.delegate = self
            self.addSubview(textColorPickerView)
            self.addSubview(backgroundColorPickerView)
            
            let bundle = Bundle(for: RichEditorToolbar.self)
            let keyboardOptionImage = UIImage(named: "ZSSkeyboard", in: bundle, compatibleWith: nil)
            let hideKeyboardOption = RichEditorOptionItem(image: keyboardOptionImage, title: "Hide Keyboard") { toolbar in
                self.editorView.endEditing(true)
            }
            
            var options: [RichEditorOption] = RichEditorDefaultOption.swarmToolbar
            options.insert(hideKeyboardOption, at: 0)
            toolbar.options = options
        }
    }
    public var htmlTextView: UITextView!
    
    //Color Picker
    lazy var colorDotWidth:CGFloat = {
        return self.frame.height - 10
    }()
    lazy var colorDotPadding:CGFloat = {
        return 5
    }()
    
    lazy var textColorPickerView: ColorPickerView = {
        let textColorPickerView = ColorPickerView(frame: CGRect(x:  0, y: -self.frame.height, width: self.bounds.width, height: self.frame.height))
        textColorPickerView.selectionStyle = .check
        textColorPickerView.isSelectedColorTappable = true
        return textColorPickerView
    }()
    
    lazy var backgroundColorPickerView: ColorPickerView = {
        let backgroundColorPickerView = ColorPickerView(frame: CGRect(x:  0, y: -self.frame.height, width: self.bounds.width, height: self.frame.height))
        backgroundColorPickerView.selectionStyle = .check
        backgroundColorPickerView.isSelectedColorTappable = true
        return backgroundColorPickerView
    }()
    
    public lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.frame.height))
        toolbar.options = RichEditorDefaultOption.swarmToolbar
        return toolbar
    }()
    
    /* Color picker helper variables  */
    var colorEditMode: ColorEditMode!
    var textColorPickerHidden: Bool = true
    var backgroundColorPickerHidden: Bool = true
    
    /* Image Picker */
    let imagePicker = UIImagePickerController()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.imagePicker.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func dismissColorPicker() {
        UIView.animate(withDuration: 0.3) {
            if(self.colorEditMode == .text && !self.textColorPickerHidden) {
                self.toolbar.frame.origin.y -= self.frame.height
                self.textColorPickerView.frame.origin.y -= self.frame.height
                self.textColorPickerHidden = true
            } else if(self.colorEditMode == .background && !self.backgroundColorPickerHidden){
                self.toolbar.frame.origin.y -= self.frame.height
                self.backgroundColorPickerView.frame.origin.y -= self.frame.height
                self.backgroundColorPickerHidden = true
            }
        }
    }
    
    func showColorPicker() {
        UIView.animate(withDuration: 0.3) {
            self.toolbar.frame.origin.y += self.frame.height
            if(self.colorEditMode == .text) {
                self.textColorPickerView.frame.origin.y += self.frame.height
                self.textColorPickerHidden = false
            }else if(self.colorEditMode == .background){
                self.backgroundColorPickerView.frame.origin.y += self.frame.height
                self.backgroundColorPickerHidden = false
            }
        }
    }
    
}

extension JJRichTextEditor: RichEditorDelegate {
    
    public func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        if content.isEmpty {
            htmlTextView?.text = "HTML Preview"
        } else {
            htmlTextView?.text = content
        }
    }
    
    /* Update toolbar every time an option is clicked */
    public func richEditor(_ editor: RichEditorView, handle action: String) {
        let appliedOptions = action.components(separatedBy: ",")
        //print(appliedOptions)
        toolbar.updateToolbar(appliedStyles: appliedOptions)
    }
    
}

extension JJRichTextEditor: RichEditorToolbarDelegate {
    
    
    public func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        colorEditMode = .text
        showColorPicker()
    }
    
    public func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        colorEditMode = .background
        showColorPicker()
    }
    
    public func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        self.parentViewController?.present(imagePicker, animated: true, completion: nil)
    }
    
    public func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if toolbar.editor?.hasRangeSelection == true {
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            let url = alert.addTextField("")
            url.text = "https://"
            alert.addButton("Create Link") {
                toolbar.editor?.insertLink(url.text!, title: "")
            }
            alert.addButton("Cancel") {
                alert.hideView()
            }
            editorView.endEditing(true)
            alert.showEdit("Add Link", subTitle: "Please enter the link information")
        } else {
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
            let url = alert.addTextField("")
            url.text = "https://"
            let txt = alert.addTextField("Display Text")
            alert.addButton("Create Link") {
                toolbar.editor?.insertLink(url.text!, title: txt.text!)
            }
            alert.addButton("Cancel") {
                alert.hideView()
            }
            editorView.endEditing(true)
            alert.showEdit("Add Link", subTitle: "Please enter the link information")
        }
    }
}

// MARK: - ColorPickerViewDelegate
extension JJRichTextEditor: ColorPickerViewDelegate {
    
    public func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        let color = colorPickerView.colors[indexPath.row]
        if(colorEditMode == .text) {
            toolbar.editor?.setTextColor(color)
        }else if(colorEditMode == .background){
            toolbar.editor?.setTextBackgroundColor(color)
        }
        dismissColorPicker()
    }
    
    // This is an optional method
    public func colorPickerView(_ colorPickerView: ColorPickerView, didDeselectItemAt indexPath: IndexPath) {
        if(colorEditMode == .text) {
            toolbar.editor?.setTextColor(UIColor.black)
        }else if(colorEditMode == .background){
            toolbar.editor?.setTextBackgroundColor(UIColor.white)
        }
        dismissColorPicker()
    }
    
}


// MARK: - ColorPickerViewDelegateFlowLayout
extension JJRichTextEditor: ColorPickerViewDelegateFlowLayout {
    
    public func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: colorDotWidth, height: colorDotWidth)
    }
    
    public func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return colorDotPadding
    }
    
    public func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return colorDotPadding
    }
    
}


// MARK: - ImagePicker Delegate
extension JJRichTextEditor: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true) {
            var imageData:NSData!
            
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                imageData = image.compressSize(maxSize: self.maxImageSize)!
            }
            else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                imageData = image.compressSize(maxSize: self.maxImageSize)!
            } else{
                print("Something went wrong")
            }
            /* Check if the image is still too big after compression */
            if(imageData.length > self.maxImageSize) {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: true))
                alert.showError("Error", subTitle: "Image is too large, please use a smaller sized image")
            } else {
                let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
                self.toolbar.editor?.insertImage("data:image/png;base64, " + strBase64, alt: "Gravatar")
            }
            
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

//helper function
extension JJRichTextEditor {
    public var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
        
        static let allQuality = [highest, high, medium, low, lowest]
    }
    
    /* Returns the data for the specified image in PNG format */
    var png: Data? { return UIImagePNGRepresentation(self) }
    
    /* Returns the data for the specified image after compressing into a size under the specified maximum size */
    func compressSize(maxSize: Int) -> NSData? {
        let originalImageData = UIImageJPEGRepresentation(self, 1)! as NSData
        
        for quality in JPEGQuality.allQuality {
            let imageData = UIImageJPEGRepresentation(self, quality.rawValue)! as NSData
            if(imageData.length < maxSize) {
                return imageData
            }
        }
        return originalImageData
    }
}

