//
//  YoutubeView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-08.
//

import SwiftUI
import YouTubePlayerKit

struct YoutubeView:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    let videoResourcesItem:VideoResourcesItem
    @State var selectedVideoItem:VideoItem?
    @StateObject var youTubePlayer: YouTubePlayer
    init(videoResourcesItem:VideoResourcesItem){
        self.videoResourcesItem = videoResourcesItem
        self._youTubePlayer = 
        StateObject(wrappedValue: YouTubePlayer(configuration:.init(allowsPictureInPictureMediaPlayback:true,
                                                                    showControls:true,
                                                                    showFullscreenButton: false)))
    }
    
    
    var body: some View {
        background
        .toolbar(.hidden)
        .ignoresSafeArea(.all)
        .safeAreaInset(edge: .top){
            mainContent
        }
        .task {
            if let videoResourcesItem = videoResourcesItem.listOfVideoItems.first{
                self.selectedVideoItem = videoResourcesItem
            }
        }
        .onChange(of: self.selectedVideoItem,initial: true){ (_ , videoItem) in
            guard let videoItem = videoItem else{
                return self.youTubePlayer.stop()
            }
            self.youTubePlayer.mute()
            self.youTubePlayer.cue(source: .url(videoItem.videoUrl))
        }
    }
}


//MARK: - MAIN CONTENT
extension YoutubeView{
    
    var background:some View{
        Color.background
    }
    
    var mainContent:some View{
        VStack{
            BaseTopBar(label: "Instruktionsfilmer", onNavigateBackAction: navigateBack)
            videoContent.vTop()
        }
        .padding([.top,.horizontal])
    }
    
    var videoContent: some View {
        ScrollView {
            LazyVStack( spacing: V_GRID_SPACING, pinnedViews: [.sectionHeaders]){
                Section {
                    ForEach(self.videoResourcesItem.listOfVideoItems) { videoItem in
                        previewView(videoItem)
                        .padding(.vertical)
                    }
                } header: {
                    playerViewView
                }
            }
            .background{
                Color.white
            }
        }
        .padding(.top)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
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
    func previewView(_ videoItem:VideoItem) -> some View{
        Button(action: { self.selectedVideoItem = videoItem },
               label: {
            YouTubePlayerView(.init(source: .url(videoItem.videoUrl)))
                .disabled(true)
                .frame(height: 150)
                .padding(.horizontal)
        })
    }
}

//MARK: - Functions
extension YoutubeView{
    
    func navigateBack(){
        youTubePlayer.stop()
        self.navigationViewModel.popPath()
     }
}
