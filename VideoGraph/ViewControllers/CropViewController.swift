//
//  CropViewController.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import CRRulerControl

class CropViewController: UIViewController {
    var bLoadedView: Bool = false
    var originalImage: UIImage? = nil
    
    @IBOutlet weak var m_viewTopOptions: UIView!
    @IBOutlet weak var m_btnLock: UIButton!
    @IBOutlet weak var m_btnUnlock: UIButton!
    
    @IBOutlet weak var m_btnCropRotate: UIButton!
    @IBOutlet weak var m_btnFlipHorizontal: UIButton!
    @IBOutlet weak var m_btnSetupRatio: UIButton!

    @IBOutlet weak var m_ruler: CRRulerControl!
    
    @IBOutlet weak var m_viewCropCanvas: UIView!
    
    var bLockMode: Bool = true
    
    var tweakViewCon: CropSubViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.edgesForExtendedLayout = UIRectEdge()
        
        addCropView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        InterfaceManager.makeRadiusControl(self.m_viewTopOptions, cornerRadius: 0.0, withColor: UIColor.black, borderSize: 2.0)

        if (bLoadedView) {
            return
        }
        
        bLoadedView = true
        makeUserInterface()
    }
    
    func makeUserInterface() {
        showLockMode()
        
        if (TheVideoEditor.cropSettings.bUpdated) {
            self.m_ruler.setValue(IGRRadianAngle.toDegrees(TheVideoEditor.cropSettings.angle), animated: false)
        }
    }
    
    func addCropView() {
        self.tweakViewCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewIDs.CropSubViewController) as? CropSubViewController
        self.tweakViewCon?.delegate = self
        self.tweakViewCon?.image = self.originalImage
        self.addChild(tweakViewCon!)
        self.m_viewCropCanvas.addSubview(tweakViewCon!.view)
        tweakViewCon!.didMove(toParent: self)
    }
    
    func showLockMode() {
        if (bLockMode) {
            self.m_btnLock.backgroundColor = UIColor.black
            self.m_btnLock.setImage(UIImage(named: Constants.LockOptionIcons.LockSelected), for: .normal)
            
            self.m_btnUnlock.backgroundColor = UIColor.white
            self.m_btnUnlock.setImage(UIImage(named: Constants.LockOptionIcons.Unlock), for: .normal)
        } else {
            self.m_btnLock.backgroundColor = UIColor.white
            self.m_btnLock.setImage(UIImage(named: Constants.LockOptionIcons.Lock), for: .normal)
            
            self.m_btnUnlock.backgroundColor = UIColor.black
            self.m_btnUnlock.setImage(UIImage(named: Constants.LockOptionIcons.UnlockSelected), for: .normal)
        }
        
        if (self.tweakViewCon != nil) {
            self.tweakViewCon!.doLockRatio(bLockMode)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func rulerValueChanged(_ sender: CRRulerControl) {
        if (self.tweakViewCon != nil) {
            self.tweakViewCon!.doRotate(sender.value)
        }
    }
    
    @IBAction func actionClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionRestore(_ sender: Any) {
        self.tweakViewCon!.doReset()
    }
    
    @IBAction func actionDone(_ sender: Any) {
        self.tweakViewCon!.doCrop()
    }
    
    @IBAction func actionLock(_ sender: Any) {
        bLockMode = true
        showLockMode()
    }
    
    @IBAction func actionUnlock(_ sender: Any) {
        bLockMode = false
        showLockMode()
    }

    @IBAction func actionCropRotate(_ sender: Any) {
        self.tweakViewCon!.doRotateBy90()
    }

    @IBAction func actionFlipHorizontal(_ sender: Any) {
        self.tweakViewCon!.doFlip()
    }

    @IBAction func actionSetupRatio(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        
        actionSheet.addAction(UIAlertAction(title: "Original", style: .default) { (action) in
            self.tweakViewCon!.doSetupRatio()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Squere", style: .default) { (action) in
            self.tweakViewCon!.doSetupRatio(false, "1:1")
        })

        actionSheet.addAction(UIAlertAction(title: "16:10", style: .default) { (action) in
            self.tweakViewCon!.doSetupRatio(false, "16:10")
        })
        
        actionSheet.addAction(UIAlertAction(title: "10:16", style: .default) { (action) in
            self.tweakViewCon!.doSetupRatio(false, "10:16")
        })
        
        actionSheet.addAction(UIAlertAction(title: "16:9", style: .default) { (action) in
            self.tweakViewCon!.doSetupRatio(false, "16:9")
        })
        
        actionSheet.addAction(UIAlertAction(title: "9:16", style: .default) { (action) in
            self.tweakViewCon!.doSetupRatio(false, "9:16")
        })
        
        actionSheet.addAction(UIAlertAction(title: "5:4", style: .default) { (action) in
            self.tweakViewCon!.doSetupRatio(false, "5:4")
        })

        actionSheet.addAction(UIAlertAction(title: "4:5", style: .default) { (action) in
            self.tweakViewCon!.doSetupRatio(false, "4:5")
        })
        
        actionSheet.addAction(UIAlertAction(title: "4:3", style: .default) { (action) in
            self.tweakViewCon!.doSetupRatio(false, "4:3")
        })
        
        actionSheet.addAction(UIAlertAction(title: "3:4", style: .default) { (action) in
            self.tweakViewCon!.doSetupRatio(false, "3:4")
        })
        
        actionSheet.addAction(UIAlertAction(title: "3:2", style: .default) { (action) in
            self.tweakViewCon!.doSetupRatio(false, "3:2")
        })
        
        actionSheet.addAction(UIAlertAction(title: "2:3", style: .default) { (action) in
            self.tweakViewCon!.doSetupRatio(false, "2:3")
        })

        actionSheet.addAction(UIAlertAction(title: "Instagram Stories", style: .default) { (action) in
            self.tweakViewCon!.doSetupRatio(false, "9:16")
        })

        actionSheet.addAction(UIAlertAction(title: "Snapchat", style: .default) { (action) in
            self.tweakViewCon!.doSetupRatio(false, "9:16")
        })

        actionSheet.addAction(UIAlertAction(title: "Facebook Cover Video", style: .default) { (action) in
            self.tweakViewCon!.doSetupRatio(false, "410:231")
        })

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true, completion: nil)
    }
}

extension CropViewController: IGRPhotoTweakViewControllerDelegate {
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage, entireTransform: CGAffineTransform, cropSize: CGSize, imageViewSize: CGSize, fliped: Bool, angle: CGFloat, rotateCnt: Int, contentViewFrame: CGRect, scrollViewFrame: CGRect, scrollViewContentOffset: CGPoint) {
        TheVideoEditor.priorCropSettings = TheVideoEditor.cropSettings
        
        TheVideoEditor.cropSettings.update(entireTransform, cropSize, imageViewSize, fliped, angle, rotateCnt, contentViewFrame, scrollViewFrame, scrollViewContentOffset)
        //TheVideoEditor.stillImage = croppedImage
        
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.CroppedVideo), object: nil, userInfo: nil)
        }
    }
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        print("crop cancelled")
    }
}

