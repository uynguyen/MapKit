//
//  FileUtility.swift
//  iTrust
//
//  Created by Uy Nguyen Long on 2/3/18.
//  Copyright © 2018 Uy Nguyen Long. All rights reserved.
//

import UIKit

class FileUtility: NSObject {
    
    // Private read-only
    static var documentDirectory:URL {
        get {
            return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory,
                                            in: FileManager.SearchPathDomainMask.userDomainMask).first!
        }
    }
    public static func save(string:String, pathComponent:String, fileName:String) -> URL? {
        var url:URL = FileUtility.documentDirectory.appendingPathComponent(pathComponent)
        let fileManager:FileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Can create new folter \(url.path), error: \(error.localizedDescription)")
                return nil
            }
        }
        
        // Append file name to url
        url = url.appendingPathComponent(fileName)
        do {
            try string.write(to: url, atomically: true, encoding: String.Encoding.ascii)
        } catch {
            print("Can not write date to url \(url.path), error: \(error.localizedDescription)")
            return nil
        }
        return url;
    }
    
    public static func listFiles(at:URL) -> [URL] {
        let fileManager:FileManager = FileManager.default
        do {
            return try fileManager.contentsOfDirectory(at: at,
                                                       includingPropertiesForKeys: nil,
                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
        } catch {
            print("Can list files at \(at.path), error: \(error.localizedDescription)")
        }
        
        return []
    }
    
    public static func save(data:Data, pathComponent:String, fileName:String) -> URL? {
        var url:URL = FileUtility.documentDirectory.appendingPathComponent(pathComponent)
        let fileManager:FileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Can create new folter \(url.path), error: \(error.localizedDescription)")
                return nil
            }
        }
        
        // Append file name to url
        url = url.appendingPathComponent(fileName)
        do {
            try data.write(to: url, options: Data.WritingOptions.atomic)
        } catch {
            print("Can not write date to url \(url.path), error: \(error.localizedDescription)")
            return nil
        }
        
        return url;
    }
    
    public static func delete(url:URL) -> Bool {
        let fileManager:FileManager = FileManager.default
        
        if fileManager.fileExists(atPath: url.path) {
            
            do {
                try fileManager.removeItem(at: url)
                print("Deleted file")
                return true
            } catch {
                print("Can not delete file at path:\(url.path), error:\(error.localizedDescription)")
                return false
            }
        }
        print("File is not exists atPath:\(url.path)")
        return false
    }
    
    public static func fileModificationDate(url:URL) -> Date? {
        let fileManager:FileManager = FileManager.default
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            return attributes[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
}
