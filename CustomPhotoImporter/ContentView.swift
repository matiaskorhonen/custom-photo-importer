//
//  ContentView.swift
//  CustomPhotoImporter
//
//  Created by Matias Korhonen on 1.8.2021.
//

import SwiftUI
import Photos

struct ContentView: View {
    @State var authorizationStatus: PHAuthorizationStatus!

    var body: some View {
        VStack {
            switch authorizationStatus {
            case .notDetermined:
                Button("Authorize access to Photos") {
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                        self.authorizationStatus = status
                    }
                }
            case .authorized:
                AuthorizedView()
            case .limited:
                Text("Limited")
            case .denied:
                Text("Denied: Photos access is required")
            case .restricted:
                Text("Restricted: Photos access is required")
            default:
                Text("Unknown Photo authorization status")
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity).onAppear(perform: {
            self.authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
