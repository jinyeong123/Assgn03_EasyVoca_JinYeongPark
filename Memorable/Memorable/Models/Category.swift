//
//  Category.swift
//  Memorable
//
//
//  Created by Paige 🇰🇷 on 12/5/2023.
//

import Foundation
import os.log

struct PropertyKey {
    static let name = "name"
}

class Category: NSObject, NSCoding {
    
// Properties
    
    var name: String
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("categories")
    
// Initialisers
    
    init(name: String) {
        self.name = name
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Category object.", log: OSLog.default, type: .debug)
            return nil
        }
        self.init(name: name)
    }
    
// NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
    }
    
}
