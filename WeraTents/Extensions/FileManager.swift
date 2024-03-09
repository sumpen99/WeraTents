//
//  FileManager.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-09.
//

import SwiftUI

extension FileManager{
    func temporaryFileURL(fileName: String = UUID().uuidString,ext: String = "usdz") -> URL? {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(fileName + ext)
    }
}
