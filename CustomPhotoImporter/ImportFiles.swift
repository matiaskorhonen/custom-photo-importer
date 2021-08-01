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

    func files() -> [String: [URL]] {
        let resourceKeys = Set<URLResourceKey>([.parentDirectoryURLKey, .contentTypeKey])
        guard let enumerator = FileManager.default.enumerator(at: baseUrl, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles, errorHandler: nil) else { return [String: [URL]]() }

        let deepFiles = enumerator.reduce(into: [String: [URL]]()) { result, file in
            guard let fileUrl = file as? URL else { return }

            guard let resourceValues = try? fileUrl.resourceValues(forKeys: resourceKeys),
                    let parentDirectory = resourceValues.parentDirectory,
                    let contentType = resourceValues.contentType
                    else { return }

            if contentType.conforms(to: .image) {
                let parent = parentDirectory.lastPathComponent
                if !result.keys.contains(parent) {
                    result[parent] = []
                }
                result[parent]?.append(fileUrl)
            }
        }

        #if DEBUG
        dump(deepFiles)
        #endif

        return deepFiles
    }
}
