//
//  AppLogger.swift
//  Full iOS Example
//
//  Created by Etienne Vautherin on 27/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Foundation
import AnyLogger


#if DEBUG
import XCGLogger

extension XCGLogger {
    func eraseAsAnyLogger() -> AnyLogger {
        AnyLogger(
            debug: { (message) in
                XCGLogger.self.default.logln(.debug, functionName: "", fileName: "", lineNumber: 0, userInfo: [:], closure: { message })
            },
            error: { (message) in
                XCGLogger.self.default.logln(.error, functionName: "", fileName: "", lineNumber: 0, userInfo: [:], closure: { message })
            }
        )
    }
}

struct AppLogger {
    static func logFileURL() throws -> URL? {
        
        let fm = FileManager.default
        guard
            let resultDirURL = fm.urls(for: .documentDirectory, in: .userDomainMask).last
            else { log.debug("No document directory"); return .none }
        
        try { // Create resultDirURL directory when doesn't exist
            guard !fm.fileExists(atPath: resultDirURL.path) else { return }
            
            try fm.createDirectory(at: resultDirURL, withIntermediateDirectories: true, attributes: nil)
        }()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateString = formatter.string(from: Date())
        return resultDirURL
            .appendingPathComponent("AlwaysRespectful-"+dateString)
            .appendingPathExtension("txt")
    }

    
    static func startLogging() {
        do {
            guard let url = try logFileURL() else { return }
            XCGLogger.default.setup(
                level: .debug,
                showLevel: false,
                showFileNames: false,
                showLineNumbers: false,
                writeToFile: url,
                fileLevel: .debug)
            log.debug("Logging to: \(url)")
        } catch {
            log.error(error.localizedDescription)
        }
        
        log = XCGLogger.default.eraseAsAnyLogger()
    }
    
    
    static func flushLog() {
        let identifier = XCGLogger.Constants.fileDestinationIdentifier
        let destination = XCGLogger.default.destination(withIdentifier: identifier)
        guard
            let fileDestination = destination as? FileDestination
            else { return }
        
        log.debug("Flushing \(fileDestination.debugDescription)")
        fileDestination.flush()
    }
}
#else
struct AppLogger {
    static func startLogging() {
    }
    
    
    static func flushLog() {
    }
}
#endif
