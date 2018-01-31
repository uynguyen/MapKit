//
//  ChurchListDAO.swift
//  iTrust
//
//  Created by Uy Nguyen Long on 1/31/18.
//  Copyright © 2018 Uy Nguyen Long. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON

class ChurchListDAO: RootDAO {
    override init() {
        super.init()
        self.kRootNode = FirebaseRootNode.RootChurchList.rawValue
    }
    
    func getChurchList() -> Promise<Array<JSON>> {
        return Promise { fulfill, reject in
            self.accessRootDatabase()
                .then { db -> Void in
                    let json = JSON.init(db.value as Any)
                    let result = json.array
                    fulfill(result!)
                }.catch { (error) in
                    LoggerManager.instance.error("Error \(error)")
                    reject(error)
            }
        }
    }
}
