//
//  PdfContent.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-23.
//

import SwiftUI
import PDFKit

struct PdfContentView:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @StateObject private var pdfViewCoordinator: PdfViewCoordinator
    let pdfResourceItem:PdfResourceItem
    
    init(pdfResourceItem:PdfResourceItem) {
        self._pdfViewCoordinator = StateObject(wrappedValue: PdfViewCoordinator())
        self.pdfResourceItem = pdfResourceItem
    }
    
    var body: some View {
        background
        .toolbar(.hidden)
        .ignoresSafeArea(.all)
        .safeAreaInset(edge: .top){
            mainContent
        }
        .task {
            pdfViewCoordinator.setNewDocumentFrom(url: self.pdfResourceItem.pdfUrl)
        }
        
    }
}

//MARK: - MAIN CONTENT
extension PdfContentView{
    
    var background:some View{
        appBackgroundGradient
    }
    
    var mainContent:some View{
        VStack{
            BaseTopBar(label: "Manual",onNavigateBackAction: navigateBack)
            pdfContainer
            .padding(.horizontal)
        }
    }
    
    var pdfContainer:some View{
        PdfViewContainer(pdfViewCoordinator: pdfViewCoordinator)
    }
}

//MARK: - Functions
extension PdfContentView{
    func navigateBack(){
        self.pdfViewCoordinator.destroy()
        self.navigationViewModel.popPath()
    }
}
