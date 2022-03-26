//
//  AuthorizedView.swift
//  CustomPhotoImporter
//
//  Created by Matias Korhonen on 1.8.2021.
//

import SwiftUI
import Foundation

struct AuthorizedView: View {
    @State var folderURL: URL!
    @State var files: [URL] = []
    @State var albums: [Album] = []
    @State var importFiles: ImportFiles!
    @State var loading = false
    @State var isShowingImportSheet = false
    
    var albumsCount: Int {
        albums.count
    }
    var photosCount: Int {
        albums.reduce(0, { partialResult, album in
            partialResult + album.photos.count
        })
    }

    var body: some View {
        VStack {
            Button("Select import location") {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseFiles = false
                panel.canChooseDirectories = true
                self.loading = true
                if panel.runModal() == .OK {
                    if let url = panel.url {
                        self.importFiles = ImportFiles(baseUrl: url)
                        self.folderURL = url

                        self.albums = self.importFiles.albums()
                        self.loading = false
                    }
                }
            }
            if let url = folderURL {
                Text(url.absoluteString)
            }
            List {
                if self.loading {
                    Text("Loading…")
                } else {
                    ForEach(albums, id: \.self) { album in
                        Section(header: Text("\(album.name) (\(album.photos.count))")) {
                            ForEach(album.photos, id: \.self) { photo in
                                HStack {
                                    Text("\(photo.basename):").bold()
                                    Text("Original: \(photo.originalURL?.lastPathComponent ?? "—")")
                                    if photo.edited {
                                        Text("Edited:  \(photo.editedURL?.lastPathComponent ?? "")")
                                    }
                                }
                            }
                        }
                    }
                }
            }.padding()
            Divider()
            HStack {
                Text("\(albumsCount) album(s)")
                Text("\(photosCount) photo(s)")
                Spacer()
                Button(action: { isShowingImportSheet.toggle() }) {
                    Text("Import")
                }.disabled(photosCount == 0)
                    .sheet(isPresented: $isShowingImportSheet) {
                        ImportView(isVisible: self.$isShowingImportSheet, albums: albums)
                    }
            }
        }.padding()
    }
}

struct AuthorizedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizedView()
    }
}
