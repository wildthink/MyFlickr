//
//  ContentView.swift
//  MyFlickr
//
//  Created by Jason Jobe on 9/13/24.
//

import SwiftUI
import OSLog

let log = Logger(subsystem: "com.wildthink", category: "flickr")

struct ContentView: View {
    
    @ObservedObject var api: FlickrAPI = .init()
    
    @State var flickr: FlickrRequest?
    @State var search: String = "preview"
    @State var selectedItem: Item?
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    grid
                }
            }
            .navigationTitle("Flickr Finder")
            .overlay {
                if let selectedItem {
                    ZStack {
                        Rectangle()
                            .fill(.thickMaterial)
                        ItemView(item: selectedItem, showDetails: true)
                            .padding(24)
                            .onTapGesture {
                                self.selectedItem = nil
                            }
                    }
                }
            }
        }
        .animation(.default, value: selectedItem)
        .searchable(text: $search, placement: .toolbar)
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .padding()
        .task(id: search) {
            flickr = nil
            guard !search.isEmpty else { return }
            if search.lowercased() == "preview" {
                flickr = .preview
            } else {
                let req = await api.fetch(search)
                flickr = req
            }
        }
    }
    
    @ViewBuilder
    var grid: some View {
        if let flickr {
            Grid {
                ForEach(flickr.items) { item in
                    ItemView(item: item, showDetails: false)
                        .onTapGesture {
                            selectedItem = item
                        }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
