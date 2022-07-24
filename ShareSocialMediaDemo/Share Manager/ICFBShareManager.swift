//
//  ICFBShareManager.swift
//  ShareSocialMediaDemo
//
//  Created by Nazmul on 26/04/2022.
//
//https://itnext.io/ios-swift-facebook-sharing-e473e6b2fc48

import Foundation
import UIKit
import FBSDKShareKit
import Photos
import AVKit
import AVFoundation

class ICFBShareManager: NSObject {
    
    class func shareImageToFacebook(imageUrl: URL, isMessenger: Bool) {
        let image = UIImage(contentsOfFile: imageUrl.path)!
        let content = getPhotoContentforFB(image: image)
        isMessenger ? shareInMessenger(content: content) : shareInFacebook(content: content)
    }
    
    class func shareVideoToFacebook (phasset: PHAsset, isMessenger: Bool){
        let content = getVideoContentforFB(videoAsset: phasset)
        
        isMessenger ? shareInMessenger(content: content): shareInFacebook(content: content)
    }
    
    private class func getPhotoContentforFB(image: UIImage) -> SharingContent {
        
        // For sharing Photo
        let photo = SharePhoto(image: image, userGenerated: true)
        let photoContent = SharePhotoContent()
        photoContent.photos = [photo]
        
        // Hashtag
        //photoContent.hashtag = Hashtag("#MatrixSolution")
        
        // URL
        //photoContent.contentURL = URL.init(string: "https://matrixsolution.xyz/")!
        
        return photoContent
    }
    
    private class func getVideoContentforFB(videoAsset: PHAsset) -> SharingContent {
        
        // For sharing Video
        let video = ShareVideo.init(videoAsset: videoAsset)
        
        let videoContent = ShareVideoContent()
        videoContent.video = video
        
        // Hashtag
        //videoContent.hashtag = Hashtag("#MatrixSolution")
        
        // URL
        //videoContent.contentURL = URL.init(string: "https://matrixsolution.xyz/")!
        
        return videoContent
    }
    
    private class func shareInMessenger(content: SharingContent) {
        
        guard let viewController = UIViewController.topMostViewController() else { return }

        let dialog = MessageDialog(content: content, delegate: viewController as? SharingDelegate)
        
        // Recommended to validate before trying to display the dialog
        do {
            try dialog.validate()
        } catch {
            print(error)
        }
        
        dialog.show()
    }
    
    private  class func shareInFacebook(content: SharingContent) {
        guard let viewController = UIViewController.topMostViewController() else { return }
        
        let dialog = ShareDialog.init(viewController: viewController, content: content, delegate: viewController as? SharingDelegate)

        // Recommended to validate before trying to display the dialog
        do {
            try dialog.validate()
        } catch {
            print(error)
        }
        dialog.show()
    }
    
}
