//
//  PdfViewContainer.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-11.
//

import SwiftUI
import PDFKit
class PdfViewCoordinator: NSObject, PDFViewDelegate,ObservableObject {
    var pdfView:PDFView?
  
    /*func pdfViewWillClick(onLink sender: PDFView, with url: URL){}
    func pdfViewParentViewController() -> UIViewController{}
    func pdfViewPerformFind(_ sender: PDFView){}
    func pdfViewPerformGo(toPage sender: PDFView){}
    func pdfViewOpenPDF(_ sender: PDFView, forRemoteGoToAction action: PDFActionRemoteGoTo){}*/
    
    
    func initializeView(_ pdfView:PDFView){
        pdfView.displayDirection = .vertical
        self.pdfView = pdfView
        pdfView.delegate = self
        pdfView.autoScales = true
   }
    
    func setNewDocumentFrom(url:URL){
        guard let pdfView = pdfView,
              let document = PDFDocument(url: url) else { return }
        if pdfView.window != nil,!pdfView.isFirstResponder {
            DispatchQueue.main.async {
                pdfView.becomeFirstResponder()
                pdfView.document = document
            }
        }
        else{
            pdfView.document = document
        }
    }
    
    func goToNextPage(){
        if let pdfView = pdfView{
            if pdfView.canGoToNextPage{
                pdfView.goToNextPage(nil)
            }
        }
    }
    
    func destroy(){
        self.pdfView?.document = nil
        self.pdfView?.removeFromSuperview()
        self.pdfView = nil
    }
    
}

struct PdfViewContainer: UIViewRepresentable {
    typealias UIViewType = PDFView
    typealias Context = UIViewRepresentableContext<PdfViewContainer>
    typealias Coordinator = PdfViewCoordinator
    let pdfViewCoordinator:PdfViewCoordinator
   
    func makeUIView(context: Context) -> UIViewType {
        let pdfView = PDFView()
        pdfViewCoordinator.initializeView(pdfView)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        //debugLog(object: "update pdf view")
       
    }
    
    static func dismantleUIView(_ pdfView: UIViewType, coordinator: Coordinator) {
         //debugLog(object: "dismantlePdfView")
    }
    
    func makeCoordinator() -> Coordinator {
        return pdfViewCoordinator
    }
}
