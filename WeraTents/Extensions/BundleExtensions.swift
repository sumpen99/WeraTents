//
//  BundleExtensions.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-04.
//

import SwiftUI
extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T? {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            debugLog(object: "Failed to locate \(file) in bundle.")
            return nil
        }

        guard let data = try? Data(contentsOf: url) else {
            debugLog(object: "Failed to load \(file) from bundle.")
            return nil
        }
     
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            debugLog(object: "Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            debugLog(object: "Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            debugLog(object: "Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            debugLog(object: "Failed to decode \(file) from bundle because it appears to be invalid JSON")
        } catch {
            debugLog(object: "Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
        return nil
    }
}
