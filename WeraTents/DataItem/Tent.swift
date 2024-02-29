//
//  Tent.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-29.
//

import SwiftUI

protocol CarouselItem:Identifiable{
    var id:Int { get }
    var img:Image { get }
    var title:String { get }
}

struct TentDimensions{
    let width:Float
    let height:Float
    let depth:Float
}

struct TentItem:CarouselItem{
    var id:Int
    var identifier: String
    var title:String
    var img:Image
}

struct TentMeta{
    var title:String = ""
    var dimensions:TentDimensions?
    
    mutating func setDimension(_ dimensions:TentDimensions?){
        self.dimensions = dimensions
    }
}
