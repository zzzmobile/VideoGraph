//
//  TuneLightViewController.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class TuneLightViewController: UIViewController, RulerSliderViewDelegate {
    var bLoadedView: Bool = false

    @IBOutlet weak var m_lblExposureValue: UILabel!
    @IBOutlet weak var m_lblBrightnessValue: UILabel!
    @IBOutlet weak var m_lblContrastValue: UILabel!

    @IBOutlet weak var m_viewExposureSlider: UIView!
    @IBOutlet weak var m_viewBrightnessSlider: UIView!
    @IBOutlet weak var m_viewContrastSlider: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.edgesForExtendedLayout = UIRectEdge()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (bLoadedView) {
            return
        }
        
        bLoadedView = true
        
        makeUserInterface()
        
        self.view.layoutIfNeeded()
    }
    
    func makeUserInterface() {
        let exposureSlider = RulerSliderView(frame: self.m_viewExposureSlider.bounds, minValue: -3.0, maxValue: 3.0, curValue: TheVideoEditor.editSettings.exposure, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
        exposureSlider.delegate = self
        exposureSlider.tag = 10
        self.m_viewExposureSlider.addSubview(exposureSlider)
        self.m_lblExposureValue.text = String(format: "%.02f", TheVideoEditor.editSettings.exposure)
        
        let brightnessSlider = RulerSliderView(frame: self.m_viewBrightnessSlider.bounds, minValue: -0.5, maxValue: 0.5, curValue: TheVideoEditor.editSettings.brightness, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
        brightnessSlider.delegate = self
        brightnessSlider.tag = 11
        self.m_viewBrightnessSlider.addSubview(brightnessSlider)
        self.m_lblBrightnessValue.text = String(format: "%.02f", TheVideoEditor.editSettings.brightness)
        
        let contrastSlider = RulerSliderView(frame: self.m_viewContrastSlider.bounds, minValue: 0.8, maxValue: 1.2, curValue: TheVideoEditor.editSettings.contrast, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
        contrastSlider.delegate = self
        contrastSlider.tag = 12
        self.m_viewContrastSlider.addSubview(contrastSlider)
        self.m_lblContrastValue.text = String(format: "%.02f", TheVideoEditor.editSettings.contrast)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func rulerChanged(_ view: RulerSliderView, _ value: CGFloat, _ bTouchFinished: Bool) {
        if (view.tag == 10) {
            self.m_lblExposureValue.text = String(format: "%.02f", value)
            
            TheVideoEditor.editSettings.exposure = value
        } else if (view.tag == 11) {
            self.m_lblBrightnessValue.text = String(format: "%.02f", value)
            
            TheVideoEditor.editSettings.brightness = value
        } else {
            self.m_lblContrastValue.text = String(format: "%.02f", value)
            
            TheVideoEditor.editSettings.contrast = value
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        
        if (bTouchFinished) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
        }
    }
    
    func rulerValueChangedForShow(_ view: RulerSliderView, _ value: CGFloat) {
        if (view.tag == 10) {
            self.m_lblExposureValue.text = String(format: "%.02f", value)
        } else if (view.tag == 11) {
            self.m_lblBrightnessValue.text = String(format: "%.02f", value)
        } else {
            self.m_lblContrastValue.text = String(format: "%.02f", value)
        }
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
