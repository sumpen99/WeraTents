//
//  UrlButton.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

struct UrlButton:View {
    @Environment(\.openURL) var openURL
    let label:String
    let toVisit:String
    var body: some View {
        Button(action: {
            if let url = URL(string: toVisit){
                openURL(url)
            }
       }, label: {
            Text(label)
            .font(.body)
            .frame(maxWidth: .infinity)
        })
        .buttonStyle(.borderedProminent)
    }
}
