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
    @State var importFiles: ImportFiles!

    var body: some View {
        VStack {
            Button("Select import location") {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseFiles = false
                panel.canChooseDirectories = true
                if panel.runModal() == .OK {
                    if let url = panel.url {
                        self.importFiles = ImportFiles(baseUrl: url)
                        self.folderURL = url

                        let _ = self.importFiles.files()

                        if let files = try?
                            FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.contentTypeKey, .nameKey, .fileSizeKey], options: .skipsHiddenFiles) {
                            self.files = files.sorted {
                                $0.lastPathComponent < $1.lastPathComponent
                            }
                        }

                    }
                }
            }
            if let url = folderURL {
                Text(url.absoluteString)
            }
            List {
                ForEach(files, id: \.self) {
                    Text($0.lastPathComponent)
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
