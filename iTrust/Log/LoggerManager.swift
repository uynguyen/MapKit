//
//  LoggerManager.swift
//  iTrust
//
//  Created by Uy Nguyen Long on 1/31/18.
//  Copyright © 2018 Uy Nguyen Long. All rights reserved.
//

import Foundation
import SwiftyBeaver

class LoggerManager : NSObject {
    static let instance = LoggerManager()
    static let globalLogsFileName = "HHHLord.txt"
    
    fileprivate let logger = SwiftyBeaver.self
    
    private override init () {
        let console = ConsoleDestination()  // log to Xcode Console
        console.format = "$DHH:mm:ss$d $N.$F():$l $L: $M"
        console.minLevel = .verbose
        self.logger.addDestination(console)
    }
    
    func redirectLogToDocuments() {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let pathForLog = documentsDirectory.appending("/\(LoggerManager.globalLogsFileName)")
        freopen(pathForLog.cString(using: String.Encoding.ascii)!, "a+", stderr)
    }
    
    func debug(_ mess: String) {
        self.logger.debug(mess)
    }
    
    func error(_ mess: String) {
        self.logger.error(mess)
    }
}
