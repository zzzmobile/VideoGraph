//
//  TemplateMenuViewController.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

protocol TemplateMenuViewControllerDelegate {
    func tappedTemplateMenu()
}

class TemplateMenuViewController: UIViewController {
    var delegate: TemplateMenuViewControllerDelegate? = nil
    
    var bLoadedView: Bool = false

    @IBOutlet weak var m_constraintSelectionLeading: NSLayoutConstraint!
    @IBOutlet weak var m_constraintSelectionWidth: NSLayoutConstraint!
    
    var titles: [String] = []
    
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
        
        showSelectedOption()
    }
    
    func showSelectedOption(_ bAnimation: Bool = false) {
        for nIdx in 0..<titles.count {
            if let btnSubMenu = self.view.viewWithTag(10 + nIdx) as? UIButton {
                btnSubMenu.setTitle(titles[nIdx], for: .normal)
                btnSubMenu.titleLabel?.font = UIFont.systemFont(ofSize: TheInterfaceManager.deviceWidth() > 320 ? 13.0 : 11.0)
                btnSubMenu.setTitleColor(UIColor.lightGray, for: .normal)
                
                if (nIdx == TheInterfaceManager.nSelectedSubMenu) {
                    btnSubMenu.titleLabel?.font = UIFont.boldSystemFont(ofSize: TheInterfaceManager.deviceWidth() > 320 ? 13.0 : 11.0)
                    btnSubMenu.setTitleColor(UIColor.black, for: .normal)
                    
                    let titleWidth = InterfaceManager.evaluateStringSize(font: UIFont.boldSystemFont(ofSize: TheInterfaceManager.deviceWidth() > 320 ? 13.0 : 11.0), textToEvaluate: titles[nIdx]).width + 4.0
                    
                    UIView.animate(withDuration: bAnimation ? 0.3 : 0.0) {
                        self.m_constraintSelectionWidth.constant = titleWidth
                        self.m_constraintSelectionLeading.constant = btnSubMenu.center.x - titleWidth / 2.0
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    @IBAction func actionSelectOption(_ sender: UIButton) {
        let nIdx = sender.tag - 10

        if (TheInterfaceManager.nSelectedSubMenu == nIdx) {
            return
        }
        
        TheInterfaceManager.nSelectedSubMenu = nIdx
        showSelectedOption(true)
        
        self.delegate?.tappedTemplateMenu()
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
