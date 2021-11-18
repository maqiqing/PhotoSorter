//
//  SimilarPhotosViewController.swift
//  DealPhoto
//
//  Created by maqiqing on 2021/11/5.
//

import UIKit
import Photos
import PhotosUI

class SimilarPhotosViewController: BaseViewController {

    var similarPhotos = [[PHAsset]]()
    fileprivate let imageManager = PHCachingImageManager()

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "相似图片"
    }

}

extension SimilarPhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return similarPhotos.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return similarPhotos[section].count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: GridViewCell.self, for: indexPath)
        
        let asset = similarPhotos[indexPath.section][indexPath.item]
        // Add a badge to the cell if the PHAsset represents a Live Photo.
//        if asset.mediaSubtypes.contains(.photoLive) {
//            cell.livePhotoBadgeImage = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
//        }
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 120 * UIScreen.main.scale, height: 120 * UIScreen.main.scale), contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // UIKit may have recycled this cell by the handler's activation time.
            // Set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let array = similarPhotos[indexPath.section]
        return CGSize(width: (collectionView.width - 41) / array.count.cgFloat, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 50, left: 20, bottom: 0, right: 20)
    }
    
}
