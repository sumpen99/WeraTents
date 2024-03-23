//
//  BrandSection.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-23.
//

import SwiftUI

struct BrandSection:View {
    let namespace:Namespace.ID
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @Binding var helper:CatalogeHelper
    var body: some View {
        brandHeaderList
    }
}

//MARK: -- BRAND HEADER LIST
extension BrandSection{
    var brandHeaderList:some View{
        SectionFoldableHeavy(header: headerBrandText,
                             content: headerBrandContent,
                             splitColor: Color.clear,
                             toggleColor:Color.lightGold,
                             onLabelText: "Dölj",
                             offLabelText: "Visa",
                             automaticFold: $helper.selectedCataloge,
                             showContent: true)
         .padding(.top)
    }
    
    var headerBrandText:some View{
        Text("Märken").bold().foregroundStyle(Color.white)
    }
    
    var headerBrandContent:some View{
        ScrollviewLabelHeader(namespace: namespace,
                              namespaceName: "CURRENT_SELECTED_BRAND",
                              thickness: 2.0,
                              bindingList: firestoreViewModel.currentBrandsOfCataloge(cataloge:helper.selectedCataloge),
                              selectedAnimation: .UNDERLINE,
                              menuHeight: MENU_HEIGHT_HEADER,
                              bindingLabel: $helper.selectedBrand,
                              unselectedlabelColor: Color.gray)
        .background{
            RoundedRectangle(cornerRadius: 5.0)
            .fill(Color.materialDark)
        }
        .onChange(of: helper.selectedBrand, initial: false){ oldValue,newValue in
            withAnimation{
                helper.selectedModel = nil
            }
        }
        
    }
}
