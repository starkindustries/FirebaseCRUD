//
//  File.swift
//  FirebaseCRUD
//
//  Created by Zion Perez on 12/31/17.
//  Copyright © 2017 Zion Perez. All rights reserved.
//

import Foundation

struct File: CustomStringConvertible {
    
    enum field: String {
        case userId, filename, filedata
    }
    
    var fileId: String?
    var userId: String?
    var filename: String?
    var filedata: String?
    
    init() {}
    
    init(uid: String?, name: String?, data: String?) {
        userId = uid
        filename = name
        filedata = data
    }
    
    init(uid: String?, name: String?, data: String?, id: String?) {
        self.init(uid: uid, name: name, data: data) 
        self.fileId = id
    }
    
    init(data: [String: Any]) {
        userId = data[field.userId.rawValue] as? String
        filename = data[field.filename.rawValue] as? String
        filedata = data[field.filedata.rawValue] as? String
    }
    
    init(data: [String: Any], id: String?) {
        self.init(data: data)
        self.fileId = id
    }
    
    func getDictionaryData() -> [String: Any] {
        let data: [String: Any] = [
            field.userId.rawValue: userId ?? "",
            field.filename.rawValue: filename ?? "",
            field.filedata.rawValue: filedata ?? ""
        ]
        return data
    }
    
    // CustomStringConvertible
    var description: String {
        return "[User ID: \(userId ?? "")] [filename: \(filename ?? "")] [filedata: \(filedata ?? "")]"
    }
}
