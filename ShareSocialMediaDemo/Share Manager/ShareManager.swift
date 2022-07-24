//
//  ShareManager.swift
//  ShareSocialMediaDemo
//
//  Created by Nazmul on 24/06/2022.
//

import UIKit
import Photos

protocol ShareManagerDelegate: NSObjectProtocol{
    func currentSharePhasset(phasset: PHAsset)
}

class ShareManager: NSObject {
    
    static let shareInstace = ShareManager()
    weak var delegate: ShareManagerDelegate?
    
    var phasset: PHAsset?
    
    func shareExportedUrl(exportedUrl: URL) -> Void {
        
        let fileextension = exportedUrl.fileExtension
        if phasset == nil {
            print("EXTENSTION")
            switch fileextension.lowercased(){
            case "mp4","mov":
                self.saveVideoInPhotosLibrary(videoUrl: exportedUrl)
                break
            default:
                self.saveImageInPhotosLibrary(imageUrl: exportedUrl)
                break
            }
        }
        else{
            delegate?.currentSharePhasset(phasset: phasset!)
        }
    }
    
    private func saveImageInPhotosLibrary(imageUrl: URL) {
        
        let image = UIImage(contentsOfFile: imageUrl.path)!
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(ShareManager.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    private func saveVideoInPhotosLibrary(videoUrl: URL) {
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoUrl.path) {
            UISaveVideoAtPathToSavedPhotosAlbum(videoUrl.path, self, #selector(ShareManager.video(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        else {
            print("Video is not eligiable to save this path")
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("NNNNN")
        if error == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.fethchLastObjectFromGallery(isVideo: false)
            }
        }
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("xxxx")
        if error == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.fethchLastObjectFromGallery(isVideo: true)
            }
        }
    }
    
    private func fethchLastObjectFromGallery(isVideo: Bool) {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: isVideo ? true : true)]
        // it's weired the ascending value is different for video and image, no idea why
        // Need to check this matter later
        let fetchResult = isVideo ? PHAsset.fetchAssets(with: .video, options: fetchOptions) : PHAsset.fetchAssets(with: .image, options: fetchOptions)
      
        if let lastAsset = fetchResult.lastObject {
            self.phasset = lastAsset
            
            delegate?.currentSharePhasset(phasset: lastAsset)
            //let url = URL(string: "instagram://library?LocalIdentifier=\(lastAsset.localIdentifier)")!
        }
    }
}
