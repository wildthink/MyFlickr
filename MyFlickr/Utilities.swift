//
//  Utilities.swift
//  MyFlickr
//
//  Created by Jason Jobe on 9/13/24.
//
import Foundation
import SwiftUI


@MainActor
class FlickrAPI: ObservableObject {
    @Published var inProgress: Bool = false
    private var fetchTask: Task<FlickrRequest?, Never>?

    func url(_ tags: String) -> URL? {
        URL(string: "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=\(tags)")
    }

    func fetch(_ tags: String) async -> FlickrRequest? {
        if inProgress {
            fetchTask?.cancel()
        }

        inProgress = true

        fetchTask = Task { [weak self] in
            guard let self else { return nil }
            guard let url = url(tags) else {
                log.warning("Unable to create URL with \(tags)")
                inProgress = false
                return nil
            }

            do {
                let (data, response) = try await URLSession.shared.data(from: url)

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    log.warning("Unexpected response from server")
                    inProgress = false
                    return nil
                }

                let decoder = JSONDecoder.standard
                let result = try decoder.decode(FlickrRequest.self, from: data)
                inProgress = false
                return result

            } catch {
                if Task.isCancelled {
                    log.info("Fetch task was cancelled.")
                } else {
                    log.error("Error fetching data: \(error.localizedDescription)")
                }
                inProgress = false
                return nil
            }
        }

        return await fetchTask?.value
    }
}

struct Matrix<Element> {
    private var elements: [Element]
    private let columnCount: Int
    
    init(elements: [Element], columnCount: Int) {
        self.elements = elements
        self.columnCount = columnCount
    }
    
    func elementAt(row: Int, column: Int) -> Element? {
        let index = row * columnCount + column
        guard index < elements.count else { return nil }
        return elements[index]
    }
    
    func row(at index: Int) -> [Element]? {
        guard index * columnCount < elements.count else { return nil }
        let startIndex = index * columnCount
        let endIndex = min(startIndex + columnCount, elements.count)
        return Array(elements[startIndex..<endIndex])
    }
}


extension Array {
    func splitInSubArrays(into size: Int) -> [[Element]] {
        return (0..<size).map {
            stride(from: $0, to: count, by: size).map { self[$0] }
        }
    }
}
