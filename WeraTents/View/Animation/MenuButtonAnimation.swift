//
//  MenuButton.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-12.
//

import SwiftUI

enum PressedSection:CaseIterable{
    case ICON_LEFT
    case TEXT_CENTER
    case ICON_RIGHT
}

struct MenuHelper{
    var pressedSection:PressedSection?
    var scaleAmount:CGFloat = 1.0
    var menuBarWidth:CGFloat = 0.0
    var paddingHorizontal:CGFloat = 0.0
    var paddingHorizontalOpen:CGFloat = 0.0
}

struct MenuButtonAnimation:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @State var helper:MenuHelper = MenuHelper()
    @Binding var openMenuSwitch:Bool
    let ICON_WIDTH = 50.0
    let ANIMATED_MENU_HEIGHT = 70.0
     
    @ViewBuilder
    var body: some View {
        VStack{
            openButtonList
            content
        }
        .padding()
        .padding(.bottom)
        .vBottom()
        .background{
            if openMenuSwitch{
                LayOverView(closeView: $openMenuSwitch)
            }
        }
    }
    
    var content:some View{
        GeometryReader{ reader in
            ZStack{
                RoundedRectangle(cornerRadius: 5.0)
                .fill(Color.darkerGreen )
                .shadow(color:Color.lightGold,radius: 0.5,y:0.3)
                buttonContainer
            }
            .onChange(of: reader.size.width,initial: true){ oldSize,newSize in
                helper.menuBarWidth = newSize * 0.85
                helper.paddingHorizontal = helper.menuBarWidth * 0.15
                helper.paddingHorizontalOpen = helper.menuBarWidth - ICON_WIDTH
            }
            .gesture(longPressGesture)
            .scaleEffect(helper.scaleAmount)
            .animation(.linear(duration: 0.25),value: helper.scaleAmount)
            .animation(.linear(duration: 0.25),value: openMenuSwitch)
            .frame(width: openMenuSwitch ? ICON_WIDTH : helper.menuBarWidth,
                   height: ANIMATED_MENU_HEIGHT)
            .padding(.leading,helper.paddingHorizontal)
            .padding([.bottom])
            .vBottom()
            .hTrailing()
            .background{
                arButtonOpen
            }
        }
        .frame(height: ANIMATED_MENU_HEIGHT)
    }
    
    @ViewBuilder
    var openButtonList:some View{
        if openMenuSwitch{
            VStack{
                youtubeButton
                pdfButton
            }
            .hTrailing()
            .vBottom()
            .padding([.bottom])
            .padding(.trailing,(ICON_WIDTH-ICON_WIDTH)/2.0)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    @ViewBuilder
    var buttonContainer:some View{
        HStack(spacing: 0){
            if !openMenuSwitch{
                HStack(spacing:0){
                    startARButton
                    textLabel
                    SplitLine(direction: .VERTICAL,color: Color.white,thickness: 1.0)
                }
            }
            expandMenuButton
        }
        
      }
}

//MARK: - GESTURE
extension MenuButtonAnimation{
    var longPressGesture: some Gesture {
        DragGesture(minimumDistance: 0.0)
            .onChanged { gesture in
                if (gesture.location.x < 0 || gesture.location.x > helper.menuBarWidth) ||
                    (gesture.location.y < 0 || gesture.location.y > ANIMATED_MENU_HEIGHT){
                    resetPressedState()
                    return
                }
                else{
                    helper.scaleAmount = 0.95
                }
                 
                let offsetLeft = ICON_WIDTH
                let offsetRight = helper.menuBarWidth - ICON_WIDTH
                
                if gesture.location.x < offsetLeft{
                    helper.pressedSection = .ICON_LEFT
                }
                else if gesture.location.x > offsetRight{
                    helper.pressedSection = .ICON_RIGHT
                }
                else{
                    helper.pressedSection = .TEXT_CENTER
                }
            }
            .onEnded { _ in
                executeAction()
            }
    }
}


//MARK: - BUTTON AND TEXT
extension MenuButtonAnimation{
  
    var pdfButton:some View{
        Button(action: { navigateTo(ModelRoute.ROUTE_PDF) }, label: {
            HStack{
                textLabelBase("Instruktionsmanualer")
                imageBase("book.pages")
            }
        })
        .hTrailing()
    }
    
    var youtubeButton:some View{
        Button(action: { navigateTo(ModelRoute.ROUTE_YOUTUBE) }, label: {
            HStack{
                textLabelBase("Instruktionsfilmer")
                imageBase("play.tv")
            }
        })
        .hTrailing()
    }
    
    
    func imageBase(_ name:String) -> some View{
        Image(systemName: name)
        .font(.title3)
        .bold()
        .foregroundStyle(Color.white)
        .padding()
        .background(Color.darkerGreen)
        .frame(width: ICON_WIDTH,height:ICON_WIDTH)
        .clipShape(Circle())
    }
    
    func textLabelBase(_ text:String) -> some View{
        Text(text)
            .foregroundStyle(openMenuSwitch ? Color.black : Color.white)
        .bold()
        .font(.headline)
    }
    
    var textLabel: some View{
        textLabelBase("Starta ny AR-upplevelse!")
        .opacity(helper.pressedSection == .TEXT_CENTER ? 0.5 : 1.0)
        .hCenter()
     }
    
    @ViewBuilder
    var arButtonOpen: some View{
        if openMenuSwitch{
            Button(action: { navigateTo(ModelRoute.ROUTE_AR)}, label: {
                textLabelBase("AR-upplevelse")
            })
            .hTrailing()
            .padding(.trailing,ICON_WIDTH)
            .padding([.bottom,.trailing])
            .transition(.move(edge: .trailing))
        }
    }
    
    var startARButton: some View{
        Image(systemName: "camera.metering.center.weighted")
        .font(.title)
        .foregroundStyle(Color.white)
        .frame(width: ICON_WIDTH)
        .opacity(helper.pressedSection == .ICON_LEFT ? 0.5 : 1.0)
    }
    
    var expandMenuButton: some View{
        Image(systemName: openMenuSwitch ? "camera.metering.center.weighted" : "chevron.up")
        .font(.title)
        .foregroundStyle(Color.white)
        .frame(width: ICON_WIDTH)
        .opacity(helper.pressedSection == .ICON_RIGHT ? 0.5 : 1.0)
    }
}

//MARK: - FUNCTIONS
extension MenuButtonAnimation{
    func executeAction(){
        switch helper.pressedSection {
        case .ICON_LEFT:
            fallthrough
        case .TEXT_CENTER:
            navigateTo(ModelRoute.ROUTE_AR)
        case .ICON_RIGHT:
            toggleMenu()
        case nil: break
        }
        resetPressedState()
    }
    
    func navigateTo(_ route:ModelRoute){
        if openMenuSwitch{
            toggleMenu()
        }
        navigationViewModel.switchPathToRoute(route)
    }
    
    func toggleMenu(){
        withAnimation{
            openMenuSwitch.toggle()
        }
    }
    
    func resetPressedState(){
        helper.scaleAmount = 1.0
        helper.pressedSection = nil
    }
}
