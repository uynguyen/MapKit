//
//  RootDAO.swift
//  iTrust
//
//  Created by Uy Nguyen Long on 1/31/18.
//  Copyright © 2018 Uy Nguyen Long. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON
import Firebase
import Parse

enum FirebaseRootNode: String {
    case RootChurchList = "ChurchList"
}

class RootDAO  {
    
    var kRootNode = ""
    var kSecondaryNode = ""
    
    fileprivate let firebaseManager = FirebaseManager()
    
    func accessRootDatabase() -> Promise<DataSnapshot> {
        return firstly {
            self.firebaseManager.readDatabase(rootKey: self.kRootNode)
            }.then { db -> Promise<DataSnapshot> in
                return Promise { fulfill, reject in
                    fulfill(db)
                }
            }.catch { (error) in
                LoggerManager.instance.error("Error \(error)")
        }
    }
}
