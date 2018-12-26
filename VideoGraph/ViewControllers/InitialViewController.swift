//
//  InitialViewController.swift
//  VideoGraph
//
//  Created by Admin on 19/09/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    var bLoadedView: Bool = false
    
    @IBOutlet weak var m_loadingActivity: UIActivityIndicatorView!
    
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

        self.m_loadingActivity.isHidden = false
        self.m_loadingActivity.startAnimating()

        let delayTime = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            TheProjectManger.loadProjects()
            
            DispatchQueue.main.async {
                self.m_loadingActivity.stopAnimating()
                self.m_loadingActivity.isHidden = true
                
                //go to main screen
                let viewCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewIDs.ViewController)
                self.navigationController?.pushViewController(viewCon!, animated: false)
            }
        })
    }
    
    func loadProjects() {
        DispatchQueue.global(qos: .background).async {
            
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
