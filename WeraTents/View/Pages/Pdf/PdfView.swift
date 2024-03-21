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
                firestoreViewModel.updateLoadingStateWith(state: .PDF_DOCUMENT, value: true)
                firestoreViewModel.loadTentPdfData(pdfResourceItem.pdfId){ [weak pdfViewCoordinator, weak firestoreViewModel] url in
                    if let pdfViewCoordinator = pdfViewCoordinator,
                       let url = url{
                        pdfViewCoordinator.setNewDocumentFrom(url: url)
                    }
                    firestoreViewModel?.updateLoadingStateWith(state: .PDF_DOCUMENT, value: false)
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
            BaseTopBar(label: "Manual",onNavigateBackAction: navigateBack)
            pdfContainer
            .padding(.horizontal)
        }
    }
    
    var pdfContainer:some View{
        PdfViewContainer(pdfViewCoordinator: pdfViewCoordinator)
        .overlay{
            if firestoreViewModel.loadingState(.PDF_DOCUMENT){
                SpinnerAnimation()
            }
        }
    }
}

//MARK: - Functions
extension PdfView{
    func navigateBack(){
        self.pdfViewCoordinator.destroy()
        self.navigationViewModel.popPath()
    }
}
