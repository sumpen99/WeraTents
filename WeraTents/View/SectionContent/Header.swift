//
//  Header.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-08.
//

import SwiftUI

struct HeaderContent<Content:View>:View {
    let content:Content
    var body: some View {
        ZStack{
            content
        }
        .padding()
        .background{
            Color.lightGold.opacity(0.2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 5.0))
    }
}
