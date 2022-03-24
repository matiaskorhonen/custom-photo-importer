//
//  Album.swift
//  CustomPhotoImporter
//
//  Created by Matias Korhonen on 28.2.2022.
//

import Foundation

struct Album: Hashable {
    var name: String
    var photos: [Photo] = []
}
