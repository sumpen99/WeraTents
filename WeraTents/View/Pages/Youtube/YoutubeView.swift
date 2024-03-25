//
//  YoutubeContentView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-24.
//

import SwiftUI
import YouTubePlayerKit

struct YoutubeView:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @StateObject var youTubePlayer: YouTubePlayer
    @State var helper:CatalogeHelper = CatalogeHelper()
    @Namespace var namespace
    @State var filteredCataloge:[CatalogeBrand] = []
    @State var videoUrls:[String] = []
    @State var selectedVideoUrl:String?
    
    init(){
        self._youTubePlayer =
        StateObject(wrappedValue: YouTubePlayer(configuration:.init(allowsPictureInPictureMediaPlayback:true,
                                                                    showControls:true,
                                                                    showFullscreenButton: false)))
    }
    
    var body: some View {
        background
        .ignoresSafeArea(.all)
        .toolbar(.hidden)
        .safeAreaInset(edge: .top){
            mainContent
        }
        .ignoresSafeArea(edges:[.bottom])
        .onChange(of: self.selectedVideoUrl,initial: true){ (_ , videoUrl) in
            guard let videoUrl = videoUrl else{
                return self.youTubePlayer.stop()
            }
            self.youTubePlayer.mute()
            self.youTubePlayer.cue(source: .url(videoUrl))
        }
     
    }
}

//MARK: - MAIN CONTENT
extension YoutubeView{
   
    var background:some View{
        ZStack{
            appBackgroundGradient
            catalogeContent
        }
    }
    
    var mainContent:some View{
        VStack{
            BaseTopBar(label: "Filmer",onNavigateBackAction: navigateBack)
            videoContent
        }
    }
}

//MARK: - CATALOGE CONTENT
extension YoutubeView{
    var catalogeContent:some View{
        GeometryReader{ reader in
            VStack{
                SplitLine(color:Color.lightGold)
                ScrollView(.horizontal){
                    HStack(spacing: V_SPACING_REG){
                        catalogeButtons(reader.size.width)
                    }
                }
            }
            .padding(.bottom)
        }
        .frame(height: 100.0)
        .vBottom()
        .task{
            firestoreViewModel.catalogeByFilter(on: .YOUTUBE){ labels in
                filteredCataloge = labels
                if let first = labels.first{
                    helper.selectedBrand = first.brand
                    setVideoUrlsBy(first)
                }
            }
        }
        
    }
    
    func catalogeButtons(_ maxWidth:CGFloat)-> some View{
        ForEach(filteredCataloge,id:\.self){ item in
            CatalogeButton(catalogeDb:$helper.selectedBrand,
                           buttonText: item.brand,
                           frameWidth: maxWidth,
                           disabledUnSelect:true,
                           action:{
                self.selectedVideoUrl = nil
                if helper.selectedBrand != nil{
                    setVideoUrlsBy(item)
                }
            })
         }
        
     }
    
    func setVideoUrlsBy(_ catalogeBrand:CatalogeBrand){
        videoUrls = firestoreViewModel.videoItemsBy(catalogeBrand)
        if let first = videoUrls.first{
            self.selectedVideoUrl = first
        }
    }
}

//MARK: - VIDEO CONTENT
extension YoutubeView{
    @ViewBuilder
    var videoContent: some View {
        ScrollView {
            LazyVStack(spacing: V_GRID_SPACING, pinnedViews: [.sectionHeaders]){
                Section {
                    ForEach(videoUrls,id:\.self) { videoUrl in
                        previewView(videoUrl)
                        .padding(.vertical)
                    }
                } header: {
                    playerViewView
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .vTop()
    }
}

//MARK: - PLAYERVIEW
extension YoutubeView{
    
    var playerViewView:some View{
        playerView
        .frame(height: 220)
        .shadow(
            color: .black.opacity(0.1),
            radius: 46,
            x: 0,
            y: 15
        )
    }
    
    var playerView: some View {
            YouTubePlayerView(self.youTubePlayer) { state in
                switch state {
                case .idle:
                    ProgressView()
                case .ready:
                    EmptyView()
                case .error:
                    Label(
                        "An error occurred.",
                        systemImage: "xmark.circle.fill"
                    )
                    .foregroundStyle(.red)
                }
            }
        }
}

//MARK: PREVIEWVIEW
extension YoutubeView{
    func previewView(_ videoUrl:String) -> some View{
        Button(action: { self.selectedVideoUrl = videoUrl },
               label: {
            YouTubePlayerView(.init(source: .url(videoUrl)))
                .disabled(true)
                .frame(height: 150)
                .padding(.horizontal)
        })
    }
}

//MARK: - Functions
extension YoutubeView{
    func navigateBack(){
        self.navigationViewModel.popPath()
    }
    
    
}
