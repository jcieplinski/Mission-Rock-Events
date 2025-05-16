import SwiftUI
import OSLog

@Observable
final class ImageCache {
    private var cache: [URL: Image] = [:]
    private let logger = Logger(subsystem: "com.jcieplinski.qui", category: "ImageCache")
    
    func image(for url: URL) -> Image? {
        return cache[url]
    }
    
    func setImage(_ image: Image, for url: URL) {
        cache[url] = image
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    @Environment(ImageCache.self) private var imageCache
    
    init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        if let url, let cachedImage = imageCache.image(for: url) {
            content(cachedImage)
        } else if let url {
            AsyncImage(
                url: url,
                scale: scale,
                transaction: transaction
            ) { phase in
                switch phase {
                case .empty:
                    placeholder()
                case .success(let image):
                    content(image)
                        .onAppear {
                            imageCache.setImage(image, for: url)
                        }
                case .failure:
                    placeholder()
                @unknown default:
                    placeholder()
                }
            }
        } else {
            placeholder()
        }
    }
}

#Preview {
    CachedAsyncImage(
        url: URL(string: "https://example.com/image.jpg")
    ) { image in
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
    } placeholder: {
        ProgressView()
    }
    .environment(ImageCache())
} 