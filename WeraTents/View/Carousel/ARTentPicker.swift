//
//  ArTentPicker.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-20.
//

import SwiftUI

struct ARTentPicker:View {
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @Binding var isOpen:Bool
    @State var tentItems:[Tent]?
    var body: some View {
        content
        .task {
            firestoreViewModel.everyTentItem(){ tentItems in
                self.tentItems = tentItems
           }
        }
        .animation(.easeIn(duration: 0.25),value: isOpen)
        .transition(.move(edge: .trailing))
    }
}

//MARK: - CONTENT
extension ARTentPicker{
    var content:some View{
        ZStack{
            background
            pickerContent
        }
        .hCenter()
        .vCenter()
    }
    
    var background:some View{
        Color.white.opacity(0.1)
        .ignoresSafeArea()
        .gesture(arPickerTapGesture)
    }
    
    var pickerContent:some View{
        GeometryReader{ reader in
            ZStack{
                Color.white
                ScrollView{
                    LazyVGrid(columns: [GridItem(),GridItem()],
                              spacing: V_GRID_SPACING,
                              pinnedViews: .sectionHeaders){
                        ForEach(tentItems ?? [],id:\.self){ tent in
                            FirestoreImage(iconImageUrl: tent.iconStorageIds?.first)
                            .clipShape(Circle())
                            .padding(5.0)
                            .background(Circle().fill(Color.materialDark))
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .clipShape(RoundedRectangle(cornerRadius: 5.0))
            .frame(width:reader.size.width,height: reader.size.height/2.0)
            .vCenter()
            .hCenter()
            .padding()
        }
        
        
    }
}


//MARK: - GESTURE
extension ARTentPicker{
    var arPickerTapGesture: some Gesture {
        TapGesture()
        .onEnded{
            withAnimation{
                isOpen.toggle()
            }
        }
    }
}
