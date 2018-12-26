//
//  ConstantManager.swift
//  VideoGraph
//
//  Created by Admin on 13/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages

let TheInterfaceManager = InterfaceManager.sharedInstance
let rootViewController =  UIApplication.shared.keyWindow?.rootViewController

extension UILabel {
    func addCharacterSpacing(_ value: CGFloat) {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedStringKey.kern, value: value, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

extension UITableViewCell {
    func setDisclosure(toColour: UIColor) -> () {
        for view in self.subviews {
            if let disclosure = view as? UIButton {
                if let image = disclosure.backgroundImage(for: .normal) {
                    let colouredImage = image.withRenderingMode(.alwaysTemplate);
                    disclosure.setImage(colouredImage, for: .normal)
                    disclosure.tintColor = toColour
                }
            }
        }
    }
}

extension NSAttributedString {
    func heightWithConstrainedWidth(width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.height
    }
    
}

extension UITextView {
    func takeFullScreenshot() -> UIImage {
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 1)
        
        // Draw view in that context
        drawHierarchy(in: self.frame, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        
        return UIImage()
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func takeScreenshot() -> UIImage {
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        
        return UIImage()
    }
    
    func takeScreenshotForExport() -> UIImage {
        // Begin context
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.bounds.size.width * UIScreen.main.scale, height: self.bounds.size.height * UIScreen.main.scale), false, 1.0)
        
        // Draw view in that context
        let newRect = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.size.width * UIScreen.main.scale, height: self.bounds.size.height * UIScreen.main.scale)
        drawHierarchy(in: newRect, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        
        return UIImage()
    }
}

extension UITableView {
    func setOffsetToBottom(_ animated: Bool) {
        self.setContentOffset(CGPoint(x: 0, y: self.contentSize.height - self.frame.size.height), animated: true)
    }
    
    func scrollToLastRow(_ animated: Bool) {
        if self.numberOfRows(inSection: 0) > 0 {
            self.scrollToRow(at: IndexPath(row: self.numberOfRows(inSection: 0) - 1, section: 0), at: .bottom, animated: animated)
        }
    }
}

extension UIImage {
    public func circularImage(_ size: CGSize?) -> UIImage {
        let newSize = size ?? self.size
        
        let minEdge = min(newSize.height, newSize.width)
        let size = CGSize(width: minEdge, height: minEdge)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        self.draw(in: CGRect(origin: CGPoint.zero, size: size), blendMode: .copy, alpha: 1.0)
        
        context!.setBlendMode(.copy)
        context!.setFillColor(UIColor.clear.cgColor)
        
        let rectPath = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: size))
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
        rectPath.append(circlePath)
        rectPath.usesEvenOddFillRule = true
        rectPath.fill()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result!
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x:0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    public func imageRotatedByDegrees(_ degrees: CGFloat, flip: Bool) -> UIImage {
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(Double.pi))
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(Double.pi)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
        let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, 1.0)
        //UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap!.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        bitmap!.rotate(by: degreesToRadians(degrees));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        bitmap!.scaleBy(x: yFlip, y: -1.0)
        bitmap!.draw(cgImage!, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func fixImageOrientation() -> UIImage
    {
        
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi));
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0);
            transform = transform.rotated(by: CGFloat(Double.pi / 2));
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-Double.pi / 2));
            
        case .up, .upMirrored:
            break
        }
        
        
        switch self.imageOrientation {
            
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1);
            
        default:
            break;
        }
        
        
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGContext(
            data: nil,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: self.cgImage!.bitsPerComponent,
            bytesPerRow: 0,
            space: self.cgImage!.colorSpace!,
            bitmapInfo: UInt32(self.cgImage!.bitmapInfo.rawValue)
        )
        
        ctx!.concatenate(transform);
        
        switch self.imageOrientation {
            
        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            ctx!.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height,height: self.size.width));
            
        default:
            ctx!.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width,height: self.size.height));
            break;
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg = ctx!.makeImage()
        
        let img = UIImage(cgImage: cgimg!)
        
        //CGContextRelease(ctx);
        //CGImageRelease(cgimg);
        
        return img;
        
    }
}

