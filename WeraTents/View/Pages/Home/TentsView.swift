//
//  TentsView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-13.
//

import SwiftUI

struct TentsHelper{
    var selectedBrand:String?
    var selectedModel:String?
}

struct TentsView:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @State var helper:TentsHelper = TentsHelper()
    @Namespace var namespace
    var body: some View {
        background
        .toolbar(.hidden)
        .ignoresSafeArea(.all)
        .safeAreaInset(edge: .top){
            mainContent
        }
        .task {
            helper.selectedBrand = firestoreViewModel.firstBrand
        }
    }
}
    
//MARK: - TOPCONTAINER
extension TentsView{
    var background:some View{
        Color.background
    }
    
    var mainContent:some View{
        VStack{
            BaseTopBar(label: "Kollektion", onNavigateBackAction: navigateBack)
            SplitLine(color:Color.white).hCenter().padding(.top,5)
            brandHeaderList
            modelHeaderList
            cardByModelId
        }
        .padding([.top,.horizontal])
    }
    
}

//MARK: -- BRAND HEADER LIST
extension TentsView{
    var brandHeaderList:some View{
        ScrollView(.horizontal){
            LazyHStack(alignment: .center, spacing: 20, pinnedViews: [.sectionHeaders]){
                ForEach(firestoreViewModel.brandAsset.keys, id: \.self) { label in
                    SelectedHeader(namespace: namespace,
                                   namespaceName: "CURRENT_SELECTED_BRAND",
                                   label: label,
                                   thickness: 5.0,
                                   bindingLabel: $helper.selectedBrand)
               }
            }
            .padding()
        }
        .frame(height:MENU_HEIGHT_HEADER)
        .scrollIndicators(.never)
        .onChange(of: helper.selectedBrand, initial: true){ oldValue,newValue in
            helper.selectedModel = firestoreViewModel.initializeFirstModelOfBrand(newValue)
        }
     }
    
}

//MARK: -- MODEL HEADER LIST
extension TentsView{
   
    var modelHeaderList:some View{
        ScrollView(.horizontal){
            LazyHStack(alignment: .center, spacing: 20, pinnedViews: [.sectionHeaders]){
                ForEach(firestoreViewModel.secureModelList(helper.selectedBrand), id: \.self) { label in
                    SelectedHeader(namespace: namespace,
                                   namespaceName: "CURRENT_SELECTED_MODEL",
                                   label: label,
                                   thickness: 5.0,
                                   bindingLabel: $helper.selectedModel,
                                   selectedAnimation:.UNDERLINE)
              }
            }
            .padding()
        }
        .frame(height:MENU_HEIGHT_HEADER)
        .scrollIndicators(.never)
        .padding(.top)
    }
  
}

//MARK: -- CARD
extension TentsView{
   
    @ViewBuilder
    var cardByModelId: some View{
        if let tent = firestoreViewModel.secureTentItem(brand: helper.selectedBrand,
                                                        modelId: helper.selectedModel){
            ScrollView{
                VStack{
                    ZStack {
                        tent.img
                        .resizable()
                        .scaledToFit()
                    }
                    Text(tent.shortDescription).hLeading().foregroundStyle(Color.white).vTop()
                }
            }
            .padding(.top)
        }
    }
    
}

//MARK: - FUNCTIONS
extension TentsView{
    func navigateBack(){
        navigationViewModel.popPath()
    }
}
