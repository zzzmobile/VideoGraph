//
//  UndoManager.swift
//  VideoGraph
//
//  Created by Admin on 18/09/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

let TheUndoManager = UndoManager.sharedInstance

class UndoManager: NSObject {
    static let sharedInstance = UndoManager()
    
    var actions: [Project] = []
    var bChanged: Bool = false
    
    override init() {
        super.init()
    }

    func resetManager() {
        self.bChanged = false
        self.actions.removeAll()
    }
    
    func getLastProject() -> Project {
        return self.actions.last!
    }
    
    func addAction(_ action: Project) {
        self.actions.append(action)
        self.bChanged = true
    }

    func checkUndoAvailable() -> Bool {
        var bUndoAvailable: Bool = false
        if (self.actions.count > 1) {
            bUndoAvailable = true
        }
        
        return bUndoAvailable
    }
    
    func doUndo() {
        if (self.actions.count == 1) {
            return
        }
        
        self.actions.removeLast()
        
        guard let project = self.actions.last else {
            return
        }
        
        for fontObject in TheVideoEditor.fontObjects {
            fontObject.doDeleteForUndo()
        }
        
        //undo process
        TheVideoEditor.editSettings = project.editSettings
        TheVideoEditor.bChangedTint = project.bChangedTint
        TheVideoEditor.bChangedTemperature = project.bChangedTemperature
        TheVideoEditor.bChangedToneCurve = project.bChangedToneCurve
        
        TheVideoEditor.cropSettings = project.cropSettings
        TheVideoEditor.priorCropSettings = project.priorCropSettings
        
        TheVideoEditor.stillImage = project.stillImage
        TheVideoEditor.initialStillImageSize = project.stillImageSize
        
        TheVideoEditor.currentMaskImageForUndo = project.currentMaskImage
        TheVideoEditor.originalMaskImageForUndo = project.originalMaskImage
        
        TheVideoEditor.fontObjects = project.fontObjects
        TheVideoEditor.selectedFontObjectIdx = project.selectedObjectIdx
        
        TheVideoEditor.fTrimLeftOffset = project.leftTrimOffset
        TheVideoEditor.fTrimRightOffset = project.rightTrimOffset
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.didUndoProcess), object: nil, userInfo: nil)
    }
    
}
