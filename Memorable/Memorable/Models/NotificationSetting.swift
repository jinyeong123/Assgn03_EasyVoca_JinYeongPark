//
//  NotificationSetting.swift
//  Memorable
//
//
//  Created by Paige 🇰🇷 on 12/5/2023.
//

import Foundation
import os.log

class NotificationSetting: NSObject, NSCoding {
 
    var memorable: Memorable
    var repeatInterval: Int
    var turnOnOff: Bool
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("notificationSetting")
    
    init(memorable: Memorable, repeatInterval: Int, turnOnOff: Bool) {
        self.memorable = memorable
        self.repeatInterval = repeatInterval
        self.turnOnOff = turnOnOff
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let memorable = aDecoder.decodeObject(forKey: "memorable") as? Memorable else {
            os_log("Unable to decode the memorable for a NotificationSetting object.", log: OSLog.default, type: .debug)
            return nil
        }
        let repeatInterval = aDecoder.decodeInteger(forKey: "repeatInterval")
        let turnOnOff = aDecoder.decodeBool(forKey: "turnOnOff")
        self.init(memorable: memorable, repeatInterval: repeatInterval, turnOnOff: turnOnOff)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(memorable, forKey: "memorable")
        aCoder.encode(repeatInterval, forKey: "repeatInterval")
        aCoder.encode(turnOnOff, forKey: "turnOnOff")
    }
    
}
