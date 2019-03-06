//
//  GlobalPool.swift
//  BackEraser
//
//  Created by Admin on 25/07/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyStoreKit

let TheGlobalPoolManager = GlobalPool.sharedInstance

class GlobalPool: NSObject {
    static let sharedInstance = GlobalPool()
    
    var tempCameraViewOffset: CGFloat = 0.0

    var rootViewCon: ViewController? = nil
    
    var allFonts: [String] = []
    
    var cameraSettings: CameraSettings = CameraSettings.init()

    override init() {
        super.init()
    }

    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName )
            print("Font Names = [\(names)]")
        }
    }
    
    func getAllFonts() {
        var fonts: [String] = []
        
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            let names = UIFont.fontNames(forFamilyName: familyName)
            
            if (names.count == 0) {
                continue
            } else if (names.count == 1) {
                //fonts.append(names[0])
                continue
            } else {
                for name in names {
                    if (name.contains("-Regular")) {
                        fonts.append(name)
                        break
                    }
                    
                    if (name.contains("-") == false) {
                        //fonts.append(name)
                        break
                    }
                }
            }
        }
        
        self.allFonts = fonts
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(GlobalPool.appDroppedBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GlobalPool.appReactivatedForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appDroppedBackground() {
        print("app goes to background")
    }
    
    @objc func appReactivatedForeground() {
        print("app goes to foreground")
    }

    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        } else {
            return "1.0"
        }
    }
    
    func checkAppFirstOpen() -> Bool {
        return !UserDefaults.standard.bool(forKey: "app_first_open")
    }
    
    func appOpendedAtFirst() {
        UserDefaults.standard.set(true, forKey: "app_first_open")
        UserDefaults.standard.synchronize()
    }

    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }

    func eraseFile(_ fileName: String) {
        let fileMngr = FileManager.default;
        let directoryURLs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pathURL = directoryURLs.appendingPathComponent(fileName)
        
        try? fileMngr.removeItem(at: pathURL)
    }
    
    func copyFile(_ fileName: String, _ newFileName: String) {
        let fileMngr = FileManager.default;
        let directoryURLs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pathURL = directoryURLs.appendingPathComponent(fileName)
        
        let newPathURL = directoryURLs.appendingPathComponent(newFileName)
        if (fileMngr.fileExists(atPath: newPathURL.path)) {
            try? fileMngr.removeItem(at: newPathURL)
        }
        
        try? fileMngr.copyItem(at: pathURL, to: newPathURL)
    }
    
    func getVideoURL(_ newFileName: String) -> URL {
        let fileMngr = FileManager.default;
        let directoryURLs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videoURL = directoryURLs.appendingPathComponent(newFileName)
        
        return videoURL
    }
    
    func getTempColorBetweenTwoColors(_ percent: CGFloat) -> UIColor {
        let resultRed = Constants.Colors.TempLow.redValue + Int(percent * CGFloat(Constants.Colors.TempHigh.redValue - Constants.Colors.TempLow.redValue))
        let resultGreen = Constants.Colors.TempLow.greenValue + Int(percent * CGFloat(Constants.Colors.TempHigh.greenValue - Constants.Colors.TempLow.greenValue))
        let resultBlue = Constants.Colors.TempLow.blueValue + Int(percent * CGFloat(Constants.Colors.TempHigh.blueValue - Constants.Colors.TempLow.blueValue))
        
        return UIColor(red: resultRed, green: resultGreen, blue: resultBlue)
    }
    
    func getTintColorBetweenTwoColors(_ percent: CGFloat) -> UIColor {
        let resultRed = Constants.Colors.TintLow.redValue + Int(percent * CGFloat(Constants.Colors.TintHigh.redValue - Constants.Colors.TintLow.redValue))
        let resultGreen = Constants.Colors.TintLow.greenValue + Int(percent * CGFloat(Constants.Colors.TintHigh.greenValue - Constants.Colors.TintLow.greenValue))
        let resultBlue = Constants.Colors.TintLow.blueValue + Int(percent * CGFloat(Constants.Colors.TintHigh.blueValue - Constants.Colors.TintLow.blueValue))
        
        return UIColor(red: resultRed, green: resultGreen, blue: resultBlue)
    }

    // MARKL: - Image Management in Local
    func getUniqueImageName() -> String{
        let timeString = "\(NSDate.timeIntervalSinceReferenceDate)"
        return timeString.replacingOccurrences(of: ".", with: "")
    }
    
    func saveImage(_ image: UIImage, _ imageName: String) -> Bool {
        deleteImage(imageName)
        
        let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pathURL = directoryURLs.appendingPathComponent(imageName)
        
        let imageData = image.pngData()
        
        var bResult: Bool = false
        
        do {
            try imageData?.write(to: pathURL)
            bResult = true
        } catch let error as NSError {
            print(error.debugDescription)
        }
        
        return bResult
    }
    
    func loadImage(_ imageName: String) -> UIImage? {
        let fileMngr = FileManager.default;
        let directoryURLs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pathURL = directoryURLs.appendingPathComponent(imageName)
        
        guard let image = UIImage(contentsOfFile: pathURL.path) else {
            return nil
        }
        
        /*
         let imageSize = image.size
         UIGraphicsBeginImageContextWithOptions(CGSize(width: imageSize.width, height: imageSize.height), false, 0);
         image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
         let finalImage = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         */
        
        return image
    }
    
    func deleteImage(_ imageName: String) {
        let fileMngr = FileManager.default;
        let directoryURLs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pathURL = directoryURLs.appendingPathComponent(imageName)
        
        try? fileMngr.removeItem(at: pathURL)
    }

}
