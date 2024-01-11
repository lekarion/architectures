//
//  ImageLoader.swift
//  Architectures
//
//  Created by developer on 11.01.2024.
//

import UIKit

class ImageLoader {
    init(with url: URL) {
        self.url = url
    }

    var image: UIImage? {
        get async throws {
            if let error = lastError { throw error }
            if let loadedImage = originalImage { return loadedImage }

            do {
                originalImage = try await Self.loadOriginalImage(url)
            } catch {
                lastError = error
                throw error
            }

            return originalImage
        }
    }

    var thumbnail: UIImage? {
        get async throws {
            if let testThumbnail = originalThumbnail { return testThumbnail }

            do {
                guard let image = try await self.image else { throw FetchError.invalidImage }
                originalThumbnail = try await Self.thumbnail(for: image)
            } catch {
                lastError = error
                throw error
            }

            return originalThumbnail
        }
    }

    var loadingStream: AsyncStream<State> {
        AsyncStream<State> { continuation in
            Task(priority: .utility) {
                if let error = lastError { throw error }

                let image: UIImage
                if let loadedImage = originalImage {
                    continuation.yield(.loading(progress: 0.5))
                    image = loadedImage
                } else {
                    image = try await Self.loadOriginalImage(url, progressContinuation: continuation, progressScale: 0.5)
                }

                if let loadedThumbnail = originalThumbnail {
                    continuation.yield(.loading(progress: 1.0))
                    continuation.yield(.ready(image: image, thumbnail: loadedThumbnail))
                } else {
                    let thumbnail = try await Self.thumbnail(for: image)
                    continuation.yield(.loading(progress: 1.0))
                    continuation.yield(.ready(image: image, thumbnail: thumbnail))
                }

                continuation.finish()
            }
        }
    }

    // MARK: ### Private ###
    private let url: URL
    private var originalImage: UIImage?
    private var originalThumbnail: UIImage?
    private var lastError: Error?
}

extension ImageLoader {
    enum State {
        case loading(progress: Float)
        case ready(image: UIImage, thumbnail: UIImage)
    }

    enum FetchError: Error {
        case dataGettingFailed(errorCode: Int)
        case invalidImage
        case thumbnailPreparingFailed
    }

    static let thumbnailSize = CGSize(width: 64.0, height: 64.0)
}

private extension ImageLoader {
    static func loadOriginalImage(_ url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)

        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            guard statusCode == 200 else { throw FetchError.dataGettingFailed(errorCode: statusCode) }
        }

        guard let image = UIImage(data: data) else { throw FetchError.invalidImage }
        return image
    }

    static func loadOriginalImage(_ url: URL, progressContinuation: AsyncStream<State>.Continuation, progressScale: Float = 1.0) async throws -> UIImage {
        if #available(iOS 15, *) {
            let (stream, response) = try await URLSession.shared.bytes(from: url)

            var imageDataBytes = Data()
            for try await byte in stream {
                imageDataBytes.append(contentsOf: [byte])
                progressContinuation.yield(.loading(progress: Float(imageDataBytes.count) * progressScale / Float(response.expectedContentLength)))
            }

            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                guard statusCode == 200 else { throw FetchError.dataGettingFailed(errorCode: statusCode) }
            }

            guard let image = UIImage(data: imageDataBytes) else { throw FetchError.invalidImage }
            return image
        } else {
            async let imageTask = loadOriginalImage(url)
            progressContinuation.yield(.loading(progress: 0.2 * progressScale))

            let image = try await imageTask
            progressContinuation.yield(.loading(progress: 1.0 * progressScale))

            return image
        }
    }

    static func thumbnail(for image: UIImage) async throws -> UIImage {
        if #available(iOS 15, *) {
            guard let thumbnail = await image.byPreparingThumbnail(ofSize: thumbnailSize) else {
                throw FetchError.thumbnailPreparingFailed
            }
            return thumbnail
        } else {
            let generationTask = Task(priority: .medium) {
                UIGraphicsImageRenderer(size: thumbnailSize).image { _ in
                    image.draw(in: CGRect(origin: .zero, size: thumbnailSize))
                }
            }

            return await generationTask.value
        }
    }
}
