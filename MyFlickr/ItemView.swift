//
//  ItemView.swift
//  MyFlickr
//
//  Created by Jason Jobe on 9/13/24.
//

import SwiftUI
import SwiftSoup

struct ItemView: View {
    let item: Item
    var showDetails = true
    var height: CGFloat = 200
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                AsyncImage(url: item.imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        Image(systemName: "photo")
                    @unknown default:
                        Image(systemName: "photo")
                    }
                }
                .clipShape(.rect(cornerRadius: 16))
                
                if showDetails {
                    details
                        .padding(.horizontal)
                }
            }
            if !showDetails {
                HStack {
                    Text(item.title)
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.vertical, 2)
                }
                .background(.regularMaterial)
                .alignmentGuide(.bottom) { dim in
                     dim[.bottom] + 6
                }
            }
        }
        .padding(.bottom)
        .background(.white)
        .clipShape(.rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.caption)")
    }
    
    var details: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                if let url = URL(string: item.link) {
                    ShareButtonView(urlToShare: url)
                }
            }
            
            Text(item.caption)
                .font(.body)
                .foregroundColor(.secondary)
            
            Group {
                Text("Author: \(item.author)")
                
                Text("Published on: \(dateFormatter.string(from: item.published))")
                
                if let wd = item.imageInfo?.width,
                   let ht = item.imageInfo?.height {
                    Text("Image Size \(Int(wd)) x \(Int(ht))")
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
}

#Preview("Detail View") {
    ItemView(item: .preview)
        .padding()
}

#Preview("Cell View") {
    ItemView(item: .preview, showDetails: false)
        .padding()
        .border(.green)
}
