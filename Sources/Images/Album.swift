import UIKit
import Photos

class Album {
    
    let collection: PHAssetCollection
    var photoItems: [Image] = []
    var videoItems: [Video] = []
    
    
    // MARK: - Initialization
    
    init(collection: PHAssetCollection) {
        self.collection = collection
    }
    
    func reload() {
        photoItems = []
        videoItems = []
        
        let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: nil)
        itemsFetchResult.enumerateObjects({ (asset, count, stop) in
            if asset.mediaType == .image {
                self.photoItems.insert(Image(asset: asset), at: 0)
            }else if asset.mediaType == .video {
                self.videoItems.insert(Video(asset: asset), at: 0)
            }
        })
    }
}
