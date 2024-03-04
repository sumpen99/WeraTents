//
//  OperationResult.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-23.
//

import SwiftUI

enum PresentedResult:String{
    case OK = "OK"
}

enum PresentedError: Error {
    case FAILED_TO_DOWNLOAD_IMAGE(message:String = "Failed to download image")
    case FAILED_TO_DOWNLOAD_MODEL(message:String = "Failed to download usdz model")
    case OPTIONAL(message:String)
}

enum ErrorLevel{
    case CRITICAL
    case OPTIONAL
}

struct OperationResult{
    var hasOptionalError:Bool = false
    var hasCriticalError:Bool = false
    var errors:[Error] = []
    var presentedSucces:PresentedResult = .OK
        
    init(){ }
    
    init(error:Error){
        add(error)
    }
    
    mutating func add(_ err:Error?,isOptional:Bool = false,optionalText:String = ""){
        if let err = err{
            if isOptional{
                hasOptionalError = true
                let message = err.localizedDescription + "\n\(optionalText)"
                let op = PresentedError.OPTIONAL(message: message)
                errors.append(op)
                return
            }
            else{
                hasCriticalError = true
                errors.append(err)
            }
        }
    }
    
    mutating func addAll(_ listOfErrors:[Error]){
        if errors.isEmpty{ return }
        hasCriticalError = true
        errors.append(contentsOf: listOfErrors)
    }
    
    var isSuccess:Bool{ errors.isEmpty }
    
    var operationFailed:Bool{
        return hasCriticalError
    }
    
    var operationHasMessage:Bool{
        hasCriticalError || hasOptionalError
    }
    
    var message:String{
        if errors.isEmpty { return presentedSucces.rawValue}
        return presentedErrorDescription()
    }
    
    func presentedErrorDescription() -> String{
        var presentedText = ""
        for err in errors{
            presentedText += "\(BULLET)\(err.localizedDescription)\n"
        }
        return presentedText
    }
    
}
