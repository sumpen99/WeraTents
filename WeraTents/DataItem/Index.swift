//
//  Tent.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-29.
//

import SwiftUI
// FOR THE LOVE OF GOD DONT REMOVE IMPORT
import FirebaseFirestoreSwift
import OrderedCollections

struct CatalogeBrand:Identifiable,Hashable{
    var id:String
    var cataloge:String
    var brand:String
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
        
    static func == (lhs: CatalogeBrand, rhs: CatalogeBrand) -> Bool {
        return lhs.id == rhs.id
    }
    
}

struct Meta:Codable{
    let width:Float
    let height:Float
    let depth:Float
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

struct Wera{
    let brands:[String]?
    let instructionVideoUrls:[String]?
    let instructionPdfUrls:[String]?
    let iconIdUrls:[String]?
    let modelIdUrls:[String]?
    let webPage:String?
    var cataloge:OrderedDictionary<String,Cataloge>?
}

struct WeraDb:Codable{
    let brands:[String]?
    let instructionVideoUrls:[String]?
    let instructionPdfUrls:[String]?
    let iconIdUrls:[String]?
    let modelIdUrls:[String]?
    let webPage:String?
    var catalogeDb:[CatalogeDb]?
    
    func toWera() -> Wera{
        var newCataloge:OrderedDictionary<String,Cataloge> = [:]
        if let catalogesDb = catalogeDb{
            for catalogeDb in catalogesDb{
                if let type = catalogeDb.type{
                    newCataloge[type] = catalogeDb.toCataloge()
                }
            }
        }
        return Wera(brands: self.brands,
                    instructionVideoUrls: self.instructionVideoUrls,
                    instructionPdfUrls: self.instructionPdfUrls,
                    iconIdUrls: self.iconIdUrls, 
                    modelIdUrls: self.modelIdUrls,
                    webPage: self.webPage,
                    cataloge: newCataloge)
    }
}

struct Cataloge{
    let id:String
    let type:String?
    let header:String?
    let iconIdUrls:[String]?
    let modelIdUrls:[String]?
    let instructionPdfUrls:[String]?
    let instructionVideoUrls:[String]?
    var brands:OrderedDictionary<String,Brand>?
}

struct CatalogeDb:Codable,Hashable{
    let id:String
    let type:String?
    let header:String?
    let iconIdUrls:[String]?
    let modelIdUrls:[String]?
    let instructionPdfUrls:[String]?
    let instructionVideoUrls:[String]?
    var brandsDb:[BrandDb]?
    
    static func == (lhs: CatalogeDb, rhs: CatalogeDb) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    func toCataloge() -> Cataloge{
        var newBrands:OrderedDictionary<String,Brand> = [:]
        if let brandsDb = brandsDb{
            for brandDb in brandsDb{
                if let label = brandDb.label{
                    newBrands[label] = brandDb.toBrand()
                }
            }
        }
        return Cataloge(id: self.id,
                        type: self.type,
                        header: self.header,
                        iconIdUrls: self.iconIdUrls,
                        modelIdUrls: self.modelIdUrls,
                        instructionPdfUrls: self.instructionPdfUrls,
                        instructionVideoUrls: self.instructionVideoUrls,
                        brands: newBrands)
    }
    
}

struct Brand{
    let label:String?
    let header:String?
    let subHeader:String?
    let iconIdUrls:[String]?
    let modelIdUrls:[String]?
    let instructionPdfUrls:[String]?
    let instructionVideoUrls:[String]?
    var tents:OrderedDictionary<String,Tent>?
}

struct BrandDb:Codable{
    let label:String?
    let header:String?
    let subHeader:String?
    let iconIdUrls:[String]?
    let modelIdUrls:[String]?
    let instructionPdfUrls:[String]?
    let instructionVideoUrls:[String]?
    var tentsDb:[TentDb]?
    
    func toBrand() -> Brand{
        var newTents:OrderedDictionary<String,Tent> = [:]
        if let tentsDb = tentsDb{
            for tentDb in tentsDb{
                if let modelId = tentDb.modelId{
                    newTents[modelId] = tentDb.toTent()
                }
            }
        }
        return Brand(label: self.label,
                     header: self.header,
                     subHeader: self.subHeader,
                     iconIdUrls: self.iconIdUrls,
                     modelIdUrls: self.modelIdUrls,
                     instructionPdfUrls: self.instructionPdfUrls,
                     instructionVideoUrls: self.instructionVideoUrls,
                     tents: newTents)
    }
    
}
                
struct Tent:Identifiable,Hashable{
    var id:String
    var name:String
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
    var meta:Meta?
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
        
    static func == (lhs: Tent, rhs: Tent) -> Bool {
        return lhs.id == rhs.id
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
    var meta:Meta?
       
    func toTent() -> Tent{
        return Tent(id: shortId(),
                    name: self.name ?? "",
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