extension UIImageView {
    func downloadedFrom(link:String, indicatorStyle: UIActivityIndicatorViewStyle, contentMode mode: UIViewContentMode) {
        guard
            let url = URL(string: link)
            else {return}
        contentMode = mode
        let loadingActivity = UIActivityIndicatorView(activityIndicatorStyle: indicatorStyle)
        loadingActivity.tag = 10
        loadingActivity.frame = self.bounds
        self.addSubview(loadingActivity)
        loadingActivity.startAnimating()
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else
                {
                    loadingActivity.stopAnimating()
                    loadingActivity.removeFromSuperview()
                    return
                }
            DispatchQueue.main.async { () -> Void in
                loadingActivity.stopAnimating()
                loadingActivity.removeFromSuperview()
                self.image = image
            }
        }).resume()
    }
}

let appDelegate = UIApplication.shared.delegate as! AppDelegate//Your app delegate class name.
extension UIApplication {
    class func topViewController(_ base: UIViewController? = appDelegate.window!.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

class InterfaceManager: NSObject, UIAlertViewDelegate {
    static let sharedInstance = InterfaceManager()
    var appName:String = ""

    var nSelectedMenu: EditMenu = .Video
    var nSelectedSubMenu: Int = 0

    let mainColor:UIColor = UIColor(red: 77.0/255.0, green: 181.0/255.0, blue: 219.0/255.0, alpha: 1.0)
    let borderColor:UIColor = UIColor(red: 151.0 / 255.0, green: 151.0 / 255.0, blue: 151.0 / 255.0, alpha: 1.0)
    let naviTintColor:UIColor = UIColor(red: 252.0/255.0, green: 110.0/255.0, blue: 81.0/255.0, alpha: 1.0)
    
    override init() {
        super.init()
        let bundleInfoDict: NSDictionary = Bundle.main.infoDictionary! as NSDictionary
        appName = bundleInfoDict["CFBundleName"] as! String
    }
    
    func deviceHeight ()-> CGFloat{
        return UIScreen.main.bounds.size.height
    }
    
    func deviceWidth () -> CGFloat{
        return UIScreen.main.bounds.size.width
    }
    
    func checkiPhoneX() -> Bool {
        var bYes: Bool = false
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
            case 1334:
                print("iPhone 6/6S/7/8")
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                print("iPhone X")
                bYes = true
            default:
                print("unknown")
            }
        }
        
        return bYes
    }
    
    static func evaluateStringSize (font: UIFont, textToEvaluate: String) -> CGSize {
        let sizeOfText: CGSize = textToEvaluate.size(withAttributes: [NSAttributedStringKey.font: font])
        
        return sizeOfText //sizeOfText.width
    }
    
