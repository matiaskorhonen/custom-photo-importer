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
                        Section(header: Text(album.name)) {
                            ForEach(album.photos, id: \.self) { photo in
                                if photo.edited {
                                    Text("\(photo.basename) - Original: \(photo.originalURL?.lastPathComponent ?? ""), Edited:  \(photo.editedURL?.lastPathComponent ?? "")")
                                } else {
                                    Text("\(photo.basename) - Original: \(photo.originalURL?.lastPathComponent ?? "")")
                                }

                            }
                        }
                    }
                }
            }.padding()
        }.padding()
    }
}

struct AuthorizedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizedView()
    }
}
