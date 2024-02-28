//
//  CapturedImages.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

struct CapturedImages:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @StateObject var coreDataViewModel:CoreDataViewModel
   
    init() {
        self._coreDataViewModel = StateObject(wrappedValue: CoreDataViewModel())
    }
    
    var body: some View {
        mainContent
        .toolbar(.hidden)
        .ignoresSafeArea()
        .safeAreaInset(edge: .top){
            VStack{
                topButtons
                itemsLoadedPage
                    .onAppear{
                        coreDataViewModel.setChildViewDimension(CHILD_VIEW_HEIGHT)
                        coreDataViewModel.requestInitialSetOfItems()
                    }
                    .onDisappear{
                        coreDataViewModel.resetPageCounter()
                    }
            }
         }
    }
}

//MARK: - MAIN CONTENT
extension CapturedImages{
    var mainContent:some View{
        ZStack{
            Color.red
            /*itemsLoadedPage
            .onAppear{
                coreDataViewModel.setChildViewDimension(CHILD_VIEW_HEIGHT)
                coreDataViewModel.requestInitialSetOfItems()
            }
            .onDisappear{
                coreDataViewModel.resetPageCounter()
            }*/
        }
        .vCenter()
        .hCenter()
        
    }
}

//MARK: - COREDATA-LIST
extension CapturedImages{
    
    var itemsLoadedPage:some View{
        VStack(spacing:V_SPACING_REG){
            savedScreenshotList
        }
        .padding([.leading,.trailing,.top])
    }
    
    var savedScreenshotList:some View{
        ScrollViewCoreData(coreDataViewModel:coreDataViewModel){ screenShot in
            screenShotCard(screenShot as? ScreenshotModel)
        }
        .background{
            Color.white
        }
    }
    
    @ViewBuilder
    func screenShotCard(_ item:ScreenshotModel?) -> some View{
#if targetEnvironment(simulator)
        VStack{
            Text(item?.name ?? "No name")
            Image("weratent-logo")
            .resizable()
        }
#else
        if let item = item,
           let image = item.image,
           let data = image.data,
           let uiImage = UIImage(data: data){
            VStack{
                Text(item.name ?? "No name")
                Image(uiImage: data)
                .resizable()
            }
        }
#endif
     }
     
}

//MARK: - BUTTONS
extension CapturedImages{
     
    var topButtons:some View{
        HStack{
            BackButtonAction(action: navigateBack)
        }
        .padding()
    }
}

//MARK: - FUNCTIONS
extension CapturedImages{
    func navigateBack(){
        navigationViewModel.popPath()
    }
    
    func loadImagesFromCoreData(){
        
    }
}
