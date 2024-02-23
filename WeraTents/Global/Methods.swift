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

func shortId(length: Int = 4) -> String {
    var result = ""
    let base62chars:[Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    let maxBase : UInt32 = 62
    let minBase : UInt16 = 32

    for _ in 0..<length {
        let random = Int(arc4random_uniform(UInt32(min(minBase, UInt16(maxBase)))))
        result.append(base62chars[random])
    }
    return result
}
