//
//  FirestoreDataButton.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-23.
//

import SwiftUI

struct DataFile:Comparable{
    
    
    let downloadAs:DownloadData
    let folder:TempFolder
    let name:String?
    let ext:String
    
    static func < (lhs: DataFile, rhs: DataFile) -> Bool {
        if let lhsName = lhs.name,
           let rhsName = rhs.name{
            return lhsName < rhsName
        }
        return false
    }
    
    static func == (lhs: DataFile, rhs: DataFile) -> Bool {
        return lhs.downloadAs == rhs.downloadAs &&
            lhs.folder == rhs.folder &&
            lhs.name == rhs.name &&
            lhs.ext == rhs.ext
    }
}

struct GroupedDownloader:Equatable{
    var file:DataFile
    var status:DataState
    var resourceUrl:URL?
}

enum DataState:CaseIterable{
    case INITIAL
    case DOWNLOAD
    case HAS_DATA
    case LOADING
    case INVALID_FILE_NAME
    case ERROR
}

struct FirestoreDataButton:View {
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    let file:DataFile
    let imageName:String
    let imageColor:Color
    @Binding var groupedDownloadedFile:GroupedDownloader?
    var action:((String?,URL?) -> Void)? = nil
    @State var currentState:DataState = .INITIAL
    @State var resourceUrl:URL?
    
    var body: some View {
        content
        .onChange(of: groupedDownloadedFile,initial: false){ oldValue,newValue in
            updateIfItAffectsMe(newValue)
        }
        .task{
            guard let fileName = verifyFileName() else { return }
            if !fileExistsLocally(fileName: fileName){
                changeStatusTo(.DOWNLOAD)
            }
        }
     }
}

//MARK: - CONTENT
extension FirestoreDataButton{
   
    var content:some View{
        Button(action: executeAction, label: {
            contentImage
            .frame(width:50.0)
        })
        .disabled(disabledButton())
        
    }
    @ViewBuilder
    var contentImage:some View{
        switch currentState{
        case .INITIAL:
            baseImageWithName("square.and.arrow.down")
            .foregroundStyle(Color.clear)
        case .DOWNLOAD:
            baseImageWithName("square.and.arrow.down")
            .foregroundStyle(Color.blue)
        case .HAS_DATA:
            baseImageWithName(imageName)
            .foregroundStyle(imageColor)
        case .INVALID_FILE_NAME:
            baseImageWithName("exclamationmark.triangle")
            .foregroundStyle(Color.yellow)
        case .LOADING:
            ProgressView()
        case .ERROR:
            baseImageWithName("xmark.circle")
            .foregroundStyle(Color.red)
        }
    }
    
    func baseImageWithName(_ name:String) -> some View{
        Image(systemName: name)
        .font(.title3)
        .bold()
        .vCenter()
    }
}

//MARK: - FUNCTIONS
extension FirestoreDataButton{
    
    
    func disabledButton() -> Bool{
        return (currentState == .HAS_DATA || currentState == .DOWNLOAD) ? false : true
    }
    
    func executeAction(){
        switch currentState{
        case .DOWNLOAD:
            loadData()
        case .HAS_DATA:
            action?(file.name,resourceUrl)
        default:break
        }
    }
    
    func loadData(){
        guard let fileName = verifyFileName() else{ return }
        if fileExistsLocally(fileName: fileName){ return }
        changeStatusTo(.LOADING)
        sendSignalToGroup()
        firestoreViewModel.downloadDataFromStorage(fileName,
                                                   data: file.downloadAs){ url in
            if let url = url{
                resourceUrl = url
                changeStatusTo(.HAS_DATA)
            }
            else{
                changeStatusTo(.ERROR)
            }
            sendSignalToGroup()
        }
        
    }
    
    func fileExistsLocally(fileName:String) -> Bool{
        if let url = ServiceManager.fileExistInside(folder: file.folder,
                                          fileName: fileName,
                                          ext: file.ext){
            resourceUrl = url
            changeStatusTo(.HAS_DATA)
            return true
        }
        else{
            return false
        }
    }
    
    func updateIfItAffectsMe(_ groupedDownloader:GroupedDownloader?){
        if let groupedDownloader = groupedDownloader{
            if groupedDownloader.file == file{
                resourceUrl = groupedDownloader.resourceUrl
                changeStatusTo(groupedDownloader.status)
            }
           
        }
    }
    
    func verifyFileName() -> String?{
        guard let fileName = file.name else{
            changeStatusTo(.INVALID_FILE_NAME)
            return nil
        }
        return fileName
    }
    
    func sendSignalToGroup(){
        groupedDownloadedFile = GroupedDownloader(file: file,
                                                  status: currentState,
                                                  resourceUrl: resourceUrl)
    }
    
    func changeStatusTo(_ newState:DataState){
        withAnimation{
            currentState = newState
        }
    }
}

