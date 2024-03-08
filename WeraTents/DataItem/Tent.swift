//
//  Tent.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-29.
//

import SwiftUI
// FOR THE LOVE OF GOD DONT REMOVE IMPORT
import FirebaseFirestoreSwift
protocol CarouselItem:Identifiable,Hashable{
    var id:String { get }
    var index:Int { get }
    var img:Image { get }
    var name:String { get }
    var shortDescription:String { get }
}

struct TentDimensions{
    let width:Float
    let height:Float
    let depth:Float
}

struct TentMeta{
    var title:String = ""
    var dimensions:TentDimensions?
    
    mutating func setDimension(_ dimensions:TentDimensions?){
        self.dimensions = dimensions
    }
}

struct TentItem:CarouselItem{
    var id:String
    var index:Int
    var name:String
    var img:Image
    var price:String?
    var productWeight:String?
    var shortDescription:String
    var longDescription:String?
    var category:String?
    var webpage:String?
    var label:String?
    var equipment:[String]?
    var bareInMind:[String]?
    var articleNumber:String?
    var manufacturer:String?
    var iconStorageIds:[String]?
    var modelStoragesIds:[String]?
    var instructionVideoUrls:[String]?
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
        
    static func == (lhs: TentItem, rhs: TentItem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct TentDb:Codable{
    var id: String?
    var index:Int?
    var name: String?
    var price:String?
    var productWeight:String?
    var shortDescription:String?
    var longDescription:String?
    var category:String?
    var webpage:String?
    var label:String?
    var equipment:[String]?
    var bareInMind:[String]?
    var articleNumber:String?
    var manufacturer:String?
    var iconStorageIds:[String]?
    var modelStoragesIds:[String]?
    var instructionVideoUrls:[String]?
   
    func toTentItem(index:Int,image:Image) -> TentItem{
        return TentItem(id: self.id ?? "",
                        index: index,
                        name: self.name ?? "",
                        img: image,
                        price: self.price ?? "",
                        productWeight:self.productWeight ?? "",
                        shortDescription:self.shortDescription ?? "",
                        longDescription:self.longDescription ?? "",
                        category:self.category ?? "",
                        webpage:self.webpage ?? "",
                        label:self.label ?? "",
                        equipment:self.equipment ?? [],
                        bareInMind:self.bareInMind ?? [],
                        articleNumber:self.articleNumber ?? "",
                        manufacturer:self.manufacturer ?? "",
                        iconStorageIds:self.iconStorageIds ?? [],
                        modelStoragesIds:self.modelStoragesIds ?? [],
                        instructionVideoUrls:self.instructionVideoUrls ?? [])
    }
}
