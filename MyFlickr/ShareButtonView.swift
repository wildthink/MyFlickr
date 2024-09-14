//
//  ShareButtonView.swift
//  MyFlickr
//
//  Created by Jason Jobe on 9/13/24.
//


import SwiftUI

struct ShareButtonView: View {
    let urlToShare: URL

    var body: some View {
        Button(action: {
            shareURL(urlToShare)
        }) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
    }

    private func shareURL(_ url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

struct ShareButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ShareButtonView(urlToShare: URL(string: "https://www.example.com")!)
    }
}