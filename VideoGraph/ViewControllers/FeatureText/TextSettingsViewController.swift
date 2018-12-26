//
//  TextSettingsViewController.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class TextSettingsViewController: UIViewController, RulerSliderViewDelegate {
    var bLoadedView: Bool = false

    @IBOutlet weak var m_segmentOptions: UISegmentedControl!
    
    @IBOutlet weak var m_btnAlignmentLeft: UIButton!
    @IBOutlet weak var m_btnAlignmentRight: UIButton!
    @IBOutlet weak var m_btnAlignmentCenter: UIButton!
    @IBOutlet weak var m_btnAlignmentJustify: UIButton!

    @IBOutlet weak var m_lblTitle1: UILabel!
    @IBOutlet weak var m_lblTitle2: UILabel!
    @IBOutlet weak var m_lblTitle3: UILabel!
    
    @IBOutlet weak var m_viewSlider1: UIView!
    @IBOutlet weak var m_viewSlider2: UIView!
    @IBOutlet weak var m_viewSlider3: UIView!

    var bShowSettings: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.edgesForExtendedLayout = UIRectEdge()
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectedFontObject), name: NSNotification.Name(rawValue: Constants.NotificationName.SelectedFontObject), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatedRotateInStickerView(_:)), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdateRotateValueInStickView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatedZoomInStickerView(_:)), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdateZoomValueInStickView), object: nil)
    }
    
    @objc func selectedFontObject() {
        showSliders()
    }
    
    @objc func updatedRotateInStickerView(_ notiInfo: Notification) {
        if let rotateValue = notiInfo.userInfo?["value"] as? CGFloat {
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_rotation = rotateValue
            
            if let slider = self.m_viewSlider2.viewWithTag(21) as? RulerSliderView {
                slider.setCurrentValue(rotateValue)
            }
        }
    }
    
    @objc func updatedZoomInStickerView(_ notiInfo: Notification) {
        if let zoomValue = notiInfo.userInfo?["value"] as? CGFloat {
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_in_zoom = zoomValue
            
            if let slider = self.m_viewSlider3.viewWithTag(22) as? RulerSliderView {
                slider.setCurrentValue(zoomValue)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (bLoadedView) {
            return
        }
        
        bLoadedView = true
        
        showSliders()
    }
    
    func removeSliders() {
        if let slider = self.m_viewSlider1.viewWithTag(10) as? RulerSliderView {
            slider.removeFromSuperview()
        }

        if let slider = self.m_viewSlider1.viewWithTag(20) as? RulerSliderView {
            slider.removeFromSuperview()
        }

        if let slider = self.m_viewSlider2.viewWithTag(11) as? RulerSliderView {
            slider.removeFromSuperview()
        }
        
        if let slider = self.m_viewSlider2.viewWithTag(21) as? RulerSliderView {
            slider.removeFromSuperview()
        }

        if let slider = self.m_viewSlider3.viewWithTag(12) as? RulerSliderView {
            slider.removeFromSuperview()
        }
        
        if let slider = self.m_viewSlider3.viewWithTag(22) as? RulerSliderView {
            slider.removeFromSuperview()
        }
    }
    
    @objc func showSliders() {
        removeSliders()

        let bEnabledSlider = (TheVideoEditor.selectedFontObjectIdx == -1 ? false : true)

        if (bShowSettings) {
            self.m_lblTitle1.text = "Text Size"
            let curTextSize = (TheVideoEditor.selectedFontObjectIdx == -1 ? 20.0 : TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_size)
            let textSizeSlider = RulerSliderView(frame: self.m_viewSlider1.bounds, minValue: 8.0, maxValue: 100.0, curValue: curTextSize, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
            textSizeSlider.delegate = self
            textSizeSlider.bEnabled = bEnabledSlider
            textSizeSlider.tag = 10
            self.m_viewSlider1.addSubview(textSizeSlider)
            
            self.m_lblTitle2.text = "Character Spacing"
            let curCharacterSpacing = (TheVideoEditor.selectedFontObjectIdx == -1 ? 0.0 : TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.character_spacing)
            let characterSpacingSlider = RulerSliderView(frame: self.m_viewSlider2.bounds, minValue: 0.0, maxValue: 10.0, curValue: curCharacterSpacing, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
            characterSpacingSlider.delegate = self
            characterSpacingSlider.bEnabled = bEnabledSlider
            characterSpacingSlider.tag = 11
            self.m_viewSlider2.addSubview(characterSpacingSlider)
            
            self.m_lblTitle3.text = "Line Spacing"
            let curLineCharacterSpacing = (TheVideoEditor.selectedFontObjectIdx == -1 ? 1.15 : TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.line_spacing)
            let lineSpacingSlider = RulerSliderView(frame: self.m_viewSlider3.bounds, minValue: 0.0, maxValue: 10.0, curValue: curLineCharacterSpacing, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
            lineSpacingSlider.delegate = self
            lineSpacingSlider.bEnabled = bEnabledSlider
            lineSpacingSlider.tag = 12
            self.m_viewSlider3.addSubview(lineSpacingSlider)
        } else {
            self.m_lblTitle1.text = "Text Prospective"
            let curTextProspective = (TheVideoEditor.selectedFontObjectIdx == -1 ? 0.0 : TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_prospective)
            let prospectiveSlider = RulerSliderView(frame: self.m_viewSlider1.bounds, minValue: 0.0, maxValue: 10.0, curValue: curTextProspective, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
            prospectiveSlider.delegate = self
            prospectiveSlider.bEnabled = bEnabledSlider
            prospectiveSlider.tag = 20
            self.m_viewSlider1.addSubview(prospectiveSlider)
            
            self.m_lblTitle2.text = "Text Rotation"
            let curTextRotation = (TheVideoEditor.selectedFontObjectIdx == -1 ? 0.0 : TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_rotation)
            let rotationSlider = RulerSliderView(frame: self.m_viewSlider2.bounds, minValue: -360.0, maxValue: 360.0, curValue: curTextRotation, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
            rotationSlider.delegate = self
            rotationSlider.bEnabled = bEnabledSlider
            rotationSlider.tag = 21
            self.m_viewSlider2.addSubview(rotationSlider)
            
            self.m_lblTitle3.text = "Text In Zoom"
            let curTextZoom = (TheVideoEditor.selectedFontObjectIdx == -1 ? 4.0 : TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_in_zoom)
            let zoomSlider = RulerSliderView(frame: self.m_viewSlider3.bounds, minValue: 0.2, maxValue: 10.0, curValue: curTextZoom, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
            zoomSlider.delegate = self
            zoomSlider.bEnabled = bEnabledSlider
            zoomSlider.tag = 22
            self.m_viewSlider3.addSubview(zoomSlider)
        }
    }
    
    func rulerChanged(_ view: RulerSliderView, _ value: CGFloat, _ bTouchFinished: Bool) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        
        if (view.tag == 10) {
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_size = value
        } else if (view.tag == 11) {
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.character_spacing = value
        } else if (view.tag == 12) {
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.line_spacing = value
        } else if (view.tag == 20) {
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_prospective = value
        } else if (view.tag == 21) {
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_rotation = value
        } else {
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_in_zoom = value
        }
        
        if (view.tag <= 20) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.RotateZoomText), object: nil, userInfo: nil)
        }
        
        if (bTouchFinished) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
        }
    }
    
    func rulerValueChangedForShow(_ view: RulerSliderView, _ value: CGFloat) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func optionChanged(_ sender: UISegmentedControl) {
        self.bShowSettings = self.m_segmentOptions.selectedSegmentIndex == 0 ? true : false
        showSliders()
    }
    
    @IBAction func actionChooseAlignmentLeft(_ sender: Any) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_aligment = .Left
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
    }
    
    @IBAction func actionChooseAlignmentRight(_ sender: Any) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_aligment = .Right
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
    }

    @IBAction func actionChooseAlignmentCenter(_ sender: Any) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_aligment = .Center
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
    }

    @IBAction func actionChooseAlignmentJustify(_ sender: Any) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        
        TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.text_aligment = .Justify
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
