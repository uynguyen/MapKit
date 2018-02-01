//
//  ThreadManager.swift
//  iTrust
//
//  Created by Uy Nguyen Long on 2/1/18.
//  Copyright © 2018 Uy Nguyen Long. All rights reserved.
//

import Foundation
class ThreadManager : NSObject {
    
    static let instance = ThreadManager()
    
    private override init () {
        
    }
    
    func dispatchToMainQueue(fun: @escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.dispatchToMainQueue(fun: fun)
            }
            return
        }
        fun()
    }
}
