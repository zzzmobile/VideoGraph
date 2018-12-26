//
//  NewStillViewController.swift
//  VideoGraph
//
//  Created by Techsviewer on 12/2/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class NewStillViewController: UIViewController {
    var bLoadedView: Bool = false
    @IBOutlet weak var m_imgStillImage: UIImageView!
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.edgesForExtendedLayout = UIRectEdge()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showStillImage), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedStillImage), object: nil)
        
        self.imagePicker.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (bLoadedView) {
            return
        }
        
        bLoadedView = true
        
        showStillImage()
    }
    @objc func showStillImage() {
        self.m_imgStillImage.image = TheVideoEditor.stillImage
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onExport(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Export still image to ...", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Files App", style: .default, handler: {(_ acttion: UIAlertAction) -> Void in
            self.saveToFilesApp()
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(_ acttion: UIAlertAction) -> Void in
            self.saveToPhotoLibrary()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        DispatchQueue.main.async(execute: {
            self.present(actionSheet, animated: true, completion: nil)
        })
    }
    @IBAction func onImport(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Import still image from ...", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Files App", style: .default, handler: {(_ acttion: UIAlertAction) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.TappedActionInStillImage), object: nil, userInfo: nil)
            self.choosePhotoFromFilesApp()
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(_ acttion: UIAlertAction) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.TappedActionInStillImage), object: nil, userInfo: nil)
            self.choosePhotoFromLibrary()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        DispatchQueue.main.async(execute: {
            self.present(actionSheet, animated: true, completion: nil)
        })
    }
    @IBAction func onReset(_ sender: Any) {
        self.resetStillImage()
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func resetStillImage() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.ResetStillImage), object: nil, userInfo: nil)
    }
    
    func takeNewPhoto() {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func choosePhotoFromLibrary() {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func saveToPhotoLibrary() {
        UIImageWriteToSavedPhotosAlbum(self.m_imgStillImage.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil  {
            InterfaceManager.showMessage(true, title: "Saved image successfully!", bBottomPos: true)
        } else {
            InterfaceManager.showMessage(false, title: "Failed to save image into photo library!", bBottomPos: true)
        }
    }
    
    func choosePhotoFromFilesApp() {
        let controller = UIDocumentPickerViewController(documentTypes: ["public.image"], in: .import)
        controller.delegate = self
        controller.allowsMultipleSelection = false
        self.present(controller, animated: true, completion: nil)
    }
    
    func saveToFilesApp() {
        let fileMngr = FileManager.default;
        let directoryURLs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageURL = directoryURLs.appendingPathComponent("Still Image.png")
        
        let imageData = UIImagePNGRepresentation(self.m_imgStillImage.image!)
        do {
            try imageData?.write(to: imageURL)
        } catch {
            InterfaceManager.showMessage(false, title: "Failed to process image!", bBottomPos: true)
            return
        }
        
        let controller = UIDocumentPickerViewController(url: imageURL, in: .exportToService)
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }

}
extension NewStillViewController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("cancelled")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("picked")
        let chosenImage = UIImage(contentsOfFile: url.path)
        
        let resizedImage = chosenImage!.resize(TheVideoEditor.stillImage!.size)
        self.m_imgStillImage.image = resizedImage
        
        TheVideoEditor.stillImage = resizedImage
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedStillImageInSubView), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
}

extension NewStillViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let updatedImage = TheImageProcesser.changeColorSpace(chosenImage)
        
        let resizedImage = updatedImage.resize(TheVideoEditor.stillImage!.size)
        self.m_imgStillImage.image = resizedImage
        
        TheVideoEditor.stillImage = resizedImage
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedStillImageInSubView), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
