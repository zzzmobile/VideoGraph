//
//  TextMenuViewController.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

protocol TextMenuViewControllerDelegate {
    func tappedTextMenu()
}

class TextMenuViewController: UIViewController, CenterFocusViewDelegate {
    var delegate: TextMenuViewControllerDelegate? = nil
    
    var bLoadedView: Bool = false

    @IBOutlet weak var m_viewMenu: UIView!
    var menuScrollView: CenterFocusView? = nil

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
        makeUserInterface()
    }
    
    func makeUserInterface() {
        menuScrollView = CenterFocusView(self.m_viewMenu.bounds, self.m_viewMenu.bounds.width / 3.0, Constants.TextMenu.Titles, "", 0, false)
        self.menuScrollView?.actionDelegate = self
        self.m_viewMenu.addSubview(menuScrollView!)
    }
    
    func selectedOneOption(_ view: CenterFocusView, nIdx: Int) {
        TheInterfaceManager.nSelectedSubMenu = nIdx
        
        self.delegate?.tappedTextMenu()
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
