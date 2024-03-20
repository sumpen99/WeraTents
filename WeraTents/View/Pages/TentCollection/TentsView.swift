//
//  TentsView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-13.
//

import SwiftUI

struct TentsHelper{
    var selectedCataloge:String?
    var selectedBrand:String?
    var selectedModel:String?
 
    mutating func initFromNavigator(_ navigator:TentsNavigator){
        self.selectedCataloge = navigator.cataloge
        self.selectedBrand = navigator.brand
    }
}

struct TentsNavigator:Identifiable,Hashable{
    let id:String = shortId()
    let cataloge:String
    let brand:String
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
        
    static func == (lhs: TentsNavigator, rhs: TentsNavigator) -> Bool {
        return lhs.id == rhs.id
    }
}

struct TentsView:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @State var helper:TentsHelper = TentsHelper()
    var navigator:TentsNavigator?
    @Namespace var namespace
    
    var body: some View {
        background
        .toolbar(.hidden)
        .ignoresSafeArea()
        .safeAreaInset(edge: .top){
            mainContent
        }
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
            Color.background
            labelImage
        }
        .vCenter()
        .hCenter()
    }
    
    var labelImage:some View{
        GeometryReader{ reader in
            Image("weratent-logo-horn")
             .resizable()
             .scaledToFit()
             .frame(width: reader.min()/3.0,height: reader.min()/3.0)
             .vCenter()
             .hCenter()
        }
    }
    
    var mainContent:some View{
        VStack{
            BaseTopBar(label: "Kollektion", onNavigateBackAction: navigateBack)
            catalogeContent
            scrollContent
            
       }
    }
    
    @ViewBuilder
    var scrollContent:some View{
        if helper.selectedCataloge != nil{
            ScrollView{
                VStack{
                    brandHeaderList
                    modelHeaderList
                    SplitLine(color: Color.lightGold)
                    currentDescriptionText
                    cardByModelId
                }
                .padding(.top)
                .vTop()
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal)
        }
        
    }
    
}

//MARK: - DESCRIPTION TEXT
extension TentsView{
    @ViewBuilder
    var currentDescriptionText:some View{
        if helper.selectedCataloge != nil &&
            helper.selectedBrand == nil &&
            helper.selectedModel == nil{
            if let cataloge = firestoreViewModel.currentCatalogeItem(cataloge:helper.selectedCataloge){
                baseDescriptionText(cataloge.header ?? "")
            }
        }
        else if helper.selectedBrand != nil && helper.selectedModel == nil{
            if let brand = firestoreViewModel.currentBrandItem(cataloge:helper.selectedCataloge,
                                                               brand: helper.selectedBrand){
                baseDescriptionText(brand.header ?? "")
            }
        }
    }
    
    func baseDescriptionText(_ label:String) -> some View{
        Text(label)
        .font(.headline)
        .padding()
        .foregroundStyle(Color.white)
        .background{
               RoundedRectangle(cornerRadius: 5.0)
                   .fill(Color.white.opacity(0.03))
           }
        .vBottom()
        .hCenter()
        .shadow(color:Color.materialDark,radius: 2.0)
        .padding(.vertical)
        
    }
}

//MARK: - CATALOGE HEADER LIST
extension TentsView{
    var catalogeContent:some View{
        VStack{
            GeometryReader{ reader in
                HStack(spacing: V_SPACING_REG){
                    catalogeButtons(reader.size.width)
                    .hCenter()
                }
            }
            .frame(height: HOME_BRAND_HEIGHT)
            .hCenter()
            SplitLine(color: Color.lightGold)
        }
        .hCenter()
        
    }
    
    func catalogeButtons(_ maxWidth:CGFloat)-> some View{
        ForEach(firestoreViewModel.catalogeList(),id:\.self){ cataloge in
            CatalogeButton(catalogeDb:$helper.selectedCataloge,
                           buttonText: cataloge,
                           frameWidth: maxWidth,
                           action:{
                withAnimation{
                    helper.selectedBrand = nil
                    helper.selectedModel = nil
                }
            })
        }
     }
}

//MARK: -- BRAND HEADER LIST
extension TentsView{
    var brandHeaderList:some View{
        SectionFoldableHeavy(header: headerBrandText,
                             content: headerBrandContent,
                             splitColor: Color.lightGold.opacity(0.2),
                             toggleColor:Color.lightGold,
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
                              bindingList: firestoreViewModel.currentBrandsOfCataloge(cataloge:helper.selectedCataloge),
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
                             toggleColor:Color.lightGold,
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
                              bindingList: firestoreViewModel.currentModelsOfBrand(cataloge:helper.selectedCataloge,brand: helper.selectedBrand),
                             selectedAnimation: .UNDERLINE,
                             menuHeight: MENU_HEIGHT_HEADER,
                             bindingLabel: $helper.selectedModel)
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
            .padding()
                
        }
    }
    
    func cardButton(_ tentItem:Tent) -> some View{
        Button(action: { navigateToTent(tentItem) }, label: {
            Image(systemName: "hand.point.right")
                .font(.title2)
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
                             offLabelText: "Visa")
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
