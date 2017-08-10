//
//  FileInfo.swift
//  FileShare
//
//  Created by Calvin on 6/19/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit

let DESTINATION_DIRECTORY = URL(fileURLWithPath: (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("savedFiles"))
let kUuid = "uuid"
let kcontentType = "content_type"
let kName = "name"
let kSize = "size"
let kPart = "part"
let kFragments = "fragments"
let FRAGMENT_SIZE = 2000000.0

open class FileInfo: NSObject, NSCoding {
    
    var uuid: String
    var name: String
    var type: String?
    var size: Int?
    var fragments: Int?
    var local: Bool
    var downloading: Bool
    var path: String
    
//    open var hashValue: Int {
//        return uuid.hash ^ name.hash
//    }
    
    required public init(_ name: String) {
        self.uuid = "";
        self.name = name;
        self.local = false;
        self.downloading = false;
        self.path = DESTINATION_DIRECTORY.appendingPathComponent(self.name).path
    }
    
    convenience init?(dictionary: [String: Any]) {
        
        guard
            let uuid = dictionary[kUuid],
            let name = dictionary[kName] else {
            return nil
        }
        
        self.init(name as! String)
        
        self.uuid = uuid as! String
        self.type = (dictionary[kcontentType] as! String)
        self.name = (dictionary[kName] as! String)
        self.size = (dictionary[kSize] as! Int)
        self.fragments = (dictionary[kFragments] as! Int)
        self.downloading = false
        
        // TODO: Determinar si el archivo ya se encuentra localmente
        self.local = false
    }
    
    convenience init?(path: String) {
        
        let name = (path as NSString).lastPathComponent
        
        self.init(name)
        
        self.uuid = UUID().uuidString   // An unique id is created for the file
        self.local = true
        self.downloading = false
        
        if !self.calculateValues() {
            return nil
        }
    }
    
    public convenience required init?(coder decoder: NSCoder) {
        self.init(decoder.decodeObject(forKey: kName) as! String)
        
        self.uuid =  decoder.decodeObject(forKey: kUuid) as! String
        self.local = true
        self.downloading = false
        
        if !self.calculateValues() {
            return nil
        }
    }
    
    open func encode(with encoder: NSCoder) {
        encoder.encode(self.uuid, forKey: kUuid)
        encoder.encode(self.name, forKey: kName)
        
    }
    
    func calculateValues() -> Bool {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: self.path))
            self.size = data.count
            self.type = (self.path as NSString).pathExtension
            self.fragments = self.calculateFileFragments()
            return true
        } catch {
            return false
        }
    }
    
    func fileDictionary() -> [String: Any] {
        return [
                kUuid: self.uuid as Any,
                kcontentType: self.type as Any,
                kName: self.name as Any,
                kSize: self.size as Any,
                kFragments: self.fragments as Any
                ]
    }
    
    func calculateFileFragments() -> Int {
        return Int(ceil(Double(self.size!) / FRAGMENT_SIZE))
    }
    
    func data(fragment: Int) -> Data {
        // TODO: Obtener el fragmento solicitado
        return Data()
    }
    
    func formattedFileSize() -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(self.size!))
    }
    
    open override var description: String {
        return "UUID: \(self.uuid)\nName: \(self.name)\nType: \(self.type ?? "Not defined")\nSize: \(self.size ?? 0)\nFragments: \(self.fragments ?? 0)"
    }
    
    public static func ==(lhs: FileInfo, rhs: FileInfo) -> Bool {
        return (lhs.uuid == rhs.uuid) && (lhs.name == rhs.name)
    }
}
