//
//  ImportFiles.swift
//  CustomPhotoImporter
//
//  Created by Matias Korhonen on 1.8.2021.
//

import Foundation

class ImportFiles {
    var baseUrl: URL

    init(baseUrl: URL) {
        self.baseUrl = baseUrl
    }

    func albums() -> [Album] {
        let resourceKeys = Set<URLResourceKey>([.parentDirectoryURLKey, .contentTypeKey])
        guard let enumerator = FileManager.default.enumerator(at: baseUrl, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles, errorHandler: nil) else { return [Album]() }

        var albums = [Album]()

        let separators = CharacterSet(charactersIn: ".-")

        enumerator.forEach { file in
            guard let fileUrl = file as? URL else { return }

            guard let resourceValues = try? fileUrl.resourceValues(forKeys: resourceKeys),
                    let parentDirectory = resourceValues.parentDirectory,
                    let contentType = resourceValues.contentType
                    else { return }

            if contentType.conforms(to: .image) {
                var albumIndex: Array<Album>.Index
                let parent = parentDirectory.lastPathComponent

                if let existingAlbumIndex = albums.firstIndex(where: { $0.name == parent }) {
                    albumIndex = existingAlbumIndex
                } else {
                    albumIndex = albums.endIndex
                    albums.append(Album(name: parent))
                }

                let filename = fileUrl.lastPathComponent.lowercased()
                let components = filename.components(separatedBy: separators)
                let basename = components.first!
                var index: Array<Photo>.Index;

                if let photoIndex = albums[albumIndex].photos.firstIndex(where: { $0.basename == basename }) {
                    index = photoIndex
                } else {
                    index = albums[albumIndex].photos.endIndex
                    albums[albumIndex].photos.append(Photo(basename: basename))
                }

                if !filename.contains("-edit") && !filename.contains(".tif") {
                    albums[albumIndex].photos[index].originalURL = fileUrl
                }

                if filename.contains(".dng") || filename.contains(".nef") {
                    albums[albumIndex].photos[index].originalURL = fileUrl
                } else {
                    albums[albumIndex].photos[index].editedURL = fileUrl
                }

                albums[albumIndex].photos.sort { $0.basename < $1.basename }
            }
        }

        albums.sort { $0.name < $1.name }

//        #if DEBUG
//        dump(albums)
//        #endif

        return albums
    }
}
