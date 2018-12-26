//
//  TuneToneCurveViewController.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class TuneToneCurveViewController: UIViewController, RulerSliderViewDelegate {
    var bLoadedView: Bool = false

    @IBOutlet weak var m_segmentColorOptions: UISegmentedControl!
    
    @IBOutlet weak var m_lblBlacksValue: UILabel!
    @IBOutlet weak var m_lblShadowsValue: UILabel!
    @IBOutlet weak var m_lblHighlightsValue: UILabel!
    @IBOutlet weak var m_lblWhitesValue: UILabel!

    @IBOutlet weak var m_viewBlacksSlider: UIView!
    @IBOutlet weak var m_viewShadowsSlider: UIView!
    @IBOutlet weak var m_viewHighlightsSlider: UIView!
    @IBOutlet weak var m_viewWhitesSlider: UIView!

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
        
        self.m_segmentColorOptions.selectedSegmentIndex = TheVideoEditor.editSettings.toneCurveMode.rawValue
        
        makeUserInterface()
        
        self.view.layoutIfNeeded()
    }
    
    func makeUserInterface() {
        removeSliders()
        
        var sliderActiveImage: String = Constants.SliderImage.Active
        var currentBlacksVal: CGFloat = 0.0
        var currentShadowsVal: CGFloat = 0.0
        var currentHighlightsVal: CGFloat = 0.0
        var currentWhitesVal: CGFloat = 0.0

        switch TheVideoEditor.editSettings.toneCurveMode {
        case .R:
            sliderActiveImage = Constants.SliderImage.Active_Red
            currentBlacksVal = TheVideoEditor.editSettings.blacks_r
            currentShadowsVal = TheVideoEditor.editSettings.shadows_r
            currentHighlightsVal = TheVideoEditor.editSettings.highlights_r
            currentWhitesVal = TheVideoEditor.editSettings.whites_r
            break
        case .G:
            sliderActiveImage = Constants.SliderImage.Active_Green
            currentBlacksVal = TheVideoEditor.editSettings.blacks_g
            currentShadowsVal = TheVideoEditor.editSettings.shadows_g
            currentHighlightsVal = TheVideoEditor.editSettings.highlights_g
            currentWhitesVal = TheVideoEditor.editSettings.whites_g
            break
        case .B:
            sliderActiveImage = Constants.SliderImage.Active_Blue
            currentBlacksVal = TheVideoEditor.editSettings.blacks_b
            currentShadowsVal = TheVideoEditor.editSettings.shadows_b
            currentHighlightsVal = TheVideoEditor.editSettings.highlights_b
            currentWhitesVal = TheVideoEditor.editSettings.whites_b
            break
        case .RGB:
            sliderActiveImage = Constants.SliderImage.Active
            currentBlacksVal = TheVideoEditor.editSettings.blacks
            currentShadowsVal = TheVideoEditor.editSettings.shadows
            currentHighlightsVal = TheVideoEditor.editSettings.highlights
            currentWhitesVal = TheVideoEditor.editSettings.whites
            break
        }
        
        let blacksSlider = RulerSliderView(frame: self.m_viewBlacksSlider.bounds, minValue: -1.0, maxValue: 1.0, curValue: currentBlacksVal, activeImageName: sliderActiveImage, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
        blacksSlider.delegate = self
        blacksSlider.tag = 10
        self.m_viewBlacksSlider.addSubview(blacksSlider)
        self.m_lblBlacksValue.text = String(format: "%.02f", currentBlacksVal)
        
        let shadowsSlider = RulerSliderView(frame: self.m_viewShadowsSlider.bounds, minValue: -1.0, maxValue: 1.0, curValue: currentShadowsVal, activeImageName: sliderActiveImage, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
        shadowsSlider.delegate = self
        shadowsSlider.tag = 11
        self.m_viewShadowsSlider.addSubview(shadowsSlider)
        self.m_lblShadowsValue.text = String(format: "%.02f", currentShadowsVal)
        
        let highlightsSlider = RulerSliderView(frame: self.m_viewHighlightsSlider.bounds, minValue: -1.0, maxValue: 1.0, curValue: currentHighlightsVal, activeImageName: sliderActiveImage, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
        highlightsSlider.delegate = self
        highlightsSlider.tag = 12
        self.m_viewHighlightsSlider.addSubview(highlightsSlider)
        self.m_lblHighlightsValue.text = String(format: "%.02f", currentHighlightsVal)
        
        let whitesSlider = RulerSliderView(frame: self.m_viewWhitesSlider.bounds, minValue: -1.0, maxValue: 1.0, curValue: currentWhitesVal, activeImageName: sliderActiveImage, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
        whitesSlider.delegate = self
        whitesSlider.tag = 13
        self.m_viewWhitesSlider.addSubview(whitesSlider)
        self.m_lblWhitesValue.text = String(format: "%.02f", currentWhitesVal)
    }
    
    func removeSliders() {
        for nIdx in 0..<4 {
            if let slider = self.view.viewWithTag(10 + nIdx) as? RulerSliderView {
                slider.removeFromSuperview()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func rulerChanged(_ view: RulerSliderView, _ value: CGFloat, _ bTouchFinished: Bool) {
        if (view.tag == 10) {
            self.m_lblBlacksValue.text = String(format: "%.02f", value)
            
            switch TheVideoEditor.editSettings.toneCurveMode {
            case .R:
                TheVideoEditor.editSettings.blacks_r = value
                break
            case .G:
                TheVideoEditor.editSettings.blacks_g = value
                break
            case .B:
                TheVideoEditor.editSettings.blacks_b = value
                break
            case .RGB:
                TheVideoEditor.editSettings.blacks = value
                break
            }
        } else if (view.tag == 11) {
            self.m_lblShadowsValue.text = String(format: "%.02f", value)
            
            switch TheVideoEditor.editSettings.toneCurveMode {
            case .R:
                TheVideoEditor.editSettings.shadows_r = value
                break
            case .G:
                TheVideoEditor.editSettings.shadows_g = value
                break
            case .B:
                TheVideoEditor.editSettings.shadows_b = value
                break
            case .RGB:
                TheVideoEditor.editSettings.shadows = value
                break
            }
        } else if (view.tag == 12) {
            self.m_lblHighlightsValue.text = String(format: "%.02f", value)
            
            switch TheVideoEditor.editSettings.toneCurveMode {
            case .R:
                TheVideoEditor.editSettings.highlights_r = value
                break
            case .G:
                TheVideoEditor.editSettings.highlights_g = value
                break
            case .B:
                TheVideoEditor.editSettings.highlights_b = value
                break
            case .RGB:
                TheVideoEditor.editSettings.highlights = value
                break
            }
        } else {
            self.m_lblWhitesValue.text = String(format: "%.02f", value)
            
            switch TheVideoEditor.editSettings.toneCurveMode {
            case .R:
                TheVideoEditor.editSettings.whites_r = value
                break
            case .G:
                TheVideoEditor.editSettings.whites_g = value
                break
            case .B:
                TheVideoEditor.editSettings.whites_b = value
                break
            case .RGB:
                TheVideoEditor.editSettings.whites = value
                break
            }
        }
        
        switch TheVideoEditor.editSettings.toneCurveMode {
        case .RGB:
            if (TheVideoEditor.editSettings.blacks == 0.0 &&
                TheVideoEditor.editSettings.shadows == 0.0 &&
                TheVideoEditor.editSettings.highlights == 0.0 &&
                TheVideoEditor.editSettings.whites == 0.0) {
                TheVideoEditor.bChangedToneCurve = false
            } else {
                TheVideoEditor.bChangedToneCurve = true
            }
            break
        case .R:
            if (TheVideoEditor.editSettings.blacks_r == 0.0 &&
                TheVideoEditor.editSettings.shadows_r == 0.0 &&
                TheVideoEditor.editSettings.highlights_r == 0.0 &&
                TheVideoEditor.editSettings.whites_r == 0.0) {
                TheVideoEditor.bChangedToneCurve = false
            } else {
                TheVideoEditor.bChangedToneCurve = true
            }
            break
        case .G:
            if (TheVideoEditor.editSettings.blacks_g == 0.0 &&
                TheVideoEditor.editSettings.shadows_g == 0.0 &&
                TheVideoEditor.editSettings.highlights_g == 0.0 &&
                TheVideoEditor.editSettings.whites_g == 0.0) {
                TheVideoEditor.bChangedToneCurve = false
            } else {
                TheVideoEditor.bChangedToneCurve = true
            }
            break
        case .B:
            if (TheVideoEditor.editSettings.blacks_b == 0.0 &&
                TheVideoEditor.editSettings.shadows_b == 0.0 &&
                TheVideoEditor.editSettings.highlights_b == 0.0 &&
                TheVideoEditor.editSettings.whites_b == 0.0) {
                TheVideoEditor.bChangedToneCurve = false
            } else {
                TheVideoEditor.bChangedToneCurve = true
            }
            break
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        
        if (bTouchFinished) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
        }
    }

    func rulerValueChangedForShow(_ view: RulerSliderView, _ value: CGFloat) {
        if (view.tag == 10) {
            self.m_lblBlacksValue.text = String(format: "%.02f", value)
        } else if (view.tag == 11) {
            self.m_lblShadowsValue.text = String(format: "%.02f", value)
        } else if (view.tag == 12) {
            self.m_lblHighlightsValue.text = String(format: "%.02f", value)
        } else {
            self.m_lblWhitesValue.text = String(format: "%.02f", value)
        }
    }
    
    @IBAction func colorOptionChanged(_ sender: UISegmentedControl) {
        TheVideoEditor.editSettings.toneCurveMode = ToneCurveMode(rawValue: sender.selectedSegmentIndex)!
        makeUserInterface()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
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
