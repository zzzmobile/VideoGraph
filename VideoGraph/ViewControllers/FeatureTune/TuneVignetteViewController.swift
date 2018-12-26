//
//  TuneVignetteViewController.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class TuneVignetteViewController: UIViewController, RulerSliderViewDelegate {
    var bLoadedView: Bool = false

    @IBOutlet weak var m_lblIntensityValue: UILabel!
    @IBOutlet weak var m_lblRadiusValue: UILabel!

    @IBOutlet weak var m_viewIntensitySlider: UIView!
    @IBOutlet weak var m_viewRadiusSlider: UIView!

    @IBOutlet weak var m_btnReset: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.edgesForExtendedLayout = UIRectEdge()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        InterfaceManager.makeRadiusControl(self.m_btnReset, cornerRadius: 2.0, withColor: UIColor.black, borderSize: 2.0)
        
        if (bLoadedView) {
            return
        }
        
        bLoadedView = true
        
        makeUserInterface()
        
        self.view.layoutIfNeeded()
    }
    
    func makeUserInterface() {
        let intensitySlider = RulerSliderView(frame: self.m_viewIntensitySlider.bounds, minValue: -1.0, maxValue: 1.0, curValue: TheVideoEditor.editSettings.intensity, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
        intensitySlider.delegate = self
        intensitySlider.tag = 10
        self.m_viewIntensitySlider.addSubview(intensitySlider)
        self.m_lblIntensityValue.text = String(format: "%.02f", TheVideoEditor.editSettings.intensity)
        
        let radiusSlider = RulerSliderView(frame: self.m_viewRadiusSlider.bounds, minValue: 0.0, maxValue: 2.0, curValue: TheVideoEditor.editSettings.radius, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
        radiusSlider.delegate = self
        radiusSlider.tag = 11
        self.m_viewRadiusSlider.addSubview(radiusSlider)
        self.m_lblRadiusValue.text = String(format: "%.02f", TheVideoEditor.editSettings.radius)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func rulerChanged(_ view: RulerSliderView, _ value: CGFloat, _ bTouchFinished: Bool) {
        if (view.tag == 10) {
            self.m_lblIntensityValue.text = String(format: "%.02f", value)
            
            TheVideoEditor.editSettings.intensity = value
        } else {
            self.m_lblRadiusValue.text = String(format: "%.02f", value)
            
            TheVideoEditor.editSettings.radius = value
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        
        if (bTouchFinished) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
        }
    }
    
    func rulerValueChangedForShow(_ view: RulerSliderView, _ value: CGFloat) {
        if (view.tag == 10) {
            self.m_lblIntensityValue.text = String(format: "%.02f", value)
        } else {
            self.m_lblRadiusValue.text = String(format: "%.02f", value)
        }
    }
    
    @IBAction func actionResetAdjustment(_ sender: Any) {
        TheVideoEditor.bChangedTint = false
        TheVideoEditor.bChangedTemperature = false
        TheVideoEditor.bChangedToneCurve = false
        
        TheVideoEditor.editSettings.resetAdjustment()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)

        if let intensitySlider = self.m_viewIntensitySlider.viewWithTag(10) as? RulerSliderView {
            intensitySlider.setCurrentValue(TheVideoEditor.editSettings.intensity)
            self.m_lblIntensityValue.text = String(format: "%.02f", 0.0)
        }
        
        if let radiusSlider = self.m_viewRadiusSlider.viewWithTag(11) as? RulerSliderView {
            radiusSlider.setCurrentValue(TheVideoEditor.editSettings.radius)
            self.m_lblRadiusValue.text = String(format: "%.02f", 0.0)
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
