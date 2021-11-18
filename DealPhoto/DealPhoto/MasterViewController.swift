//
//  MasterViewController.swift
//  DealPhoto
//
//  Created by maqiqing on 2021/11/5.
//

import UIKit
import Photos

class MasterViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    
    var allPhotos: PHFetchResult<PHAsset>!
    var screenShotAlbums: PHFetchResult<PHAssetCollection>!
    var videoAlbums: PHFetchResult<PHAssetCollection>!
    var similarPhotos = [[PHAsset]]()
    
    var userCollections: PHFetchResult<PHCollection>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchAssets()
    }
    
    /// - Tag: UnregisterChangeObserver
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    
    func fetchAssets() {
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        videoAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: nil)
        screenShotAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil)
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        PHPhotoLibrary.shared().register(self)
        
        fetchSimilarPhotos()
    }
    func fetchSimilarPhotos() {
        DispatchQueue.global().async {
            guard let array = AMPhotoManager.fectchSimilarArray() as? [[PHAsset]] else {
                return
            }
            self.similarPhotos = array
            var count = 0
            array.forEach {
                count += $0.count
            }
            print("总共图片 = \(array.count)组")
            print("相似图片 = \(count)张")
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [IndexPath(row: 3, section: 0)])
            }
        }
    }

}

extension MasterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 4 : userCollections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: MasterCell.self, for: indexPath)
        if indexPath.section == 0 {
            cell.titleLabel.text = ["所有照片", "截图", "视频", "相似图片"][indexPath.row]
            if indexPath.row == 0 {
                cell.countLabel.text = "\(allPhotos.count)张"
            }
            if indexPath.row == 3 {
                cell.countLabel.text = "\(similarPhotos.count)组"
            }
        }
        if indexPath.section == 1 {
            if let collection = userCollections.object(at: indexPath.row) as? PHAssetCollection {
                let fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
                cell.titleLabel.text = collection.localizedTitle
                cell.countLabel.text = "\(fetchResult.count)"
            }
        }
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.width - 40 - 10) / 2, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                performSegue(withIdentifier: R.segue.masterViewController.showAllPhotos, sender: nil)
            }
            if indexPath.item == 3 {
                performSegue(withIdentifier: R.segue.masterViewController.similarSegue, sender: nil)
            }
        }
        if indexPath.section == 1 {
            guard let collection = userCollections.object(at: indexPath.row) as? PHAssetCollection else {
                return
            }
            performSegue(withIdentifier: R.segue.masterViewController.showCollection, sender: collection)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let info = R.segue.masterViewController.showAllPhotos(segue: segue) {
            info.destination.fetchResult = allPhotos
        }
        if let info = R.segue.masterViewController.showCollection(segue: segue) {
            let collection = sender as! PHAssetCollection
            info.destination.assetCollection = collection
            info.destination.fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
        }
        if let info = R.segue.masterViewController.similarSegue(segue: segue) {
            info.destination.similarPhotos = similarPhotos
        }
    }
    
}

extension MasterViewController {
    
    /// - Tag: CreateAlbum
    @objc
    func addAlbum(_ sender: AnyObject) {
        let alertController = UIAlertController(title: NSLocalizedString("New Album", comment: ""), message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = NSLocalizedString("Album Name", comment: "")
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Create", comment: ""), style: .default) { action in
            let textField = alertController.textFields!.first!
            if let title = textField.text, !title.isEmpty {
                // Create a new album with the entered title.
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
                }, completionHandler: { success, error in
                    if !success { print("Error creating album: \(String(describing: error)).") }
                })
            }
        })
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: PHPhotoLibraryChangeObserver

extension MasterViewController: PHPhotoLibraryChangeObserver {
    /// - Tag: RespondToChanges
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        // Change notifications may originate from a background queue.
        // Re-dispatch to the main queue before acting on the change,
        // so you can update the UI.
        DispatchQueue.main.sync {
            // Check each of the three top-level fetches for changes.
            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
                // Update the cached fetch result.
                allPhotos = changeDetails.fetchResultAfterChanges
                // Don't update the table row that always reads "All Photos."
                self.collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
            }
            
            // Update the cached fetch results, and reload the table sections to match.
            if let changeDetails = changeInstance.changeDetails(for: screenShotAlbums) {
                screenShotAlbums = changeDetails.fetchResultAfterChanges
                self.collectionView.reloadItems(at: [IndexPath(item: 1, section: 0)])
            }
            if let changeDetails = changeInstance.changeDetails(for: videoAlbums) {
                videoAlbums = changeDetails.fetchResultAfterChanges
                self.collectionView.reloadItems(at: [IndexPath(item: 2, section: 0)])
            }
            if let changeDetails = changeInstance.changeDetails(for: userCollections) {
                userCollections = changeDetails.fetchResultAfterChanges
                self.collectionView.reloadSections([1])
            }
        }
    }
}


