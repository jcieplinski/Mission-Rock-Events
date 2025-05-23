import Foundation
import SwiftUI
import OSLog

actor DiskImageCache {
  private let logger = Logger(subsystem: "com.jcieplinski.qui", category: "DiskImageCache")
  
  private var cacheDirectory: URL {
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("ImageCache", isDirectory: true)
  }
  
  private func cacheKey(for url: URL) -> String {
    // Use a hash of the full URL to ensure uniqueness
    let urlString = url.absoluteString
    let hash = urlString.hash
    return String(format: "%x", abs(hash))
  }
  
  init() {
    // Synchronous initialization for default value
  }
  
  init() async {
    await createCacheDirectoryIfNeeded()
  }
  
  private nonisolated func createCacheDirectoryIfNeeded() async {
    do {
      try await FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    } catch {
      logger.error("Failed to create cache directory: \(error)")
    }
  }
  
  func saveImage(_ image: UIImage, for url: URL) async {
    guard let data = image.jpegData(compressionQuality: 0.8) else {
      logger.error("Failed to convert image to data for URL: \(url)")
      return
    }
    
    let fileURL = cacheDirectory.appendingPathComponent(cacheKey(for: url))
    
    do {
      try data.write(to: fileURL)
      logger.debug("Saved image to disk for URL: \(url)")
    } catch {
      logger.error("Failed to save image to disk for URL: \(url), error: \(error)")
    }
  }
  
  func loadImage(for url: URL) async -> UIImage? {
    let fileURL = cacheDirectory.appendingPathComponent(cacheKey(for: url))
    
    guard let data = try? Data(contentsOf: fileURL),
          let image = UIImage(data: data) else {
      logger.debug("No cached image found for URL: \(url)")
      return nil
    }
    
    logger.debug("Loaded image from disk for URL: \(url)")
    return image
  }
  
  func removeImage(for url: URL) async {
    let fileURL = cacheDirectory.appendingPathComponent(cacheKey(for: url))
    
    do {
      try FileManager.default.removeItem(at: fileURL)
      logger.debug("Removed image from disk for URL: \(url)")
    } catch {
      logger.error("Failed to remove image from disk for URL: \(url), error: \(error)")
    }
  }
  
  func cleanup(keeping urls: Set<URL>) async {
    do {
      let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
      
      for fileURL in fileURLs {
        // Since we're using hashes, we need to check if any of the kept URLs match this file
        let isKept = urls.contains { url in
          cacheKey(for: url) == fileURL.lastPathComponent
        }
        
        if !isKept {
          try FileManager.default.removeItem(at: fileURL)
          logger.debug("Cleaned up unused image: \(fileURL.lastPathComponent)")
        }
      }
    } catch {
      logger.error("Failed to cleanup disk cache: \(error)")
    }
  }
}
