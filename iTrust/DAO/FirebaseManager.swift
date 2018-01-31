//
//  FirebaseManager.swift
//  iTrust
//
//  Created by Uy Nguyen Long on 1/31/18.
//  Copyright © 2018 Uy Nguyen Long. All rights reserved.
//

import Foundation
import Firebase
import Parse
import BoltsSwift
import SwiftyJSON
import PromiseKit

let kFirebaseErrorDomain = "FirebaseErrorDomain"

class FirebaseManager {
    fileprivate let ref = Database.database().reference()
    
    init() {
        self.ref.observe(.childChanged, with: { (snapshot) in
            print("Database changed")
        })
    }
    
    func readDatabase(rootKey: String) -> Promise<DataSnapshot> {
        return Promise { fulfill, reject in
            self.ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() {
                    reject(NSError.init(domain: kFirebaseErrorDomain, code: 0, userInfo: nil))
                    return
                }
                let rootTree = snapshot.childSnapshot(forPath: rootKey)
                fulfill(rootTree)
            })
        }
    }
}

