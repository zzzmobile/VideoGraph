//
//  BrushOverlayViewController.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class BrushOverlayViewController: UIViewController, RulerSliderViewDelegate {
    var bLoadedView: Bool = false

    @IBOutlet weak var m_segmentMaskAvailable: UISegmentedControl!
    @IBOutlet weak var m_segmentMaskAll: UISegmentedControl!

    @IBOutlet weak var m_scrollColorView: UIScrollView!
    
    @IBOutlet weak var m_viewOpacitySlider: UIView!
    
    var colorLabels: [UILabel] = []
    
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
        
        self.m_segmentMaskAvailable.selectedSegmentIndex = (TheVideoEditor.editSettings.bShowMaskAlways ? 0 : 1)
        self.m_segmentMaskAll.selectedSegmentIndex = -1
        
        showSlider()
        showColors()
    }
    
    func removeSlider() {
        if let sliderView = self.m_viewOpacitySlider.viewWithTag(10) as? RulerSliderView {
            sliderView.removeFromSuperview()
        }
    }
    
    func showSlider() {
        removeSlider()
        
        let sliderView = RulerSliderView(frame: self.m_viewOpacitySlider.bounds, minValue: 25.0, maxValue: 80.0, curValue: TheVideoEditor.editSettings.maskOpacity, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive)
        sliderView.delegate = self
        sliderView.tag = 10
        self.m_viewOpacitySlider.addSubview(sliderView)
    }
    
    func showColors() {
        var totalWidth: CGFloat = 0.0
        let height: CGFloat = self.m_scrollColorView.frame.height
        let stepWidth: CGFloat = (self.m_scrollColorView.frame.width - 5.0 * height) / 4.0
        
        for nIdx in 0..<colors.count {
            let colorLabel = UILabel.init(frame: CGRect(x: totalWidth, y: 0.0, width: height, height: height))
            colorLabel.tag = 10 + nIdx
            colorLabel.backgroundColor = colors[nIdx]
            colorLabel.text = ""
            
            self.m_scrollColorView.addSubview(colorLabel)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedColor(_:)))
            colorLabel.isUserInteractionEnabled = true
            colorLabel.addGestureRecognizer(tapGesture)
            
            InterfaceManager.makeRadiusControl(colorLabel, cornerRadius: height / 2.0, withColor: UIColor.black, borderSize: 0.0)
            if (nIdx == TheVideoEditor.editSettings.maskColorIdx) {
                InterfaceManager.makeRadiusControl(colorLabel, cornerRadius: height / 2.0, withColor: UIColor.black, borderSize: 2.0)
            }
            
            totalWidth += height + stepWidth
            
            colorLabels.append(colorLabel)
        }
        
        self.m_scrollColorView.showsVerticalScrollIndicator = false
        self.m_scrollColorView.showsHorizontalScrollIndicator = false
        self.m_scrollColorView.contentSize = CGSize(width: totalWidth - stepWidth, height: height)
    }
    
    @objc func tappedColor(_ sender: UITapGestureRecognizer) {
        if (sender.view is UILabel) {
            let tappedLabel = sender.view as! UILabel
            
            let height: CGFloat = self.m_scrollColorView.frame.height

            if (TheVideoEditor.editSettings.maskColorIdx >= 0) {
                InterfaceManager.makeRadiusControl(colorLabels[TheVideoEditor.editSettings.maskColorIdx], cornerRadius: height / 2.0, withColor: UIColor.black, borderSize: 0.0)
            }

            TheVideoEditor.editSettings.maskColorIdx = tappedLabel.tag - 10
            InterfaceManager.makeRadiusControl(colorLabels[TheVideoEditor.editSettings.maskColorIdx], cornerRadius: height / 2.0, withColor: UIColor.black, borderSize: 2.0)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskColor), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func rulerChanged(_ view: RulerSliderView, _ value: CGFloat, _ bTouchFinished: Bool) {
        TheVideoEditor.editSettings.maskOpacity = value
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskOpacity), object: nil, userInfo: nil)
        
        if (bTouchFinished) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
        }
    }
    
    func rulerValueChangedForShow(_ view: RulerSliderView, _ value: CGFloat) {
    }
    
    @IBAction func maskAvailableChanged(_ sender: UISegmentedControl) {
        TheVideoEditor.editSettings.bShowMaskAlways = (sender.selectedSegmentIndex == 0 ? true : false)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskVisible), object: nil, userInfo: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
    }
    
    @IBAction func maskAllChanged(_ sender: UISegmentedControl) {
        TheVideoEditor.editSettings.bMaskAll = (sender.selectedSegmentIndex == 0 ? true : false)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedMaskFeature), object: nil, userInfo: nil)

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)

        let delayTime = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            self.m_segmentMaskAll.selectedSegmentIndex = -1
        })

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
