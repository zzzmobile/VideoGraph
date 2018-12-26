//
//  StringExtension.swift
//  VideoGraph
//
//  Created by Admin on 13/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import Foundation

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func substring(_ from: Int) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: from))
    }
    
    func encodeString() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }

    func encodeURLString() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }

    var length: Int {
        return self.characters.count
    }
    
    func trimString() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func customCapitalized() -> String {
        let str = self.capitalized
        var updated_str = str.replacingOccurrences(of: "And ", with: "and ")
        updated_str = updated_str.replacingOccurrences(of: "Or ", with: "or ")
        
        return updated_str
    }
    
    var isEmailValid: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    
    var isNameValid: Bool {
        let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9_ ].*", options: NSRegularExpression.Options())
        if regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(), range:NSMakeRange(0, self.characters.count)) != nil {
            return false
        } else {
            return true
        }
    }

    var isFullNameValid: Bool {
        let regex = try! NSRegularExpression(pattern: "([^\\s]+)\\s([^\\s]+)(.*)", options: NSRegularExpression.Options())
        if regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(), range:NSMakeRange(0, self.characters.count)) != nil {
            return true
        } else {
            return false
        }
    }

    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func removeSpecialCharactersInBirth() -> String {
        var updatedString = self.replacingOccurrences(of: "\\\"", with: "")
        updatedString = updatedString.replacingOccurrences(of: "\"", with: "")
        return updatedString
    }
    
    func convertToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.date(from: self)!
    }
    
    func convertToDateWithFormat(_ format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    func convertEmojiToUnicode() -> String {
        let encodedStr = NSString(cString: self.cString(using: String.Encoding.nonLossyASCII)!, encoding: String.Encoding.utf8.rawValue)
        return encodedStr as! String
        /*
         let data = self.dataUsingEncoding(NSNonLossyASCIIStringEncoding)
         let finalString = String.init(data: data!, encoding: NSUTF8StringEncoding)
         
         return finalString!
         */
    }
    
    func convertUnicodeToEmoji() -> String {
        let data = self.data(using: String.Encoding.utf8);
        let decodedStr = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue)
        if let decodeString = decodedStr as? String {
            return decodeString
        }
        
        return self
        
        /*
         let updatedString = self.stringByReplacingOccurrencesOfString("\\\\", withString: "\\")
         print("updated string - \(updatedString)")
         let data = updatedString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
         let finalString = String.init(data: data!, encoding: NSNonLossyASCIIStringEncoding)
         print("final string - \(finalString)")
         */
    }
    
    func chopPrefix(_ count: Int = 1) -> String {
        return substring(from: index(startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return substring(to: index(endIndex, offsetBy: -count))
    }
}
