//
//  Photo.swift
//  CustomPhotoImporter
//
//  Created by Matias Korhonen on 28.2.2022.
//

import Foundation

struct Photo: Hashable {
    var basename: String
    var _originalURL: URL?
    var originalURL: URL? {
        get {
            return _originalURL == nil ? editedURL : _originalURL
        }
        set {
            _originalURL = newValue
        }
    }
    var editedURL: URL?

    var edited: Bool {
        if editedURL == nil {
            return false
        }

        if originalURL != editedURL {
            return true
        }

        return false
    }
}
