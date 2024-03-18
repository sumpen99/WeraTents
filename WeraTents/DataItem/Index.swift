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
    var label:String { get }
    var shortDescription:String { get }
    var price:String{ get }
}

struct VideoItem:Identifiable,Hashable{
    let id:String
    let videoUrl:String
    let title:String
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
        
    static func == (lhs: VideoItem, rhs: VideoItem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct PdfItem:Identifiable,Hashable{
    let id:String
    let pdfId:String
    let title:String
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
        
    static func == (lhs: PdfItem, rhs: PdfItem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct VideoResourcesItem:Hashable{
    let id:String
    let listOfVideoItems:[VideoItem]
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
        
    static func == (lhs: VideoResourcesItem, rhs: VideoResourcesItem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct PdfResourcesItem:Hashable{
    let id:String
    let listOfPdfItems:[PdfItem]
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
        
    static func == (lhs: PdfResourcesItem, rhs: PdfResourcesItem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct BrandModel:Equatable{
    let brand:String?
    let modelId:String?
}

struct TentDimensions{
    let width:Float
    let height:Float
    let depth:Float
}

struct TentMeta{
    let name:String
    let modelId:String
    let shortDesc:String
    let label:String
    var dimensions:TentDimensions?
    
    mutating func setDimension(_ dimensions:TentDimensions?){
        self.dimensions = dimensions
    }
}

struct TentItemDimensions:Codable{
    var width:String?
    var minHeight:String?
    var maxHeight:String?
    var depth:String?
    var depthDescription:String?
    var preferedHeight:String?
    var infoText:String?
   
    var sizeDesc:String{
        "\(widthDesc) x \(depthDesc)"
    }
    
    var heightDesc:String{
        "\(preferedHeightDesc)"
    }
     
    var widthDesc:String{
        if let width = width{
            return width
        }
        return "[bredd] cm"
    }
    
    var depthDesc:String{
        if let depthDescription = depthDescription{
            return depthDescription
        }
        else if let depth = depth{
            return "\(depth) cm"
        }
        return "[djup] cm"
    }
    
    var preferedHeightDesc:String{
        if let preferedHeight = preferedHeight{
            return preferedHeight
        }
        return "[höjd] cm"
    }
}

struct TentItem:CarouselItem{
    var id:String
    var index:Int
    var name:String
    var img:Image
    var label:String
    var modelId:String
    var shortDescription:String
    var price:String
    var productWeight:String?
    var longDescription:String?
    var category:String?
    var webpage:String?
    var dimensions:TentItemDimensions?
    var equipment:[String]?
    var bareInMind:[String]?
    var articleNumber:String?
    var manufacturer:String?
    var iconStorageIds:[String]?
    var modelStorageIds:[String]?
    var instructionVideoUrls:[String]?
    var instructionPdfIds:[String]?
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
        
    static func == (lhs: TentItem, rhs: TentItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func toTentMeta() -> TentMeta{
        return TentMeta(name: self.name,
                        modelId: self.modelId,
                        shortDesc: self.shortDescription,
                        label: self.label)
    }
}

struct TentDb:Codable,Comparable{
    var id: String?
    var index:Int?
    var name: String?
    var price:String?
    var productWeight:String?
    var shortDescription:String?
    var longDescription:String?
    var category:String?
    var webpage:String?
    var modelId:String?
    var label:String?
    var dimensions:TentItemDimensions?
    var equipment:[String]?
    var bareInMind:[String]?
    var articleNumber:String?
    var manufacturer:String?
    var iconStorageIds:[String]?
    var modelStorageIds:[String]?
    var instructionVideoUrls:[String]?
    var instructionPdfIds:[String]?
   
    func toTentItem(index:Int,image:Image) -> TentItem{
        return TentItem(id: self.id ?? "",
                        index: index,
                        name: self.name ?? "",
                        img: image,
                        label:self.label ?? "",
                        modelId: self.modelId ?? "",
                        shortDescription:self.shortDescription ?? "",
                        price: self.price ?? "",
                        productWeight:self.productWeight,
                        longDescription:self.longDescription,
                        category:self.category,
                        webpage:self.webpage,
                        dimensions: self.dimensions,
                        equipment:self.equipment,
                        bareInMind:self.bareInMind,
                        articleNumber:self.articleNumber,
                        manufacturer:self.manufacturer,
                        iconStorageIds:self.iconStorageIds,
                        modelStorageIds:self.modelStorageIds,
                        instructionVideoUrls:self.instructionVideoUrls,
                        instructionPdfIds: self.instructionPdfIds)
    }
    
    static func < (lhs: TentDb, rhs: TentDb) -> Bool{
        if let lhsLabel = lhs.label,
           let rhsLabel = rhs.label{
            return lhsLabel < rhsLabel
        }
        return false
    }
    static func <= (lhs: TentDb, rhs: TentDb) -> Bool{
        if let lhsLabel = lhs.label,
           let rhsLabel = rhs.label{
            return lhsLabel <= rhsLabel
        }
        return false
    }
    static func >= (lhs: TentDb, rhs: TentDb) -> Bool{
        if let lhsLabel = lhs.label,
           let rhsLabel = rhs.label{
            return lhsLabel >= rhsLabel
        }
        return false
    }
    static func > (lhs: TentDb, rhs: TentDb) -> Bool{
        if let lhsLabel = lhs.label,
           let rhsLabel = rhs.label{
            return lhsLabel > rhsLabel
        }
        return false
    }
    
    static func == (lhs: TentDb, rhs: TentDb) -> Bool {
        if let lhsLabel = lhs.label,
           let rhsLabel = rhs.label{
            return lhsLabel == rhsLabel
        }
        return false
    }
    
}