//
//  BaseTopbar.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-11.
//

import SwiftUI

struct BaseTopBar:View {
    let label:String
    var addedSpacer:Bool = true
    let onNavigateBackAction:() -> Void
    
    var body: some View {
        VStack{
            if addedSpacer{ addedSpacerTopbar }
            else{ regularTopBar }
            SplitLine()
        }
        .padding(.top)
   }
}

//MARK: - TYPE OF TOP-BARS
extension BaseTopBar{
    var addedSpacerTopbar:some View{
        HStack{
            BackButtonAction(action: onNavigateBackAction).hLeading()
            Text(label)
            .font(.headline)
            .hCenter()
            .bold()
            .foregroundStyle(Color.white)
            Spacer().hLeading()
        }
    }
    
    var regularTopBar:some View{
        HStack{
            BackButtonAction(action: onNavigateBackAction)
            Text(label)
            .font(.headline)
            .hCenter()
            .bold()
            .foregroundStyle(Color.white)
        }
    }
}
