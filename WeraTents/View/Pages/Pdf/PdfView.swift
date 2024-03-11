//
//  PdfView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-10.
//

import SwiftUI
import PDFKit

struct PdfView:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @StateObject private var pdfViewCoordinator: PdfViewCoordinator
    let pdfResourcesItem:PdfResourcesItem
    
    init(pdfResourcesItem:PdfResourcesItem) {
        self._pdfViewCoordinator = StateObject(wrappedValue: PdfViewCoordinator())
        self.pdfResourcesItem = pdfResourcesItem
    }
    
    var body: some View {
        background
        .toolbar(.hidden)
        .ignoresSafeArea(.all)
        .safeAreaInset(edge: .top){
            mainContent
        }
        .task {
            if let pdfResourceItem = pdfResourcesItem.listOfPdfItems.first{
                firestoreViewModel.loadTentPdfData(pdfResourceItem.pdfId){ [weak pdfViewCoordinator] url in
                    guard let pdfViewCoordinator = pdfViewCoordinator,
                          let url = url else { return }
                    pdfViewCoordinator.setNewDocumentFrom(url: url)
                }
            }
        }
        
    }
}

//MARK: - MAIN CONTENT
extension PdfView{
    
    var background:some View{
        Color.background
    }
    
    var mainContent:some View{
        VStack{
            BaseTopBar(label: "Instruktionsmanualer", onNavigateBackAction: navigateBack)
            splitLine(color: Color.white).hCenter().padding(.top,5)
            PdfViewContainer(pdfViewCoordinator: pdfViewCoordinator)
        }
        .padding([.top,.horizontal])
    }
}

//MARK: - Functions
extension PdfView{
    func navigateBack(){
        self.pdfViewCoordinator.destroy()
        self.navigationViewModel.popPath()
    }
}
