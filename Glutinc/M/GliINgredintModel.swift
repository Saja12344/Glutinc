//
//  GliINgredintModel.swift
//  Glutinc
//
//  Created by saja khalid on 10/06/1447 AH.
//
import Foundation

// Simple model representing a gluten ingredient found in the text.
// Conforms to Identifiable for use in SwiftUI lists and ForEach.
struct GlutenIngredient: Identifiable,Equatable {
    let id = UUID()   // Unique identifier for SwiftUI
    let name: String  // The keyword/ingredient name (e.g., "wheat")
 
}

