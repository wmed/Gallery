import UIKit
import Photos

class VideosLibrary {

    var isSyncing = false
  var items: [Video] = []
  var fetchResults: PHFetchResult<PHAsset>?

    var albums: [Album] = []
    var albumsFetchResults = [PHFetchResult<PHAssetCollection>]()
    
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
        if isSyncing == true{
            return
        }
        
        isSyncing = true
        
        let types: [PHAssetCollectionType] = [.smartAlbum, .album]
        
        albumsFetchResults = types.map {
            return PHAssetCollection.fetchAssetCollections(with: $0, subtype: .any, options: nil)
        }
        
        albums = []
        
        for result in albumsFetchResults {
            
            result.enumerateObjects({ (collection, _, _) in
                let album = Album(collection: collection)
                album.reload()
                
                if !album.videoItems.isEmpty {
                    self.albums.append(album)
                }
            })
        }
        
        if let index = albums.index(where: { $0.collection.assetCollectionSubtype == . smartAlbumUserLibrary }) {
            albums.g_moveToFirst(index)
        }
        isSyncing = false
    }

//  fileprivate func reloadSync() {
//    fetchResults = PHAsset.fetchAssets(with: .video, options: nil)
//
//    items = []
//
//    fetchResults?.enumerateObjects({ (asset, _, _) in
//
//    self.items.insert(Video(asset: asset), at: 0)
//      //self.items.append(Video(asset: asset))
//    })
//  }
}

