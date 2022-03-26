//
//  ImportView.swift
//  CustomPhotoImporter
//
//  Created by Matias Korhonen on 26.3.2022.
//

import SwiftUI

struct ImportView: View {
    @Binding var isVisible: Bool
    var albums: [Album] = []
    @State var isImporting = false
    @State var currentAlbum: Album?
    @State var runningCount = 0
    
    var body: some View {
        VStack {
            if let album = currentAlbum {
                Text("Importing: \(album.name) (\(runningCount)/\(albums.count)")
            } else {
                Text("This will import \(albums.count) album(s) into Photos.app, are you sure?")
            }
            Spacer()
            HStack {
                Button( action: { self.isVisible = false }) {
                    Text("Cancel")
                }.disabled(isImporting)
                Spacer()
                
                Button(action: {
                    self.isImporting = true
                    albums.forEach { album in
                        self.runningCount = self.runningCount + 1
                        self.currentAlbum = album
                        album.importIntoPhotos()
                    }
                    self.isImporting = false
                    self.isVisible = false
                }) {
                    Text("Yes, I'm sure")
                }.disabled(isImporting)
            }
        }.frame(width: 300, height: 150).padding()
    }
}

struct ImportView_Previews: PreviewProvider {    
    static var previews: some View {
        StatefulPreviewWrapper(true) { ImportView( isVisible: $0) }
    }
}
