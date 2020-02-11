//
//  FilterViewController.swift
//  VideoGraph
//
//  Created by Admin on 15/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var bLoadedView: Bool = false

    @IBOutlet weak var m_collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.edgesForExtendedLayout = UIRectEdge()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFilters), name: NSNotification.Name(rawValue: Constants.NotificationName.UpdatedStillImage), object: nil)
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
        self.m_collectionView.backgroundColor = UIColor.white
        
        let edgeInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        let layout:UICollectionViewFlowLayout = self.m_collectionView.collectionViewLayout as! UICollectionViewFlowLayout;
        layout.sectionInset = edgeInsets
        layout.minimumInteritemSpacing = 4.0
        layout.minimumLineSpacing = 4.0
        
        self.m_collectionView.delegate = self
        self.m_collectionView.dataSource = self
        
        self.m_collectionView.isScrollEnabled = false
    }
    
    @objc func refreshFilters() {
        self.m_collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewID.FilterCell, for: indexPath) as! FilterCell
        
        InterfaceManager.makeRadiusControl(cell, cornerRadius: 4.0, withColor: UIColor.black, borderSize: 0.0)
        if (indexPath.row == TheVideoEditor.editSettings.filterIdx) {
            InterfaceManager.makeRadiusControl(cell, cornerRadius: 4.0, withColor: UIColor.black, borderSize: 2.0)
        }
        
        cell.showFilteredImage(indexPath.row)
        
        cell.layoutIfNeeded()
        cell.setNeedsLayout()
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TheVideoFilterManager.filterNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 32.0 - 12.0) / 4.0
        let height = width * 1.4
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (TheVideoEditor.editSettings.filterIdx == indexPath.row) {
            return
        }
        
        if (TheVideoEditor.editSettings.filterIdx > -1) {
            if let prevCell = collectionView.cellForItem(at: IndexPath(row: TheVideoEditor.editSettings.filterIdx, section: 0)) as? FilterCell {
                InterfaceManager.makeRadiusControl(prevCell, cornerRadius: 4.0, withColor: UIColor.black, borderSize: 0.0)
            }
        }
        
        TheVideoEditor.editSettings.filterIdx = indexPath.row
        
        if let cell = collectionView.cellForItem(at: indexPath) as? FilterCell {
            InterfaceManager.makeRadiusControl(cell, cornerRadius: 4.0, withColor: UIColor.black, borderSize: 2.0)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AppliedVideoFilter), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.AddedActionForUndo), object: nil, userInfo: nil)
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
