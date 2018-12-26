//
//  TextFontColorViewController.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class TextFontColorViewController: UIViewController, RulerSliderViewDelegate {
    var bLoadedView: Bool = false

    @IBOutlet weak var m_scrollFontsView: UIScrollView!
    
    @IBOutlet weak var m_scrollBGColorsView: UIScrollView!
    @IBOutlet weak var m_viewBGColorOpacitySlider: UIView!
    
    @IBOutlet weak var m_scrollTextColorsView: UIScrollView!
    @IBOutlet weak var m_viewTextColorOpacitySlider: UIView!

    var bgColorLabels: [UILabel] = []
    var textColorLabels: [UILabel] = []
    var fontLabels: [UILabel] = []
    
    var nSelectedBGColorIdx: Int = -1
    var nSelectedTextColorIdx: Int = 0
    var nSelectedFontIdx: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.edgesForExtendedLayout = UIRectEdge()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSelectedObject), name: NSNotification.Name(rawValue: Constants.NotificationName.SelectedFontObject), object: nil)
    }
    
    @objc func showSelectedObject() {
        showSliders()
        
        //update bg color scrollview
        for label in self.bgColorLabels {
            InterfaceManager.makeRadiusControl(label, cornerRadius: self.m_scrollBGColorsView.frame.height / 2.0, withColor: UIColor.black, borderSize: 0.0)
        }
        
        nSelectedBGColorIdx = (TheVideoEditor.selectedFontObjectIdx == -1 ? -1 : TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.bg_colorIdx)
        
        if (nSelectedBGColorIdx > -1) {
            InterfaceManager.makeRadiusControl(bgColorLabels[nSelectedBGColorIdx], cornerRadius: self.m_scrollBGColorsView.frame.height / 2.0, withColor: UIColor.black, borderSize: 2.0)
            self.m_scrollBGColorsView.setContentOffset(CGPoint(x: self.bgColorLabels[nSelectedBGColorIdx].frame.minX, y: 0.0), animated: true)
        }

        //update text color scrollview
        for label in self.textColorLabels {
            InterfaceManager.makeRadiusControl(label, cornerRadius: self.m_scrollTextColorsView.frame.height / 2.0, withColor: UIColor.black, borderSize: 0.0)
        }
        
        nSelectedTextColorIdx = (TheVideoEditor.selectedFontObjectIdx == -1 ? 0 : TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.colorIdx)
        InterfaceManager.makeRadiusControl(textColorLabels[nSelectedTextColorIdx], cornerRadius: self.m_scrollTextColorsView.frame.height / 2.0, withColor: UIColor.black, borderSize: 2.0)
        self.m_scrollTextColorsView.setContentOffset(CGPoint(x: self.textColorLabels[nSelectedTextColorIdx].frame.minX, y: 0.0), animated: true)

        //update font scrollview
        for label in self.fontLabels {
            label.textColor = UIColor.lightGray
            InterfaceManager.makeRadiusControl(label, cornerRadius: 0.0, withColor: UIColor.black, borderSize: 0.0)
        }
        
        nSelectedFontIdx = (TheVideoEditor.selectedFontObjectIdx == -1 ? 0 : TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.fontIdx)
        fontLabels[nSelectedFontIdx].textColor = UIColor.black
        self.m_scrollFontsView.setContentOffset(CGPoint(x: self.fontLabels[nSelectedFontIdx].frame.minX, y: 0.0), animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (bLoadedView) {
            return
        }
        
        bLoadedView = true
        
        showSliders()
        showFonts()
        showBackgroundColors()
        showTextColors()
    }
    
    func removeSliders() {
        if let slider = self.m_viewBGColorOpacitySlider.viewWithTag(10) as? RulerSliderView {
            slider.removeFromSuperview()
        }
        
        if let slider = self.m_viewTextColorOpacitySlider.viewWithTag(11) as? RulerSliderView {
            slider.removeFromSuperview()
        }
    }
    
    func showSliders() {
        removeSliders()
        
        let bEnabledSlider = (TheVideoEditor.selectedFontObjectIdx == -1 ? false : true)

        let curBgColorOpacity = (TheVideoEditor.selectedFontObjectIdx == -1 ? 0.0 : TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.bg_opacity)
        let bgColorOpacitySlider = RulerSliderView(frame: self.m_viewBGColorOpacitySlider.bounds, minValue: 0.0, maxValue: 1.0, curValue: curBgColorOpacity, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
        bgColorOpacitySlider.delegate = self
        bgColorOpacitySlider.bEnabled = bEnabledSlider
        bgColorOpacitySlider.tag = 10
        self.m_viewBGColorOpacitySlider.addSubview(bgColorOpacitySlider)

        let curTextColorOpacity = (TheVideoEditor.selectedFontObjectIdx == -1 ? 1.0 : TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.opacity)
        let textColorOpacitySlider = RulerSliderView(frame: self.m_viewTextColorOpacitySlider.bounds, minValue: 0.0, maxValue: 1.0, curValue: curTextColorOpacity, activeImageName: Constants.SliderImage.Active, unactiveImageName: Constants.SliderImage.Unactive, continousUpdate: true)
        textColorOpacitySlider.delegate = self
        textColorOpacitySlider.bEnabled = bEnabledSlider
        textColorOpacitySlider.tag = 11
        self.m_viewTextColorOpacitySlider.addSubview(textColorOpacitySlider)
    }
    
    func rulerChanged(_ view: RulerSliderView, _ value: CGFloat, _ bTouchFinished: Bool) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }
        
        if (view.tag == 10) {
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.bg_opacity = value
        } else {
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.opacity = value
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
        
        if (bTouchFinished) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
        }
    }
    
    func rulerValueChangedForShow(_ view: RulerSliderView, _ value: CGFloat) {
    }
    
    func showBackgroundColors() {
        var totalWidth: CGFloat = 0.0
        let height: CGFloat = self.m_scrollBGColorsView.frame.height
        let stepWidth: CGFloat = (self.m_scrollBGColorsView.frame.width - 5.0 * height) / 4.0
        
        for nIdx in 0..<colors.count {
            let colorLabel = UILabel.init(frame: CGRect(x: totalWidth, y: 0.0, width: height, height: height))
            colorLabel.tag = 10 + nIdx
            colorLabel.backgroundColor = colors[nIdx]
            colorLabel.text = ""
            
            self.m_scrollBGColorsView.addSubview(colorLabel)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedBGColor(_:)))
            colorLabel.isUserInteractionEnabled = true
            colorLabel.addGestureRecognizer(tapGesture)
            
            InterfaceManager.makeRadiusControl(colorLabel, cornerRadius: height / 2.0, withColor: UIColor.black, borderSize: 0.0)
            if (nIdx == self.nSelectedBGColorIdx) {
                InterfaceManager.makeRadiusControl(colorLabel, cornerRadius: height / 2.0, withColor: UIColor.black, borderSize: 2.0)
            }
            
            totalWidth += height + stepWidth
            
            bgColorLabels.append(colorLabel)
        }
        
        self.m_scrollBGColorsView.showsVerticalScrollIndicator = false
        self.m_scrollBGColorsView.showsHorizontalScrollIndicator = false
        
        self.m_scrollBGColorsView.contentSize = CGSize(width: totalWidth - stepWidth, height: height)
        
        if (self.nSelectedBGColorIdx > -1) {
            self.m_scrollBGColorsView.setContentOffset(CGPoint(x: self.bgColorLabels[nSelectedBGColorIdx].frame.minX, y: 0.0), animated: true)
        }
    }
    
    func showTextColors() {
        var totalWidth: CGFloat = 0.0
        let height: CGFloat = self.m_scrollTextColorsView.frame.height
        let stepWidth: CGFloat = (self.m_scrollTextColorsView.frame.width - 5.0 * height) / 4.0
        
        for nIdx in 0..<colors.count {
            let textLabel = UILabel.init(frame: CGRect(x: totalWidth, y: 0.0, width: height, height: height))
            textLabel.tag = 10 + nIdx
            textLabel.backgroundColor = colors[nIdx]
            textLabel.text = ""
            self.m_scrollTextColorsView.addSubview(textLabel)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedTextColor(_:)))
            textLabel.isUserInteractionEnabled = true
            textLabel.addGestureRecognizer(tapGesture)
            
            InterfaceManager.makeRadiusControl(textLabel, cornerRadius: height / 2.0, withColor: UIColor.black, borderSize: 0.0)
            if (nIdx == self.nSelectedTextColorIdx) {
                InterfaceManager.makeRadiusControl(textLabel, cornerRadius: height / 2.0, withColor: UIColor.black, borderSize: 2.0)
            }
            
            totalWidth += height + stepWidth
            
            textColorLabels.append(textLabel)
        }
        
        self.m_scrollTextColorsView.showsVerticalScrollIndicator = false
        self.m_scrollTextColorsView.showsHorizontalScrollIndicator = false

        self.m_scrollTextColorsView.contentSize = CGSize(width: totalWidth - stepWidth, height: height)
        
        self.m_scrollTextColorsView.setContentOffset(CGPoint(x: self.textColorLabels[nSelectedTextColorIdx].frame.minX, y: 0.0), animated: true)
    }
    
    func showFonts() {
        var totalWidth: CGFloat = 0.0
        let height: CGFloat = self.m_scrollFontsView.frame.height
        let stepWidth: CGFloat = 24.0
        
        for nIdx in 0..<TheGlobalPoolManager.allFonts.count {
            let stringSize = InterfaceManager.evaluateStringSize(font: UIFont.init(name: TheGlobalPoolManager.allFonts[nIdx], size: 16.0)!, textToEvaluate: "ABC")
            let stringWidth = stringSize.width + 2.0
            let stringHeight = stringSize.height
            
            let fontLabel = UILabel.init(frame: CGRect(x: totalWidth, y: 0.0, width: stringWidth, height: height))
            fontLabel.tag = 10 + nIdx
            fontLabel.text = "ABC"
            fontLabel.textColor = UIColor.lightGray
            fontLabel.font = UIFont.init(name: TheGlobalPoolManager.allFonts[nIdx], size: 16.0)!
            fontLabel.numberOfLines = 0
            //fontLabel.backgroundColor = UIColor.red
            fontLabel.sizeToFit()
            self.m_scrollFontsView.addSubview(fontLabel)
            
            fontLabel.center = CGPoint(x: totalWidth + stringWidth / 2.0, y: height / 2.0 - fontLabel.frame.height / 2.0)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedFont(_:)))
            fontLabel.isUserInteractionEnabled = true
            fontLabel.addGestureRecognizer(tapGesture)
            
            if (nIdx == self.nSelectedFontIdx) {
                fontLabel.textColor = UIColor.black
            }
            
            totalWidth += stringWidth + stepWidth
            
            fontLabels.append(fontLabel)
        }
        
        self.m_scrollFontsView.showsVerticalScrollIndicator = false
        self.m_scrollFontsView.showsHorizontalScrollIndicator = false

        self.m_scrollFontsView.contentSize = CGSize(width: totalWidth - stepWidth, height: height)
        
        self.m_scrollFontsView.setContentOffset(CGPoint(x: self.fontLabels[nSelectedFontIdx].frame.minX, y: 0.0), animated: true)
    }
    
    @objc func tappedBGColor(_ sender: UITapGestureRecognizer) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }

        if (sender.view is UILabel) {
            let tappedLabel = sender.view as! UILabel
            
            let height: CGFloat = self.m_scrollBGColorsView.frame.height
            
            if (nSelectedBGColorIdx >= 0) {
                InterfaceManager.makeRadiusControl(bgColorLabels[nSelectedBGColorIdx], cornerRadius: height / 2.0, withColor: UIColor.black, borderSize: 0.0)
            }
            
            nSelectedBGColorIdx = tappedLabel.tag - 10
            InterfaceManager.makeRadiusControl(bgColorLabels[nSelectedBGColorIdx], cornerRadius: height / 2.0, withColor: UIColor.black, borderSize: 2.0)
            
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.bg_colorIdx = nSelectedBGColorIdx
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
        }
    }
    
    @objc func tappedTextColor(_ sender: UITapGestureRecognizer) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }

        if (sender.view is UILabel) {
            let tappedLabel = sender.view as! UILabel
            
            let height: CGFloat = self.m_scrollTextColorsView.frame.height
            
            if (nSelectedTextColorIdx >= 0) {
                InterfaceManager.makeRadiusControl(textColorLabels[nSelectedTextColorIdx], cornerRadius: height / 2.0, withColor: UIColor.black, borderSize: 0.0)
            }
            
            nSelectedTextColorIdx = tappedLabel.tag - 10
            InterfaceManager.makeRadiusControl(textColorLabels[nSelectedTextColorIdx], cornerRadius: height / 2.0, withColor: UIColor.black, borderSize: 2.0)
            
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.colorIdx = nSelectedTextColorIdx
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
        }
    }
    
    @objc func tappedFont(_ sender: UITapGestureRecognizer) {
        if (TheVideoEditor.selectedFontObjectIdx == -1) {
            return
        }

        if (sender.view is UILabel) {
            let tappedLabel = sender.view as! UILabel
            
            if (nSelectedFontIdx >= 0) {
                fontLabels[nSelectedFontIdx].textColor = UIColor.lightGray
            }
            
            nSelectedFontIdx = tappedLabel.tag - 10
            fontLabels[nSelectedFontIdx].textColor = UIColor.black
            
            TheVideoEditor.fontObjects[TheVideoEditor.selectedFontObjectIdx].settings.fontIdx = nSelectedFontIdx
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedTextSeting), object: nil, userInfo: nil)
            
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

}