    static func circleAnim(_ view: UIView, _ duration: CFTimeInterval, _ fillColor: UIColor, _ bShow: Bool) {
        let maskDiameter = CGFloat(sqrtf(powf(Float(view.bounds.width), 2) + powf(Float(view.bounds.height), 2)))
        let mask = CAShapeLayer()
        let animationId = "path"
        
        // Make a circular shape.
        if (bShow) {
            mask.path = UIBezierPath(roundedRect: CGRect(x: maskDiameter / 2, y: maskDiameter / 2, width: 0, height: 0), cornerRadius: 0).cgPath
        } else {
            mask.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: maskDiameter, height: maskDiameter), cornerRadius: maskDiameter / 2).cgPath
        }
        
        // Center the shape in the view.
        mask.position = CGPoint(x: (view.bounds.width - maskDiameter) / 2, y: (view.bounds.height - maskDiameter) / 2)
        
        // Fill the circle.
        mask.fillColor = fillColor.cgColor
        
        // Add as a mask to the parent layer.
        view.layer.mask = mask
        
        // Animate.
        let animation = CABasicAnimation(keyPath: animationId)
        animation.duration = duration
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        // Create a new path.
        var newPath: CGPath
        if (bShow) {
            newPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: maskDiameter, height: maskDiameter), cornerRadius: maskDiameter / 2).cgPath
        } else {
            newPath = UIBezierPath(roundedRect: CGRect(x: maskDiameter / 2, y: maskDiameter / 2, width: 0, height: 0), cornerRadius: 0).cgPath
        }
        
        // Set start and end values.
        animation.fromValue = mask.path
        animation.toValue = newPath
        
        // Start the animaiton.
        mask.add(animation, forKey: animationId)
    }
    
    static func doZoomAnimation(_ view: UIView, needAlpha: Bool, completion: @escaping () -> Void) {
        view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2);
        view.alpha = 0.0

        UIView.animate(withDuration: 0.3, animations: {
            view.transform = CGAffineTransform.identity
            view.alpha = 1.0
        }) { (bFinished) in
            if (bFinished) {
                completion()
            }
        }
    }
    
    static func doCounterAnimation (_ view: UIView, completion: @escaping () -> Void) {
        if view.isHidden == true {
            view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6);
        }
        
        view.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            view.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            view.alpha = 0.8
        },
                       completion: {(bCompleted) -> Void in
                        UIView.animate(withDuration: 0.4, animations: {() -> Void in
                            view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                            view.alpha = 0.9
                        },
                                       completion: {(bCompleted) -> Void in
                                        UIView.animate(withDuration: 0.3, animations: {() -> Void in
                                            view.transform = CGAffineTransform.identity
                                            view.alpha = 1.0
                                        },
                                                       completion: {(bCompleted) -> Void in
                                                        if (bCompleted) {
                                                            completion()
                                                        }
                                        })
                        })
                        
        })
    }
    
    static func doPopUpAnimation (_ view: UIView, needAlpha: Bool, completion: @escaping () -> Void) {
        if view.isHidden == true {
            view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6);
        }
        
        view.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            view.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            view.alpha = 0.8
        },
                       completion: {(bCompleted) -> Void in
                        UIView.animate(withDuration: 1/15.0, animations: {() -> Void in
                            view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                            view.alpha = 0.9
                        },
                                       completion: {(bCompleted) -> Void in
                                        UIView.animate(withDuration: 1/7.5, animations: {() -> Void in
                                            view.transform = CGAffineTransform.identity
                                            view.alpha = 1.0
                                            if (needAlpha) {
                                                view.alpha = 0.3
                                            }
                                        },
                                                       completion: {(bCompleted) -> Void in
                                                        if (bCompleted) {
                                                            completion()
                                                        }
                                        })
                        })
                        
        })
    }
    
    static func doHidePopUpAnimation (_ view: UIView, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            view.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            view.alpha = 1.0
        },
                       completion: {(bCompleted) -> Void in
                        UIView.animate(withDuration: 0.3, animations: {() -> Void in
                            view.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                            view.alpha = 0.0
                        },
                                       completion: {(bCompleted) -> Void in
                                        if (bCompleted) {
                                            completion()
                                        }
                        })
                        
        })
    }
    
    static func showMessage(_ success: Bool, title: String, bBottomPos: Bool, bDefaultStatus: Bool = true) {
        DispatchQueue.main.async(execute: {
            let message = MessageView.viewFromNib(layout: .cardView)
            let themeType: Theme = success ? .success : .error
            message.configureTheme(themeType)
            message.configureDropShadow()
            message.configureContent(title: success ? "Success" : "Error", body: title)
            message.button?.isHidden = true
            var messageConfing = SwiftMessages.defaultConfig
            messageConfing.presentationStyle = (bBottomPos ? .bottom : .top) as SwiftMessages.PresentationStyle
            messageConfing.presentationContext = .window(windowLevel: UIWindowLevelNormal)
            messageConfing.preferredStatusBarStyle = bDefaultStatus ? .default : .lightContent
            SwiftMessages.show(config: messageConfing, view: message)
        })
    }
    
    static func showWarningMessage(_ title: String, bBottomPos: Bool, bDefaultStatus: Bool = true) {
        DispatchQueue.main.async(execute: {
            let message = MessageView.viewFromNib(layout: .cardView)
            let themeType: Theme = .warning
            message.configureTheme(themeType)
            message.configureDropShadow()
            message.configureContent(title:"Warning", body: title)
            message.button?.isHidden = true
            var messageConfing = SwiftMessages.defaultConfig
            messageConfing.presentationStyle = (bBottomPos ? .bottom : .top) as SwiftMessages.PresentationStyle
            messageConfing.presentationContext = .window(windowLevel: UIWindowLevelNormal)
            messageConfing.preferredStatusBarStyle = bDefaultStatus ? .default : .lightContent
            SwiftMessages.show(config: messageConfing, view: message)
        })
    }
    
    static func showLoadingView(_ title: String = "") {
        let topView = UIApplication.topViewController()?.view
        
        let loadingView = MBProgressHUD.init(view: topView!)
        topView!.addSubview(loadingView!)
        
        loadingView!.tag = 1100
        loadingView!.labelText = title
        loadingView!.labelColor = UIColor.white
        loadingView!.dimBackground = true
        
        loadingView!.show(true)
    }
    
    static func hideLoadingView() {
        let topView = UIApplication.topViewController()?.view

        var loadingView = topView!.viewWithTag(1100) as? MBProgressHUD
        if (loadingView != nil) {
            loadingView?.hide(true)
            loadingView?.removeFromSuperview()
            loadingView = nil
        }
    }
    
    static func createShadowLayer() -> CALayer {
        let shadowLayer = CALayer()
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize.zero
        shadowLayer.shadowRadius = 3.0
        shadowLayer.shadowOpacity = 0.8
        shadowLayer.backgroundColor = UIColor.clear.cgColor
        
        return shadowLayer
    }
    
    static func scaleImage(_ image: UIImage, toSize newSize: CGSize) -> (UIImage) {
        let newRect = CGRect(x: 0,y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context!.interpolationQuality = .high
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
        context!.concatenate(flipVertical)
        context!.draw(image.cgImage!, in: newRect)
        let newImage = UIImage(cgImage: context!.makeImage()!)
        UIGraphicsEndImageContext()
        return newImage
    }
    
    static func imageWithColor(_ color:UIColor) -> UIImage {
        let rect:CGRect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(color.cgColor);
        context.fill(rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }

    static func showAlertView(_ message: String) {
        let alertController = UIAlertController(title: Constants.AppName, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    static func heightForView(_ text:String, font: UIFont, width: CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }

    static func makeRadiusControl(_ view:UIView, cornerRadius radius:CGFloat, withColor borderColor:UIColor, borderSize borderWidth:CGFloat) {
        view.layer.cornerRadius = radius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
        view.layer.masksToBounds = true
    }
    
    static func addShadowToView(_ view: UIView, _ shadow_color: UIColor, _ offset: CGSize, _ shadow_radius: CGFloat, _ corner_radius: CGFloat) {
        view.layer.shadowColor = shadow_color.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = offset
        view.layer.shadowRadius = shadow_radius
        view.layer.cornerRadius = corner_radius
    }
    
    static func addShadowToViewWithBorder(_ view: UIView, _ shadow_color: UIColor, _ offset: CGSize, _ shadow_radius: CGFloat, _ corner_radius: CGFloat, _ border_color: UIColor, _ border_width: CGFloat = 1.0) {
        view.layer.shadowColor = shadow_color.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = offset
        view.layer.shadowRadius = shadow_radius
        view.layer.cornerRadius = corner_radius
        view.layer.borderColor = border_color.cgColor
        view.layer.borderWidth = border_width
    }
    
    static func addBorderToView(_ view:UIView, toCorner corner:UIRectCorner, cornerRadius radius:CGSize, withColor borderColor:UIColor, borderSize borderWidth:CGFloat) {
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corner, cornerRadii: radius)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path  = maskPath.cgPath
        
        view.layer.mask = maskLayer
        
        let borderLayer = CAShapeLayer()
        borderLayer.frame = view.bounds
        borderLayer.path  = maskPath.cgPath
        borderLayer.lineWidth   = borderWidth
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor   = UIColor.clear.cgColor
        borderLayer.setValue("border", forKey: "name")
        
        if let sublayers = view.layer.sublayers {
            for prevLayer in sublayers {
                if let name: AnyObject = prevLayer.value(forKey: "name") as AnyObject {
                    if name as! String == "border" {
                        prevLayer.removeFromSuperlayer()
                    }
                }
            }
        }
        
        view.layer.addSublayer(borderLayer)
    }
    
    static func addGlowEffect(_ view: UIView, color: UIColor, radius: CGFloat) {
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = radius
        view.layer.shadowOpacity = 1.0
        view.layer.masksToBounds = false
        //view.layer.shouldRasterize = true
    }

}
