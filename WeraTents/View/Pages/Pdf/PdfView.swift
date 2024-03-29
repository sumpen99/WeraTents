//
//  PdfView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-10.
//

import SwiftUI

struct PdfResourceItem:Hashable{
    let id:String
    let pdfUrl:URL
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
        
    static func == (lhs: PdfResourceItem, rhs: PdfResourceItem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct PdfView:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @State var helper:CatalogeHelper = CatalogeHelper()
    @State var groupedDownloadedFile:GroupedDownloader?
    @Namespace var namespace
    
    var body: some View {
        appBackgroundGradient
        .ignoresSafeArea(.all)
        .toolbar(.hidden)
        .safeAreaInset(edge: .top){
            mainContent
        }
        .ignoresSafeArea(edges:[.bottom])
    }
}

//MARK: - MAIN CONTENT
extension PdfView{
    
    var mainContent:some View{
        VStack{
            BaseTopBar(label: "Manualer",onNavigateBackAction: navigateBack)
            CatalogeSection(helper: $helper)
            scrollContent
        }
    }
     
}

//MARK: - SCROLL CONTENT
extension PdfView{
    @ViewBuilder
    var scrollContent:some View{
        ScrollView{
            VStack{
                BrandSection(namespace: namespace,
                             helper: $helper)
                SplitLine(color: Color.lightGold)
                modelHeaderList
                SplitLine(color: Color.lightGold)
            }
            .padding(.top)
            .vTop()
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal)
        
    }
}

//MARK: -- MODEL HEADER LIST
extension PdfView{
   
    var modelHeaderList:some View{
        SectionFoldableHeavy(header: headerModelText,
                             content: headerModelContent,
                             splitColor: Color.clear,
                             toggleColor:Color.lightGold,
                             onLabelText: "Dölj",
                             offLabelText: "Visa",
                             automaticFold: $helper.selectedCataloge,
                             showContent: true)
        .padding(.top)
    }
    
    var headerModelText:some View{
        Text("Modeller").bold().foregroundStyle(Color.white)
    }
    
    var headerModelContent:some View{
        LazyVStack( spacing: 0, pinnedViews: [.sectionHeaders]){
            ForEach(firestoreViewModel.tentItemsBy(category:helper.selectedCataloge,
                                                  brand:helper.selectedBrand),id:\.self){ tent in
                buttonAsNavigationLink(title: tent.name,
                                       dataFile: DataFile(downloadAs: .PDF,
                                                        folder: .PDF,
                                                        name: tent.instructionPdfIds?.first,
                                                        ext: "pdf"))
            }
        }
        .background{
            Color.section
        }
   }
  
}

//MARK: - NAVIGATIONBUTTON
extension PdfView{
    
    func buttonAsNavigationLink(title:String,dataFile:DataFile) -> some View{
        VStack(spacing:0){
            HStack{
                Label(title, systemImage: "doc")
                .bold()
                .foregroundStyle(Color.white)
                .hLeading()
                .padding(.leading)
                FirestoreDataButton(file: dataFile,
                                    imageName: "chevron.right",
                                    imageColor: Color.white,
                                    groupedDownloadedFile:$groupedDownloadedFile,
                                    action: navigateToPdfContainer)
                .hTrailing()
            }
            .padding(.vertical)
            SplitLine(color:Color.white)
        }
        .hCenter()
        .vCenter()
    }
    
}

//MARK: - Functions
extension PdfView{
    func navigateBack(){
        self.navigationViewModel.popPath()
    }
    
    func navigateToPdfContainer(fileName:String?,fileUrl:URL?){
        if let fileName = fileName,
            let fileUrl = fileUrl{
                navigationViewModel.appendToPathWith(PdfResourceItem(id: fileName,
                                                                      pdfUrl: fileUrl))
        }
        
    }
}
