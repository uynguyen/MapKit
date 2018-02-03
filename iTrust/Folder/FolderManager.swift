//
//  FolderManager.swift
//  iTrust
//
//  Created by Uy Nguyen Long on 2/3/18.
//  Copyright © 2018 Uy Nguyen Long. All rights reserved.
//

import UIKit

class FolderManager: NSObject {
    static let instance = FolderManager()
    
    private override init () {
        
    }
    
    fileprivate func createFolder(name: String) {
        let url:URL = FileUtility.documentDirectory.appendingPathComponent(name)
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                LoggerManager.instance.error("Can not create new folter, error: \(error.localizedDescription)")
            }
        }
    }
    
    func checkIfExistAsset(path: String) -> Bool {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(path)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
}
