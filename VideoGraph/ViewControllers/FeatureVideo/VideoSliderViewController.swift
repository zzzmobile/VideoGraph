//
//  VideoSliderViewController.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class VideoSliderViewController: UIViewController, RulerSliderViewDelegate {
    var bLoadedView: Bool = false

    @IBOutlet weak var m_segmentRepeat: UISegmentedControl!
    
    @IBOutlet weak var m_lblValue: UILabel!
    
    @IBOutlet weak var m_viewSlider: UIView!
    var slider: RulerSliderView? = nil
    
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
        showSlider()
    }
    
    func makeUserInterface() {
        self.m_segmentRepeat.selectedSegmentIndex = (TheVideoEditor.editSettings.repeatMode == .Bounce ? 0 : 1)
        
        if (TheInterfaceManager.nSelectedSubMenu == 0) {
            self.m_segmentRepeat.isHidden = false
        } else {
            self.m_segmentRepeat.isHidden = true
        }
    }
    
    func showSlider() {
        if (self.slider != nil) {
            self.slider!.removeFromSuperview()
            self.slider = nil
        }

        var minValue: CGFloat = 0.0
        var maxValue: CGFloat = 0.0
        var curValue: CGFloat = 0.0
        
        if (TheInterfaceManager.nSelectedSubMenu == 0) {
            minValue = 0.0
            maxValue = 1.0
            curValue = TheVideoEditor.editSettings.crossFade

            self.m_lblValue.text = String(format: "%.02f", curValue)
        } else if (TheInterfaceManager.nSelectedSubMenu == 1) {
            minValue = 0.0
            maxValue = 2.0
            curValue = TheVideoEditor.editSettings.speed

            self.m_lblValue.text = String(format: "%.01f x", curValue)
        } else {
            minValue = 0.0
            maxValue = 5.0
            curValue = TheVideoEditor.editSettings.delay

            self.m_lblValue.text = String(format: "%.02f second", curValue)
        }
        
        let sliderView = RulerSliderView(frame: self.m_viewSlider.bounds, minValue: minValue, maxValue: maxValue, curValue: curValue, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive)
        sliderView.delegate = self
        self.m_viewSlider.addSubview(sliderView)
        
        self.slider = sliderView
        
        self.view.layoutIfNeeded()
    }

    func rulerValueChangedForShow(_ view: RulerSliderView, _ value: CGFloat) {
        if (TheInterfaceManager.nSelectedSubMenu == 0) {
            self.m_lblValue.text = String(format: "%.02f", value)
        } else if (TheInterfaceManager.nSelectedSubMenu == 1) {
            self.m_lblValue.text = String(format: "%.01f x", value)
        } else {
            self.m_lblValue.text = String(format: "%.02f second", value)
        }
    }
    
    func rulerChanged(_ view: RulerSliderView, _ value: CGFloat, _ bTouchFinished: Bool) {
        if (TheInterfaceManager.nSelectedSubMenu == 0) {
            self.m_lblValue.text = String(format: "%.02f", value)
            TheVideoEditor.editSettings.crossFade = value
        } else if (TheInterfaceManager.nSelectedSubMenu == 1) {
            self.m_lblValue.text = String(format: "%.01f x", value)
            TheVideoEditor.editSettings.speed = value
        } else {
            self.m_lblValue.text = String(format: "%.02f second", value)
            TheVideoEditor.editSettings.delay = value
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedEditVideoSettings), object: nil, userInfo: nil)
        
        if (bTouchFinished) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
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

    @IBAction func repeatOptionChanged(_ sender: UISegmentedControl) {
        TheVideoEditor.editSettings.repeatMode = (sender.selectedSegmentIndex == 0 ? .Bounce : .Repeat)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedEditVideoSettings), object: nil, userInfo: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
}
