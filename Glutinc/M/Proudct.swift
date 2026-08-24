//
//  Proudct.swift
//  Glutinc
//
//  Created by saja khalid on 17/06/1447 AH.
//
//
//struct ProductModel: Identifiable {
//    let id: String
//    let productName: String
//    let username: String
//    let rating: Double
//    let isGlutenFree: Bool
//    let price: String
//    let location: String
//    let category: String
//    
//}

import Foundation
import UIKit
struct ProductModel: Identifiable, Hashable{
    var id: String = UUID().uuidString
    var productName: String
    var username: String
    var rating: Double
    var isGlutenFree: Bool
    var price: String
    var location: String
    var category: String
    
    let detectedIngredients: [String]

    var notes: String?
    var productURL: String?
    let image: UIImage
    var ownerAppleID: String


    
}

