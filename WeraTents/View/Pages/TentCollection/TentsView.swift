//
//  TentsView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-13.
//

import SwiftUI

struct TentsView:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @State var helper:CatalogeHelper = CatalogeHelper()
    var navigator:CatalogeNavigator?
    @Namespace var namespace
    
    var body: some View {
        background
        .toolbar(.hidden)
        .ignoresSafeArea()
        .safeAreaInset(edge: .top){
            mainContent
        }
        .ignoresSafeArea(edges:[.bottom])
        .task{
            if let navigator = navigator{
                helper.initFromNavigator(navigator)
            }
        }
    }
}


    
//MARK: - TOPCONTAINER
extension TentsView{
    var background:some View{
        ZStack{
            appBackgroundGradient
            labelImage
        }
        .vCenter()
        .hCenter()
    }
    
    @ViewBuilder
    var labelImage:some View{
        if helper.noCurrentSelection{
            GeometryReader{ reader in
                Image("weratent-logo-horn")
                    .resizable()
                    .scaledToFit()
                    .frame(width: reader.min()/3.0,height: reader.min()/3.0)
                    .vCenter()
                    .hCenter()
            }
        }
    }
    
    var mainContent:some View{
        VStack{
            BaseTopBar(label: "Kollektion", onNavigateBackAction: navigateBack)
            CatalogeSection(helper: $helper)
            scrollContent
            
       }
    }
    
}

//MARK: - SCROLL CONTENT
extension TentsView{
    @ViewBuilder
    var scrollContent:some View{
        ScrollView{
            VStack{
                BrandSection(namespace: namespace,
                             helper: $helper)
                SplitLine(color: Color.lightGold)
                modelHeaderList
                SplitLine(color: Color.lightGold)
                cardByModelId
                currentDescriptionText
            }
            .padding(.top)
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal)
        
    }
}

//MARK: -- MODEL HEADER LIST
extension TentsView{
   
    var modelHeaderList:some View{
        SectionFoldableHeavy(header: headerModelText,
                             content: headerModelContent,
                             splitColor: Color.clear,
                             toggleColor:Color.lightGold,
                             onLabelText: "Dölj",
                             offLabelText: "Visa",
                             automaticFold: $helper.selectedBrand,
                             showContent: true)
        .padding(.top)
    }
    
    var headerModelText:some View{
        Text("Modeller").bold().foregroundStyle(Color.white)
    }
    
    var headerModelContent:some View{
        ScrollviewLabelHeader(namespace: namespace,
                             namespaceName: "CURRENT_SELECTED_MODEL",
                             thickness: 2.0,
                              bindingList: firestoreViewModel.currentModelsOfBrand(cataloge:helper.selectedCataloge,brand: helper.selectedBrand),
                             selectedAnimation: .UNDERLINE,
                             menuHeight: MENU_HEIGHT_HEADER,
                              bindingLabel: $helper.selectedModel,
                              unselectedlabelColor: Color.gray)
        .background{
            RoundedRectangle(cornerRadius: 5.0)
                .fill(Color.section)
        }
    }
  
}

//MARK: - DESCRIPTION TEXT
extension TentsView{
    @ViewBuilder
    var currentDescriptionText:some View{
        if helper.onlyCataloge{
            if let cataloge = firestoreViewModel.currentCatalogeItem(cataloge:helper.selectedCataloge){
                baseDescriptionText(cataloge.header ?? "")
            }
        }
        else if helper.catalogeAndBrand{
            if let brand = firestoreViewModel.currentBrandItem(cataloge:helper.selectedCataloge,
                                                               brand: helper.selectedBrand){
                baseDescriptionText(brand.header ?? "")
            }
        }
    }
    
    func baseDescriptionText(_ label:String) -> some View{
        LazyVStack{
            Text(label)
            .font(.headline)
            .padding()
            .foregroundStyle(Color.white)
            .hLeading()
            .background{
                RoundedRectangle(cornerRadius: 5.0)
                .fill(Color.section)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 5.0))
        .shadow(color:Color.darkGreen,radius: 5.0)
        .padding(.horizontal)
        .padding(.top,50.0)
        .padding(.bottom,25.0)
        /*.background(RoundedRectangle(cornerRadius: 5.0).stroke(lineWidth: 2.0).foregroundStyle(Color.lightGold))
        .padding(1.0)
        .padding(.top,50.0)
        .padding(.bottom,25.0)*/
        
     }
}



//MARK: -- CARD
extension TentsView{
   
    @ViewBuilder
    var cardByModelId: some View{
        if let tent = firestoreViewModel.currentTentItem(cataloge:helper.selectedCataloge,
                                               brand: helper.selectedBrand,
                                               modelId: helper.selectedModel){
            ZStack{
                Color.lightBrown
                VStack(spacing:V_SPACING_REG){
                    FirestoreImage(iconImageUrl: tent.iconStorageIds?.first)
                    cardDimensionText(tent.dimensions)
                    cardShortDescriptionText(tent.shortDescription)
                    cardPriceText(tent.price)
                    cardButton(tent)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
            .shadow(color:Color.lightGold,radius: 2.0,x:0,y:0)
            .padding(.vertical)
                
        }
    }
    
    func cardButton(_ tentItem:Tent) -> some View{
        Button(action: { navigateToTent(tentItem) }, label: {
            Image(systemName: "hand.point.right")
                .font(.title)
                .bold()
        })
        .foregroundStyle(Color.lightGold)
        .padding([.bottom,.trailing],4.0)
        .hTrailing()
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
                             toggleColor:Color.lightGold,
                             onLabelText: "Dölj",
                             offLabelText: "Visa",
                             automaticFold: $helper.selectedModel,
                             showContent: false,
                             addedSplitLine: true)
    }
    
}

//MARK: - FUNCTIONS
extension TentsView{
    func navigateBack(){
        navigationViewModel.popPath()
    }
    
    func navigateToTent(_ tent:Tent){
        navigationViewModel.appendToPathWith(tent)
    }
}
