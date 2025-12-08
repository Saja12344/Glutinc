//
//  File.swift
//  Glutinc
//
//  Created by saja khalid on 17/06/1447 AH.
//

import Foundation

struct HomeProduct: Identifiable {
    let id = UUID()
    let imageName: String
    let name: String
    let username: String
    let rating: Double
    let isGlutenFree: Bool
}
