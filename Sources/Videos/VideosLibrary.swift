import UIKit
import Photos

class VideosLibrary {

  var items: [Video] = []
  var fetchResults: PHFetchResult<PHAsset>?

  // MARK: - Initialization

  init() {

  }

  // MARK: - Logic

  func reload(_ completion: @escaping () -> Void) {
    DispatchQueue.global().async {
      self.reloadSync()
      DispatchQueue.main.async {
        completion()
      }
    }
  }

  fileprivate func reloadSync() {
    fetchResults = PHAsset.fetchAssets(with: .video, options: nil)

    items = []

    fetchResults?.enumerateObjects({ (asset, _, _) in
        
    self.items.insert(Video(asset: asset), at: 0)
      //self.items.append(Video(asset: asset))
    })
  }
}

