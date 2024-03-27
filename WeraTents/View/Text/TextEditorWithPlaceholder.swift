//
//  TextEditorWithPlaceholder.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-27.
//

import SwiftUI

struct TextEditorWithPlaceholder: View {
    @Binding var text: String
    let placeholderText:String
    
    var body: some View {
        content
    }
}

//MARK: - CONTENT
extension TextEditorWithPlaceholder{
    
    var content:some View{
        ZStack(alignment: .leading) {
            Color(uiColor: .tertiaryLabel).opacity(0.2)
            if text.isEmpty {
                placeholderTextContent
            }
            textEditorContent
        }
        .clipShape(RoundedRectangle(cornerRadius: 5.0))
    }
    
    var textEditorContent:some View{
        VStack {
            TextEditor(text: $text)
                .vTop()
                .opacity(text.isEmpty ? 0.85 : 1)
                .font(.callout)
                .scrollContentBackground(.hidden)
            Spacer()
        }
    }
    
    var placeholderTextContent:some View{
        VStack {
             Text(placeholderText)
                 .padding(.top, 10)
                 .padding(.leading, 6)
                 .opacity(0.6)
                 .font(.callout)
             Spacer()
         }
    }
    
}
