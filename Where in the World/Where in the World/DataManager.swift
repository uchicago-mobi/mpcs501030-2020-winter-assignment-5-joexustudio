//
//  DataManager.swift
//  Where in the World
//
//  Created by Sheng Xu (TT) on 2/7/20.
//  Copyright © 2020 Sheng Xu. All rights reserved.
//

import UIKit

public class DataManager {
    
    // MARK: - Singleton Stuff
    public static let sharedInstance = DataManager()
    
    // This prevents others from using the default '()' initializer
    fileprivate init() {}
    
    func loadAnnotationFromPlist() -> [Place] {
        if let data = dataFromPlist() {
            var places: [Place] = []
            for placeData in data.places {
                places.append(Place(data: placeData))
            }
            return places
        }
        return []
    }
    
    func dataFromPlist() -> Data? {
        // https://learnappmaking.com/plist-property-list-swift-how-to/
        // https://www.ioscreator.com/tutorials/load-data-property-list-ios-tutorial
        // https://useyourloaf.com/blog/using-swift-codable-with-property-lists/
        // Load Data from Data.plist
        if  let path = Bundle.main.path(forResource: "Data", ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path),
            let data = try? PropertyListDecoder().decode(Data.self, from: xml) {
            return data
        }
        return nil
    }
    
    func saveFavorites(_ placeName: String) {
        var favorites = listFavorites()
        if !favorites.contains(placeName) {
            favorites.append(placeName)
        }
        UserDefaults.standard.set(favorites, forKey: "Favorites")
    }

    func deleteFavorite(_ placeName: String) {
        var favorites = listFavorites()
        // https://stackoverflow.com/questions/24051633/how-to-remove-an-element-from-an-array-in-swift
        favorites = favorites.filter() { $0 != placeName }
        UserDefaults.standard.set(favorites, forKey: "Favorites")
    }

    func listFavorites() -> [String] {
        if let favorites = UserDefaults.standard.stringArray(forKey: "Favorites") {
            return favorites
        }
        UserDefaults.standard.set([], forKey: "Favorites")
        return []
    }
    
    func isFavorite(_ placeName: String) -> Bool {
        return listFavorites().contains(placeName)
    }
    
    func toggleFavorite(_ placeName: String) {
        if isFavorite(placeName) {
            deleteFavorite(placeName)
        } else {
            saveFavorites(placeName)
        }
    }

}

