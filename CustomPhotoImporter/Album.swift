//
//  Album.swift
//  CustomPhotoImporter
//
//  Created by Matias Korhonen on 28.2.2022.
//

import Foundation
import Photos

struct ImportError: Error {
    enum ErrorKind {
        case collectionError
        case placeholderError
        case assetError
        case otherError
    }
    let kind: ErrorKind
}

class Album: Hashable {
    static func == (lhs: Album, rhs: Album) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    var name: String
    var photos: [Photo] = []
    var topLevelCollection: PHCollectionList?
    var topLevelCollectionPlaceholder: PHObjectPlaceholder?
    var assetCollection: PHAssetCollection?
    var assetCollectionPlaceholder: PHObjectPlaceholder?
    
    init(name: String) {
        self.name = name
    }
    
    func findOrCreateTopLevelCollection() {
        let collectionOptions = PHFetchOptions()
        collectionOptions.predicate = NSPredicate.init(format: "title = %@", "Lightroom")

        let collectionLists = PHCollectionList.fetchCollectionLists(with: .folder, subtype: .regularFolder, options: collectionOptions)
        
        // If found, then get the first album out
        if let existingList = collectionLists.firstObject {
            self.topLevelCollection = existingList
        } else {
            // Create a new album if not found
            do {
                try PHPhotoLibrary.shared().performChangesAndWait {
                    let request = PHCollectionListChangeRequest.creationRequestForCollectionList(withTitle: "Lightroom")
                    self.topLevelCollectionPlaceholder = request.placeholderForCreatedCollectionList
                }
                let collectionFetchResult = PHCollectionList.fetchCollectionLists(withLocalIdentifiers: [self.topLevelCollectionPlaceholder!.localIdentifier], options: nil)
                self.topLevelCollection = collectionFetchResult.firstObject
            } catch {
                print("Couldn't create top-level list: \(error)")
            }
        }
    }
    
    func findOrCreateAlbum() {
        if topLevelCollection == nil {
            findOrCreateTopLevelCollection()
        }
        
        let collectionOptions = PHFetchOptions()
        collectionOptions.predicate = NSPredicate.init(format: "title = %@", name)

        let assetCollections = PHCollection.fetchCollections(in: topLevelCollection!, options: collectionOptions)
        
        // If found, then get the first album out
        if let existingAlbum = assetCollections.firstObject as? PHAssetCollection {
            self.assetCollection = existingAlbum
        } else {
            // Create a new album if not found
            do {
                try PHPhotoLibrary.shared().performChangesAndWait {
                    let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.name)
                    self.assetCollectionPlaceholder = request.placeholderForCreatedAssetCollection
                    let childRequest = PHCollectionListChangeRequest(for: self.topLevelCollection!)!
                    childRequest.addChildCollections([self.assetCollectionPlaceholder!] as NSArray)
                }
                let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [self.assetCollectionPlaceholder!.localIdentifier], options: nil)
                self.assetCollection = collectionFetchResult.firstObject
            } catch {
                print("Couldn't create album: \(error)")
            }
        }
    }
    
    func importIntoPhotos() {
        if assetCollection == nil {
            findOrCreateAlbum()
        }
        
        guard let album = self.assetCollection else {
            print("Album in Photos not found!")
            return
        }
        
        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                // Request editing the album
                guard let addAssetRequest = PHAssetCollectionChangeRequest(for: album) else { return }
                
                do {
                    let placeholders = try self.photos.map { photo -> PHObjectPlaceholder in
                        // Request creating an asset from the image
                        guard let creationRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: photo.originalURL!) else {
                            throw ImportError.init(kind: .assetError)
                        }
                        
                        // Get a placeholder for the new asset
                        guard let placeholder = creationRequest.placeholderForCreatedAsset else {
                            throw ImportError.init(kind: .placeholderError)
                        }
                        
                        if photo.edited {
                            // Set the edited photo as an adjustment
                            let output = PHContentEditingOutput(placeholderForCreatedAsset: placeholder)
                            let editedData = try Data(contentsOf: photo.editedURL!)
                            try editedData.write(to: output.renderedContentURL, options: .atomic)
                            output.adjustmentData = PHAdjustmentData(
                                formatIdentifier: "customImport",
                                formatVersion: "1",
                                data: "Imported 📸".data(using: .utf8)!
                            )
                            creationRequest.contentEditingOutput = output
                        }

                        return placeholder
                    }
                    
                    // Add the placeholder to the album editing request
                    addAssetRequest.addAssets(placeholders as NSArray)
                } catch {
                    print(error)
                }
            }
        } catch {
            print("Error importing photos for album \(name): \(error)")
        }
    }
}
