//
//  ProjectManger.swift
//  VideoGraph
//
//  Created by Admin on 18/09/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

let TheProjectManger = ProjectManger.sharedInstance

class ProjectManger: NSObject {
    static let sharedInstance = ProjectManger()
    
    var realProjectIdx: [Int] = []
    var thumbnails: [UIImage] = []
    var projects: [Project] = []
    
    var nLastProjectIdx: Int = 0
    var curArrayIdx: Int = -1
    
    override init() {
        super.init()
    }

    func loadProjects() {
        self.realProjectIdx.removeAll()
        self.thumbnails.removeAll()
        self.projects.removeAll()
        
        for nIdx in 0..<1000 {
            let name = "Project_\(nIdx)"
            
            let bExist = UserDefaults.standard.bool(forKey: name)
            if (!bExist) {
                continue
            }
            
            let thumbnailName = "\(name)_thumbnail.png"
            let thumbnail = TheGlobalPoolManager.loadImage(thumbnailName)
            self.thumbnails.append(thumbnail!)
            
            let project = Project.init(nIdx)
            self.projects.append(project)
            
            self.realProjectIdx.append(nIdx)
            
            self.nLastProjectIdx = nIdx
        }
    }
    
    func getSelectedProject() -> Project {
        return self.projects[self.curArrayIdx]
    }
    
    func addProject(_ thumbnail: UIImage, _ project: Project, _ finalVideoName: String, _ completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            let name = "Project_\(self.nLastProjectIdx + 1)"
            let thumbnailName = "\(name)_thumbnail.png"
            
            if (!TheGlobalPoolManager.saveImage(thumbnail, thumbnailName)) {
                DispatchQueue.main.async {
                    completion()
                    return
                }
            }
            
            var mutableProject: Project = project
            
            UserDefaults.standard.set(thumbnailName, forKey: "\(name)_thumbnail")
            UserDefaults.standard.set(TheVideoEditor.editSettings.originalVideoName, forKey: "\(name)_video")
            mutableProject.saveProject(self.nLastProjectIdx + 1, finalVideoName)
            
            UserDefaults.standard.set(true, forKey: name)
            
            UserDefaults.standard.synchronize()
            
            self.thumbnails.append(thumbnail)
            self.projects.append(mutableProject)
            
            self.nLastProjectIdx += 1
            self.realProjectIdx.append(self.nLastProjectIdx)
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func updateProject(_ thumbnail: UIImage, _ project: Project, _ finalVideoName: String, _ completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            let name = "Project_\(self.realProjectIdx[self.curArrayIdx])"
            let thumbnailName = "\(name)_thumbnail.png"
            
            if (!TheGlobalPoolManager.saveImage(thumbnail, thumbnailName)) {
                DispatchQueue.main.async {
                    completion()
                    return
                }
            }
            
            var mutableProject: Project = project

            UserDefaults.standard.set(thumbnailName, forKey: "\(name)_thumbnail")
            UserDefaults.standard.set(project.editSettings.originalVideoName, forKey: "\(name)_video")
            mutableProject.saveProject(self.realProjectIdx[self.curArrayIdx], finalVideoName)
            
            UserDefaults.standard.set(true, forKey: name)
            
            UserDefaults.standard.synchronize()

            self.thumbnails[self.curArrayIdx] = thumbnail
            self.projects[self.curArrayIdx] = mutableProject
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func deleteProject(_ nArrayIdx: Int, _ completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            let name = "Project_\(self.realProjectIdx[nArrayIdx])"
            
            let thumbnailName = "\(name)_thumbnail.png"
            TheGlobalPoolManager.deleteImage(thumbnailName)
            
            if let videoName = UserDefaults.standard.value(forKey: "\(name)_video") as? String {
                TheGlobalPoolManager.eraseFile(videoName)
            }
            
            let project = self.projects[nArrayIdx]
            project.deleteData(self.realProjectIdx[nArrayIdx])
            
            self.thumbnails.remove(at: nArrayIdx)
            self.projects.remove(at: nArrayIdx)
            
            UserDefaults.standard.set(false, forKey: name)
            UserDefaults.standard.synchronize()

            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func deleteProjects(_ ids: [Int]) {
        for nIdx in 0..<ids.count {
            let nArrayIdx = ids[nIdx] - 1
            
            let name = "Project_\(self.realProjectIdx[nArrayIdx])"
            
            let thumbnailName = "\(name)_thumbnail.png"
            TheGlobalPoolManager.deleteImage(thumbnailName)
            
            if let videoName = UserDefaults.standard.value(forKey: "\(name)_video") as? String {
                TheGlobalPoolManager.eraseFile(videoName)
            }
            
            let project = self.projects[nArrayIdx]
            project.deleteData(self.realProjectIdx[nArrayIdx])
            
            self.thumbnails.remove(at: nArrayIdx)
            self.projects.remove(at: nArrayIdx)
            
            UserDefaults.standard.set(false, forKey: name)
            UserDefaults.standard.synchronize()
        }
    }
}
