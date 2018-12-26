//
//  MotionManager.swift
//  VideoGraph
//
//  Created by Admin on 17/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import CoreMotion

let TheMotionManager = MotionManager.sharedInstance

class MotionManager: NSObject {
    static let sharedInstance = MotionManager()
    
    let motionManager = CMMotionManager()
    
    let updateInterval: TimeInterval = 1.0/60.0
    var bStartTimer = false
    var timer: Timer? = nil
    
    var motionX: CGFloat = 0.0
    var motionY: CGFloat = 0.0
    
    var sensorView: CameraSensorView? = nil
    
    override init() {
        super.init()
    }
    
    func startMonitoring(_ sensorView: CameraSensorView) {
        self.sensorView = sensorView
        
        motionManager.accelerometerUpdateInterval = updateInterval
        //motionManager.startAccelerometerUpdates()
        //motionManager.startGyroUpdates()
        motionManager.startDeviceMotionUpdates()
        //motionManager.startMagnetometerUpdates()
        
        bStartTimer = true
        timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(onTick), userInfo: nil, repeats: true)
    }
    
    func stopMonitoring() {
        bStartTimer = false
        
        if (timer != nil) {
            timer!.invalidate()
        }
        
        timer = nil
        
        //motionManager.stopGyroUpdates()
        motionManager.stopDeviceMotionUpdates()
        //motionManager.stopAccelerometerUpdates()
        //motionManager.stopMagnetometerUpdates()
    }
    
    @objc func onTick() {
        if (!bStartTimer) {
            return
        }
        
        if let motionData = motionManager.deviceMotion {
            motionX = CGFloat(motionData.gravity.x)
            motionY = CGFloat(motionData.gravity.y)
            
            if (self.sensorView != nil) {
                self.sensorView!.setNeedsDisplay()
            }
        }
    }
}
