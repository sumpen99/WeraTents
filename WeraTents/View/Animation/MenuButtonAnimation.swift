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
    var scaleAmount = 1.0
    var menuBarWidth:CGFloat = 0.0
    var paddingHorizontal:CGFloat = 0.0
}

struct MenuButtonAnimation:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @State var helper:MenuHelper = MenuHelper()
    @Binding var openMenuSwitch:Bool
     
    @ViewBuilder
    var body: some View {
        content
    }
    
    var content:some View{
        GeometryReader{ reader in
            ZStack{
                RoundedRectangle(cornerRadius: CORNER_RADIUS_MENU)
                .fill(Color.materialDark)
                buttonContainer
            }
            .onChange(of: reader.size.width,initial: true){ oldSize,newSize in
                helper.menuBarWidth = newSize * 0.85
                helper.paddingHorizontal = helper.menuBarWidth * 0.15
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
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    var buttonContainer:some View{
        HStack(spacing: 0){
            if !openMenuSwitch{
                HStack(spacing:0){
                    startARButton
                    textLabel
                    SplitLine(direction: .VERTICAL,color: Color.white.opacity(0.3),thickness: 2.0)
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
    var textLabel: some View{
        Text("Starta ny AR-upplevelse!")
        .foregroundStyle(Color.white)
        .bold()
        .font(.headline)
        .opacity(openMenuSwitch ? 0 : helper.pressedSection == .TEXT_CENTER ? 0.5 : 1.0)
        .hCenter()
     }
    
    var startARButton: some View{
        Image(systemName: "camera.metering.center.weighted")
        .font(.title3)
        .foregroundStyle(Color.white)
        .frame(width: ICON_WIDTH)
        .opacity(openMenuSwitch ? 0 : helper.pressedSection == .ICON_LEFT ? 0.5 : 1.0)
    }
    
    var expandMenuButton: some View{
        Image(systemName: openMenuSwitch ? "camera.metering.center.weighted" : "chevron.up")
        .font(.title3)
        .foregroundStyle(Color.white)
        .frame(width: ICON_WIDTH)
        .opacity(openMenuSwitch ? 0 : helper.pressedSection == .ICON_RIGHT ? 0.5 : 1.0)
    }
}

//MARK: - FUNCTIONS
extension MenuButtonAnimation{
    func executeAction(){
        switch helper.pressedSection {
        case .ICON_LEFT:
            fallthrough
        case .TEXT_CENTER:
            navigate()
        case .ICON_RIGHT:
            toggleMenu()
        case nil: break
        }
        resetPressedState()
    }
    
    func navigate(){
        if openMenuSwitch{
            toggleMenu()
        }
        else{
            navigationViewModel.switchPathToRoute(ModelRoute.ROUTE_AR)
        }
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
