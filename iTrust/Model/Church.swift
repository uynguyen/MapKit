//
//  Church.swift
//  iTrust
//
//  Created by Uy Nguyen Long on 2/1/18.
//  Copyright © 2018 Uy Nguyen Long. All rights reserved.
//

import UIKit
import SwiftyJSON
import FirebaseStorage
import PromiseKit

let imageExt = ".jpg"

class Church: NSObject {
    var id: Int
    var name: String
    var link: String
    var strCN: String
    var CN: Array<Date>
    var address: String
    
    var imagePath: String {
        get {
            return "\(self.id)\(imageExt)"
        }
    }
    
    
    var image: UIImage? {
        get {
            if FolderManager.instance.checkIfExistAsset(path: self.imagePath) {
                let url = FileUtility.documentDirectory.appendingPathComponent(self.imagePath, isDirectory: false)
                return UIImage.init(contentsOfFile: url.path)
            }
            return nil
        }
    }
    
    
    public init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.link = json["link"].stringValue
        self.strCN = json["strCN"].stringValue
        self.address = json["address"].stringValue
        self.CN = [Date]()
        
        if let CNList = json["CN"].arrayObject {
            for item in CNList {
                var splits = (item as! String).components(separatedBy: ":")
                
                if let hour = Int.init(splits[0]), let minutes = Int.init(splits[1]) {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    let time = formatter.date(from: "\(hour):\(minutes)")!
                    
                    let hourPart = Int(NSCalendar.current.component(.hour, from: time))
                    let minutePart = Int(NSCalendar.current.component(.minute, from: time))
                    
                    self.CN.append(time)
                }
            }
        }
    }
    
    public func downLoadImage() -> Promise<Void> {
        // Points to the root reference
        return Promise { fulfill, reject in
            let storageRef = Storage.storage().reference()
            let imagesRef = storageRef.child("images")
            let spaceRef = imagesRef.child(self.imagePath)
            
            DispatchQueue.global(qos: .background).async {
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                spaceRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                    if let error = error {
                        LoggerManager.instance.error("Download error \(self.imagePath): \(error)")
                        reject(error)
                    } else {
                        LoggerManager.instance.debug("Download \(self.imagePath) success")
                        
                        if let data = data {
                            _ = FileUtility.save(data: data, pathComponent: "", fileName: self.imagePath)
                        }
                        
                        fulfill()
                    }
                }
            }
        }
    }
    
    
}
