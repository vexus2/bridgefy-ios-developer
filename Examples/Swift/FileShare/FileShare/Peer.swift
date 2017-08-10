//
//  Peer.swift
//  FileShare
//
//  Created by Calvin on 6/20/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit

enum DeviceType : Int {
    case undefined = 0
    case android
    case ios
}

class Peer: NSObject {
    
    var uuid: String
    var name: String?
    var deviceType: DeviceType
    var files: [FileInfo]
    
    required public init(uuid: String) {
        self.uuid = uuid
        self.deviceType = .undefined
        self.files = []
    }
    
    func formattedName() -> String {
        
        let index = self.uuid.index(self.uuid.startIndex, offsetBy: 5)
        let idFragment = self.uuid.substring(to: index)
        
        guard self.name != nil else {
            return idFragment
        }
        
        return "\(String(describing: self.name)) (\(idFragment))"
    }
    
    func createFiles(files: [[String: Any]]) {
        self.files = Array()
        
        for fileDictionary in files {
            let fileInfo = FileInfo(dictionary: fileDictionary)
            
            self.files.append(fileInfo!)
        }
    }
    
    func file(with uuid: String) -> FileInfo? {
        for file in self.files {
            if file.uuid == uuid {
                return file
            }
        }
        
        return nil
    }
    
    override var description: String {
        return "ID: \(self.uuid)\nName: \(self.name ?? "Not available")\nType: \(self.deviceType)\nFiles: \(String(describing: self.files))"
    }
    
}
