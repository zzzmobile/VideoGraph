//
//  ViewController.swift
//  VideoGraph
//
//  Created by Admin on 13/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ProjectCellDelegate, MyProjectHeaderViewDelegate {
    var bLoadedView: Bool = false
    
    @IBOutlet weak var m_imgThumbnail: UIImageView!
    @IBOutlet weak var m_constraintImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var m_collectionView: UICollectionView!
    
    var m_headerView: MyProjectHeaderView? = nil
    
    var selectedIndexes: [Int] = []
    var bLongPressAvailable: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.edgesForExtendedLayout = UIRectEdge()
        
        TheGlobalPoolManager.rootViewCon = self
        
        makeUserInterface()

        if (TheProjectManger.projects.count == 0) {
            let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                self.goCameraView()
            })
        }
    }

    func goCameraView() {
        DispatchQueue.global(qos: .background).async {
            TheVideoWriter.setupAssetWriter(720, 1280)
            
            DispatchQueue.main.async {
                let cameraViewCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewIDs.NewCameraViewController)
                self.navigationController?.pushViewController(cameraViewCon!, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.m_collectionView.reloadData()
        self.m_headerView?.m_imgThumbnail.image = (TheProjectManger.thumbnails.count > 0 ? TheProjectManger.thumbnails[0] : nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (bLoadedView) {
            return
        }
        
        bLoadedView = true
    }
    
    func showDeleteButton() {
        self.m_headerView?.m_btnDelete.isHidden = !self.bLongPressAvailable
    }
    
    @objc func tappedLongPress(_ gesture: UILongPressGestureRecognizer) {
        let p = gesture.location(in: self.m_collectionView)
        
        if let indexPath = self.m_collectionView.indexPathForItem(at: p) {
            if (indexPath.row == 0) {
                return
            }

            let selectedCell = self.m_collectionView.cellForItem(at: indexPath) as! ProjectCell
            if gesture.state == .began {
                InterfaceManager.makeRadiusControl(selectedCell, cornerRadius: 6.0, withColor: UIColor.purple, borderSize: 4.0)
                
                return
            }
            
            if (gesture.state == .ended) {
                self.bLongPressAvailable = !self.bLongPressAvailable
                self.showDeleteButton()
                if (self.bLongPressAvailable) {
                    self.selectedIndexes.removeAll()
                    self.selectedIndexes.append(indexPath.row)
                }
                
                self.m_collectionView.reloadData()
            }
        } else {
            print("couldn't find index path")
        }
    }
    
    func tappedDeleteButton() {
        if (self.selectedIndexes.count == 0) {
            return
        }
        
        self.selectedIndexes = self.selectedIndexes.sorted(by: {$0 > $1})

        let message = (self.selectedIndexes.count == 1 ? "Are you sure to delete selected video right now?" : "Are you sure to delete selected videos right now?")
        let alert = UIAlertController(title: Constants.AppName, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            InterfaceManager.showLoadingView()
            DispatchQueue.global(qos: .background).async {
                TheProjectManger.deleteProjects(self.selectedIndexes)
                
                DispatchQueue.main.async {
                    InterfaceManager.hideLoadingView()
                    InterfaceManager.showMessage(true, title: "You have deleted successfully!", bBottomPos: true)
                    
                    self.selectedIndexes.removeAll()
                    self.bLongPressAvailable = false
                    self.showDeleteButton()
                    
                    self.m_collectionView.reloadData()
                    self.m_headerView?.m_imgThumbnail.image = (TheProjectManger.thumbnails.count > 0 ? TheProjectManger.thumbnails[0] : nil)
                }
            }
        }))
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func makeUserInterface() {
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(tappedLongPress(_:)))
        longGesture.delaysTouchesBegan = true
        longGesture.minimumPressDuration = 0.4
        self.m_collectionView.addGestureRecognizer(longGesture)

//        self.m_collectionView.backgroundColor = UIColor.white
        
        let edgeInsets = UIEdgeInsetsMake(4.0, 8.0, 8.0, 8.0)
        let layout:UICollectionViewFlowLayout = self.m_collectionView.collectionViewLayout as! UICollectionViewFlowLayout;
        layout.sectionInset = edgeInsets
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        self.m_collectionView.delegate = self
        self.m_collectionView.dataSource = self
        
//        if let headerView = Bundle.main.loadNibNamed("MyProjectHeaderView", owner: self, options: nil)?.first as? MyProjectHeaderView {
//            headerView.m_imgThumbnail.image = (TheProjectManger.thumbnails.count > 0 ? TheProjectManger.thumbnails[0] : nil)
//            headerView.m_imgThumbnail.backgroundColor = UIColor.black
//
//            self.m_collectionView.addSubview(headerView)
//
//            self.m_headerView = headerView
//            self.m_headerView?.delegate = self
//            self.showDeleteButton()
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tappedCreateNewVideo(_ cell: ProjectCell) {
    }
    
    func tappedPlayVideo(_ cell: ProjectCell) {
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewID.ProjectCell, for: indexPath) as! ProjectCell
//        InterfaceManager.makeRadiusControl(cell, cornerRadius: 6.0, withColor: UIColor.clear, borderSize: 0.0)
        
        cell.showInfo(indexPath.row == 0 ? true : false)
        if (indexPath.row > 0) {
            cell.m_imgThumbnail.image = TheProjectManger.thumbnails[indexPath.row - 1]
        }

//        InterfaceManager.makeRadiusControl(cell, cornerRadius: 6.0, withColor: UIColor.purple, borderSize: 0.0)

        if (self.bLongPressAvailable) {
            if (self.selectedIndexes.contains(indexPath.row)) {
//                InterfaceManager.makeRadiusControl(cell, cornerRadius: 6.0, withColor: UIColor.purple, borderSize: 4.0)
            }
        }
        
        cell.delegate = self
        
        cell.layoutIfNeeded()
        cell.setNeedsLayout()
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + TheProjectManger.thumbnails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 40.0) / 4.0
        let height: CGFloat = width * 0.75
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (bLongPressAvailable) {
            if (indexPath.row == 0) {
                return
            }
            
            if (self.selectedIndexes.contains(indexPath.row)) {
                self.selectedIndexes.remove(at: self.selectedIndexes.index(of: indexPath.row)!)
            } else {
                self.selectedIndexes.append(indexPath.row)
            }
            
            self.m_collectionView.reloadData()
            
            if (self.selectedIndexes.count == 0) {
                self.selectedIndexes.removeAll()
                self.bLongPressAvailable = false
                self.showDeleteButton()
                
                self.m_collectionView.reloadData()
                self.m_headerView?.m_imgThumbnail.image = (TheProjectManger.thumbnails.count > 0 ? TheProjectManger.thumbnails[0] : nil)            }
        } else {
            if (indexPath.row == 0) {
                TheProjectManger.curArrayIdx = -1
                
                self.goCameraView()
            } else {
                TheProjectManger.curArrayIdx = indexPath.row - 1
                
                TheVideoEditor.initEditorWithProject(TheProjectManger.getSelectedProject())
                
                let viewCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewIDs.NewEditViewController)
                self.navigationController?.pushViewController(viewCon!, animated: true)
            }
        }
    }
}

