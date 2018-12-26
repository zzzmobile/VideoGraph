//
//  BrushSliderViewController.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class BrushSliderViewController: UIViewController, RulerSliderViewDelegate {
    var bLoadedView: Bool = false

    @IBOutlet weak var m_viewSlider: UIView!
    
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
        
        showSlider()
    }
    
    func showSlider() {
        var minValue: CGFloat = 0.0
        var maxValue: CGFloat = 0.0
        var curValue: CGFloat = 0.0
        
        if (TheInterfaceManager.nSelectedSubMenu == 0) {
            minValue = 4.0
            maxValue = 64.0
            curValue = TheVideoEditor.editSettings.brushSize
        } else if (TheInterfaceManager.nSelectedSubMenu == 1) {
            minValue = 0.0
            maxValue = 60.0
            curValue = TheVideoEditor.editSettings.brushHardness
        } else {
            minValue = 25.0
            maxValue = 100.0
            curValue = TheVideoEditor.editSettings.brushOpacity
        }
        
        let sliderView = RulerSliderView(frame: self.m_viewSlider.bounds, minValue: minValue, maxValue: maxValue, curValue: curValue, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive)
        sliderView.delegate = self
        self.m_viewSlider.addSubview(sliderView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func rulerChanged(_ view: RulerSliderView, _ value: CGFloat, _ bTouchFinished: Bool) {
        if (TheInterfaceManager.nSelectedSubMenu == 0) {
            TheVideoEditor.editSettings.brushSize = value
        } else if (TheInterfaceManager.nSelectedSubMenu == 1) {
            TheVideoEditor.editSettings.brushHardness = value
        } else {
            TheVideoEditor.editSettings.brushOpacity = value
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedBrushParam), object: nil, userInfo: nil)
    }
    
    func rulerValueChangedForShow(_ view: RulerSliderView, _ value: CGFloat) {
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
