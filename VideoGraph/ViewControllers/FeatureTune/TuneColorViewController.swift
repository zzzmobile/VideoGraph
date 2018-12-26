//
//  TuneColorViewController.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class TuneColorViewController: UIViewController, RulerSliderViewDelegate {
    var bLoadedView: Bool = false

    @IBOutlet weak var m_lblTempValue: UILabel!
    @IBOutlet weak var m_lblTineValue: UILabel!
    @IBOutlet weak var m_lblSaturationValue: UILabel!
    
    @IBOutlet weak var m_viewTempSlider: UIView!
    @IBOutlet weak var m_viewTineSlider: UIView!
    @IBOutlet weak var m_viewSaturationSlider: UIView!
    
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
        let tempSlider = RulerSliderView(frame: self.m_viewTempSlider.bounds, minValue: -10.0, maxValue: 10.0, curValue: TheVideoEditor.editSettings.temperature, activeImageName: Constants.SliderImage.Active_Temp, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
        tempSlider.delegate = self
        tempSlider.tag = 10
        self.m_viewTempSlider.addSubview(tempSlider)
        self.m_lblTempValue.text = String(format: "%.02f", TheVideoEditor.editSettings.temperature)
        
        let tineSlider = RulerSliderView(frame: self.m_viewTineSlider.bounds, minValue: -10.0, maxValue: 10.0, curValue: TheVideoEditor.editSettings.tint, activeImageName: Constants.SliderImage.Active_Tint, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
        tineSlider.delegate = self
        tineSlider.tag = 11
        self.m_viewTineSlider.addSubview(tineSlider)
        self.m_lblTineValue.text = String(format: "%.02f", TheVideoEditor.editSettings.tint)

        let saturationSlider = RulerSliderView(frame: self.m_viewSaturationSlider.bounds, minValue: 0.0, maxValue: 2.0, curValue: TheVideoEditor.editSettings.saturation, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
        saturationSlider.delegate = self
        saturationSlider.tag = 12
        self.m_viewSaturationSlider.addSubview(saturationSlider)
        self.m_lblSaturationValue.text = String(format: "%.02f", TheVideoEditor.editSettings.saturation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func rulerChanged(_ view: RulerSliderView, _ value: CGFloat, _ bTouchFinished: Bool) {
        if (view.tag == 10) {
            self.m_lblTempValue.text = String(format: "%.02f", value)
            
            TheVideoEditor.editSettings.temperature = value
            if (TheVideoEditor.editSettings.temperature == 0.0) {
                TheVideoEditor.bChangedTemperature = false
            } else {
                TheVideoEditor.bChangedTemperature = true
            }
        } else if (view.tag == 11) {
            self.m_lblTineValue.text = String(format: "%.02f", value)
            
            TheVideoEditor.editSettings.tint = value
            if (TheVideoEditor.editSettings.tint == 0.0) {
                TheVideoEditor.bChangedTint = false
            } else {
                TheVideoEditor.bChangedTint = true
            }
        } else {
            self.m_lblSaturationValue.text = String(format: "%.02f", value)
            
            TheVideoEditor.editSettings.saturation = value
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        
        if (bTouchFinished) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
        }
    }
    
    func rulerValueChangedForShow(_ view: RulerSliderView, _ value: CGFloat) {
        if (view.tag == 10) {
            self.m_lblTempValue.text = String(format: "%.02f", value)
        } else if (view.tag == 11) {
            self.m_lblTineValue.text = String(format: "%.02f", value)
        } else {
            self.m_lblSaturationValue.text = String(format: "%.02f", value)
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
