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
        .ignoresSafeArea()
        .safeAreaInset(edge: .top){
            mainContent
        }
    }
}
    
//MARK: - TOPCONTAINER
extension TentsView{
    var background:some View{
        Color.background
        .vCenter()
        .hCenter()
    }
    
    var mainContent:some View{
        VStack{
            BaseTopBar(label: "Kollektion", onNavigateBackAction: navigateBack)
            scrollContent
       }
    }
    
    var scrollContent:some View{
        ScrollView{
            VStack{
                brandHeaderList
                modelHeaderList
                cardByModelId
            }
            .padding(.top)
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal)
    }
    
}

//MARK: -- BRAND HEADER LIST
extension TentsView{
    var brandHeaderList:some View{
        SectionFoldableHeavy(header: headerBrandText,
                             content: headerBrandContent,
                             splitColor: Color.lightGold.opacity(0.2),
                             toggleColor:Color.darkGreen,
                             onLabelText: "Dölj",
                             offLabelText: "Visa",
                             showContent: true)
        .padding(.top)
    }
    
    var headerBrandText:some View{
        Text("Märken").bold().foregroundStyle(Color.white)
    }
    
    var headerBrandContent:some View{
        ScrollviewLabelHeader(namespace: namespace,
                              namespaceName: "CURRENT_SELECTED_BRAND",
                              thickness: 3.0,
                              bindingList: firestoreViewModel.brandAsset.keys.elements,
                              selectedAnimation: .UNDERLINE,
                              menuHeight: MENU_HEIGHT_HEADER,
                              bindingLabel: $helper.selectedBrand)
        .onChange(of: helper.selectedBrand, initial: false){ oldValue,newValue in
            helper.selectedModel = nil
        }
    }
}

//MARK: -- MODEL HEADER LIST
extension TentsView{
   
    var modelHeaderList:some View{
        SectionFoldableHeavy(header: headerModelText,
                             content: headerModelContent,
                             splitColor: Color.lightGold.opacity(0.2),
                             toggleColor:Color.darkGreen,
                             onLabelText: "Dölj",
                             offLabelText: "Visa",
                             showContent: true)
        .padding(.top)
    }
    
    var headerModelText:some View{
        Text("Modeller").bold().foregroundStyle(Color.white)
    }
    
    var headerModelContent:some View{
        ScrollviewLabelHeader(namespace: namespace,
                                         namespaceName: "CURRENT_SELECTED_MODEL",
                                         thickness: 3.0,
                                         bindingList: firestoreViewModel.secureModelList(helper.selectedBrand),
                                         selectedAnimation: .UNDERLINE,
                                         menuHeight: MENU_HEIGHT_HEADER,
                                         bindingLabel: $helper.selectedModel)
    }
  
}

//MARK: -- CARD
extension TentsView{
   
    @ViewBuilder
    var cardByModelId: some View{
        if let tent = firestoreViewModel.secureTentItem(brand: helper.selectedBrand,
                                                        modelId: helper.selectedModel){
            ZStack{
                Color.lightBrown
                VStack(spacing:V_SPACING_REG){
                    cardImage(tent.img)
                    cardDimensionText(tent.dimensions)
                    cardShortDescriptionText(tent.shortDescription)
                    cardPriceText(tent.price)
                    cardButton(tent.index)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
            .shadow(color:Color.lightGold,radius: 2.0,x:0,y:0)
            .padding()
                
        }
    }
    
    func cardButton(_ index:Int) -> some View{
        Button(action: { navigateTo(index) }, label: {
            Image(systemName: "square.split.diagonal.2x2.fill")
                .font(.title3)
                .bold()
        })
        .foregroundStyle(Color.darkGreen)
        .padding([.bottom,.trailing],4.0)
        .hTrailing()
    }
    
    func cardImage(_ img:Image) -> some View{
        img
        .resizable()
        .scaledToFit()
        .vTop()
    }
        
    func cardShortDescriptionText(_ shortDescription:String) -> some View{
        Text(shortDescription)
        .italic()
        .hLeading()
        .padding([.horizontal,.top])
    }
    
    func cardPriceText(_ price:String) -> some View{
        Text(price)
        .font(.title)
        .hLeading()
        .padding([.horizontal,.top])
    }
    
    @ViewBuilder
    func cardDimensionText(_ dimensions:TentItemDimensions?) -> some View{
        if let dimensions = dimensions{
            VStack(spacing: V_SPACING_REG){
                cardFoldableSection(headerText: "Storlek:", contentText: dimensions.sizeDesc)
                cardFoldableSection(headerText: "Monteringshöjd:", contentText: dimensions.heightDesc)
                if let infotext = dimensions.infoText{
                    cardFoldableSection(headerText: "Information:", contentText: infotext)
                }
            }
            .padding(.horizontal)
        }
        
    }
    
    func cardFoldableSection(headerText:String,contentText:String) -> some View{
        SectionFoldableHeavy(header: Text(headerText).bold(),
                             content: Text(contentText).hLeading(),
                             splitColor: Color.lightGold.opacity(0.2),
                             toggleColor:Color.darkGreen,
                             onLabelText: "Dölj",
                             offLabelText: "Visa")
    }
    
}

//MARK: - FUNCTIONS
extension TentsView{
    func navigateBack(){
        navigationViewModel.popPath()
    }
    
    func navigateTo(_ index:Int){
        navigationViewModel.appendToPathWith(firestoreViewModel.tentAssets[index])
    }
}
