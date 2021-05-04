//
//  Logger.swift
//  ScanCard
//
//  Created by admin on 20/04/2021.
//

import Foundation

enum Logger {
    // Copy of Truc-san
    public static func log(_ item: Any) {
        #if DEBUG
        print(item)
        #endif
    }
}
