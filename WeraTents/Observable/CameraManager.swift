//
//  CameraManager.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-22.
//

import AVFoundation
import SwiftUI

@MainActor
class CameraManger:ObservableObject{
    @Published var permission:(isAuthorized:Bool,status:AVAuthorizationStatus) = (false,.notDetermined)
    
    private var currentStatus:(Bool,AVAuthorizationStatus) {
        get async {
            var status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
                status = AVCaptureDevice.authorizationStatus(for: .video)
            }
            return (isAuthorized:isAuthorized,status:status)
        }
    }
    
    func setUpCaptureSession() async {
        await permission = currentStatus
    }
    
}
