//
//  Methods.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-20.
//
import SwiftUI
func debugLog(object: Any, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line){
  #if DEBUG
    let className = (fileName as NSString).lastPathComponent
    print("<\(className)> \(functionName) [#\(lineNumber)]| \(object)\n")
  #endif
}
