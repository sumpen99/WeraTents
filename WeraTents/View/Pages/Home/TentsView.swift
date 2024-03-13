//
//  TentsView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-13.
//

import SwiftUI

struct TentsHelper{
    var selectedBrand:String?
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
            BaseTopBar(label: "Vår kollektion", onNavigateBackAction: navigateBack)
            SplitLine(color:Color.white).hCenter().padding(.top,5)
            collectionContainer
            brandSection
        }
        .padding([.top,.horizontal])
    }
    
    var collectionContainer:some View{
        ScrollviewLabelHeader(namespace: namespace,
                              thickness: 5.0,
                              bindingLabel: $helper.selectedBrand,
                              bindingList: $firestoreViewModel.brandAssets)
    }
}

//MARK: -- SECTION
extension TentsView{
   
    var brandSection: some View{
        ScrollView{
            LazyVGrid(columns: [GridItem(),GridItem()],
                      spacing: V_GRID_SPACING,
                      pinnedViews: [.sectionHeaders]){
                ForEach(firestoreViewModel.splitAssetsOnBrand(helper.selectedBrand),id:\.self){ tent in
                    ZStack{
                        Color.red
                        Text(tent.name)
                    }
                    .frame(height: 150.0)
                }
        
            }
        }
        
    }
}

//MARK: - FUNCTIONS
extension TentsView{
    func navigateBack(){
        navigationViewModel.popPath()
    }
}
