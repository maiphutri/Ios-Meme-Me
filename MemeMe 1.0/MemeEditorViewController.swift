//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by Tri Mai on 8/29/18.
//  Copyright © 2018 Tri Mai. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController {
    
    let imagePicker = UIImagePickerController()
    
    // Setting font style and color
    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "impact", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -5.0]
    
    func configure(textField: UITextField,withText: String) {
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self
        textField.text = withText // Default value, so it's not nil
        textField.textAlignment = .center
        
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        configure(textField: topTextField, withText: "TOP")
        configure(textField: bottomTextField, withText: "BOTTOM")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        shareButton.isEnabled = !(imagePickerView.image == nil)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subsribeToKeyboardMoveUpNotifications()
        subscribeKeyboardDismissNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        unsubscribeFromKeyboardNotifications()
        unsubscribeKeyboardDismissNotification()
    }
    
    // Keyboard's Adjustment
    func subsribeToKeyboardMoveUpNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow , object: nil )
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow , object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat{
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // Dimiss Keyboard
    func subscribeKeyboardDismissNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide , object: nil)
    }
    
    func unsubscribeKeyboardDismissNotification() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide , object: nil)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if bottomTextField.isEditing {
            view.frame.origin.y = 0
        }
    }
    
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        
        sender.tag == 0 ? chooseSourceType(sourceType: .camera) :
            chooseSourceType(sourceType: .photoLibrary)
    }
    func chooseSourceType(sourceType: UIImagePickerControllerSourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePicker.sourceType = sourceType
            present(imagePicker,animated: true,completion: nil)
        }
    }
    
    @IBAction func shareImage(_ sender: Any) {
        
        let image = generateMemedImage()
        let shareMeme = UIActivityViewController(activityItems:[image], applicationActivities: nil)
        
        shareMeme.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed {
                return self.save()
            }
        }
        present(shareMeme,animated: true,completion: nil)
        
    }
    
    // Show Images from Camera or Album
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        imagePickerView.isHidden = false
        
        if let imageFromAlbum = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = imageFromAlbum
        }
        if let imageFromCamera = info[UIImagePickerControllerEditedImage] as? UIImage {
            imagePickerView.image = imageFromCamera
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    
    // TextField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 0.0
        textField.text = ""
        textField.tintColor = .green
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func toolBars(isHidden: Bool) {
        
        topToolbar.isHidden = isHidden
        bottomToolbar.isHidden = isHidden
    }
    
    func generateMemedImage() -> UIImage {
        
        toolBars(isHidden: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolBars(isHidden: false)
        
        return memedImage
    }
    
    func save() {
        
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        
        (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        
        imagePickerView.isHidden = true
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK - UIImagePickerControllerDelegate
extension MemeEditorViewController: UIImagePickerControllerDelegate {
}

//MARK - UINavigationControllerDelegate
extension MemeEditorViewController: UINavigationControllerDelegate {
}

//MARK - UITextFieldDelegate
extension MemeEditorViewController: UITextFieldDelegate {
}
