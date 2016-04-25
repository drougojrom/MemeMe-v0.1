//
//  ViewController.swift
//  preMeme
//
//  Created by Roman Ustiantcev on 25/04/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    let imagePicker = UIImagePickerController()
    var defaultTextTop = "TOP"
    var defaultTextBottom = "BOTTOM"
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.whiteColor(),
        NSForegroundColorAttributeName : UIColor.blackColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -2.0
    ]
    
    struct Meme {
        let topMemeText: String
        let bottomMemeText: String
        let image: UIImage
        let memedImage: UIImage
    }

    @IBAction func pickImageFromLibrary(sender: UIBarButtonItem) {
        
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImage(sender: UIBarButtonItem) {
        imagePicker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            cameraButton.enabled = true
            imagePicker.sourceType = .Camera
        }
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func shareMemes(sender: UIBarButtonItem) {
        
        let textToShare: String = "Look at that!"
        let objectsToShare = [textToShare];
        let controller = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        let excludedActivities = [
                                  UIActivityTypeMessage,
                                  UIActivityTypePostToVimeo,
                                  UIActivityTypePostToTwitter,
                                  UIActivityTypePostToFacebook]
        
        controller.excludedActivityTypes = [UIActivityTypeSaveToCameraRoll, UIActivityTypePostToTwitter, UIActivityTypeAddToReadingList]
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func toolBarVisible(visible: Bool){
        toolBar.hidden = !visible
        navigationBar.hidden = !visible
        
    }
    
    func generateMemedImage() -> UIImage {
        
        // hide toolbar and navbar
        toolBarVisible(false)
        
        // render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // showtoolbar and navbar
        toolBarVisible(true)
        
        return memedImage
    }
    
    func save(memedImage: UIImage){
        // create the meme
        let meme = Meme(topMemeText: topTextField.text!, bottomMemeText: bottomTextField.text!, image: imageView.image!, memedImage: memedImage)
    }
    
    // MARK : - delegates
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFit
            imageView.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.CGRectValue().height
    }
    
    // MARK : - override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frameRectTop: CGRect = topTextField.frame
        var frameRectBottom: CGRect = bottomTextField.frame
        
        frameRectTop.size.height = 100
        frameRectBottom.size.height = 100
        
        bottomTextField.frame = frameRectBottom
        topTextField.frame = frameRectTop
        
        // Do any additional setup after loading the view, typically from a nib.
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textColor = UIColor.blackColor()
        topTextField.textAlignment = .Center
        topTextField.text = defaultTextTop
        
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textColor = UIColor.blackColor()
        bottomTextField.textAlignment = .Center
        bottomTextField.text = defaultTextBottom
        
        imagePicker.delegate = self
        topTextField.delegate = self
        bottomTextField.delegate = self
    }
    
    func subscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func subscribeToKeyboardNotificationsHide(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        subscribeToKeyboardNotifications()
        subscribeToKeyboardNotificationsHide()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(true)
        
        unSubscribeFromKeyboardNotifications()
        unSubscribeFromKeyboardNotificationsHide()
    }
    
    func unSubscribeFromKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func unSubscribeFromKeyboardNotificationsHide(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification){
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(notification: NSNotification){
        view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    // MARK : - TextFieldDelagate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }


}

