//
//  Church.swift
//  iTrust
//
//  Created by Uy Nguyen Long on 2/1/18.
//  Copyright © 2018 Uy Nguyen Long. All rights reserved.
//

import UIKit
import SwiftyJSON

class Church: NSObject {
    var id: Int
    var name: String
    var link: String
    var strCN: String
    var CN: Array<Date>
    var image: UIImage?
    var address: String
    
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
    
    
}
