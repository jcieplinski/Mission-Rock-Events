import SwiftUI
import OSLog
import Observation

private struct ImageCacheKey: EnvironmentKey {
    static let defaultValue = ImageCache(diskCache: DiskImageCache())
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}

@Observable
final class ImageCache: @unchecked Sendable {
    private var memoryCache: [URL: Image] = [:]
    private var diskCache: DiskImageCache
    private let logger = Logger(subsystem: "com.jcieplinski.qui", category: "ImageCache")
    
    init(diskCache: DiskImageCache) {
        self.diskCache = diskCache
    }
    
    func initialize() async {
        // Create a new properly initialized DiskImageCache
        let newDiskCache = await DiskImageCache()
        // Replace the disk cache
        Task { @MainActor in
            self.diskCache = newDiskCache
        }
    }
    
    func image(for url: URL) async -> Image? {
        // Check memory cache first
        if let cachedImage = memoryCache[url] {
            logger.debug("Found image in memory cache for URL: \(url)")
            return cachedImage
        }
        
        // Try loading from disk
        if let diskImage = await diskCache.loadImage(for: url) {
            let image = Image(uiImage: diskImage)
            memoryCache[url] = image
            logger.debug("Loaded image from disk cache for URL: \(url)")
            return image
        }
        
        return nil
    }
    
    func setImage(_ image: Image, for url: URL) {
        memoryCache[url] = image
        
        // Save to disk in the background
        Task { @MainActor in
            if let uiImage = image.uiImage {
                await diskCache.saveImage(uiImage, for: url)
            }
        }
    }
    
    func clearMemoryCache() {
        memoryCache.removeAll()
    }
    
    func clearDiskCache() async {
        await diskCache.cleanup(keeping: [])
    }
    
    func cleanup(keeping urls: Set<URL>) async {
        // Clear memory cache
        memoryCache.removeAll()
        
        // Clean up disk cache
        await diskCache.cleanup(keeping: urls)
    }
}

// Helper extension to convert SwiftUI Image to UIImage
extension Image {
    @MainActor
    var uiImage: UIImage? {
        let renderer = ImageRenderer(content: self.resizable())
        return renderer.uiImage
    }
}

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    @Environment(\.imageCache) private var imageCache
    @State private var cachedImage: Image?
    
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
        Group {
            if let image = cachedImage {
                content(image)
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
                                cachedImage = image
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
        .task {
            if let url {
                cachedImage = await imageCache.image(for: url)
            }
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
}
