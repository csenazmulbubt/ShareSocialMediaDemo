//
//  ViewController.swift
//  ShareSocialMediaDemo
//
//  Created by Nazmul on 21/04/2022.
//

import UIKit
import AVFoundation
import Photos
import MessageUI

class ViewController: UIViewController {
   
    @IBOutlet weak var shareView: ShareView!
    
    let videoUrl = Bundle.main.url(forResource: "vid", withExtension: "mp4")
    let imgUrl = Bundle.main.url(forResource: "test1", withExtension: "jpeg")
    let image = UIImage(named: "test1")
    var first = false
    var currentSelectedShareOption: shareOptionType = .saved
    var isInstagramBtn = false
    var isProcessing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareView.delegate = self
        shareView.shareUrl = videoUrl
        ShareManager.shareInstace.phasset = nil
        ShareManager.shareInstace.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func isPhotoUrl(url: URL) -> Bool {
        let fileextension = url.fileExtension
        
        switch  fileextension.lowercased(){
        case "mp4","mov":
            return false
        default:
            return true
        }
    }
}


//MARK: - ShareViewDelegate
extension ViewController: ShareViewDelegate {
    func instagramShareBtnClickd() {
        print("ISNTAGRAM")
        if isProcessing {
            return
        }
        self.isProcessing = true
        if ShareManager.shareInstace.phasset == nil{
            self.isInstagramBtn = true
            ShareManager.shareInstace.shareExportedUrl(exportedUrl: self.videoUrl!)
        }
        else{
            self.isProcessing = false
            self.shareToInstagram(phaseet: ShareManager.shareInstace.phasset!)
        }
    }
    
    
    func selectedShareOption(shareOption: shareOptionType) {
        
        if isProcessing{
            return
        }
        self.currentSelectedShareOption = shareOption
        self.isProcessing = true
        switch shareOption {
        case .saved:
            ShareManager.shareInstace.shareExportedUrl(exportedUrl: self.videoUrl!)
        case .instagramStory:
            self.isProcessing = false
            if isPhotoUrl(url: self.videoUrl!){
                self.sharePhotoAsInstagramStory()
            }
            else{
                self.shareVideoAsInstagramStory()
            }
        
        case .more:
            defaultShareOption()
        
        case .emial:
            self.shareWithEmail()
        
        case .fbStory:
            if isPhotoUrl(url: self.videoUrl!){
                self.shareImageAsFbStory(shareUrl: self.imgUrl!, shareTypeLink: FB_IMG_LINK)
            }
            else{
                self.shareImageAsFbStory(shareUrl: self.videoUrl!, shareTypeLink: FB_VIDEO_LINK)
            }
            break
        
        case .fb:
            if isPhotoUrl(url: self.imgUrl!){
                self.isProcessing = false
                ICFBShareManager.shareImageToFacebook(imageUrl: self.imgUrl!, isMessenger: false)
            }
            else{
                ShareManager.shareInstace.shareExportedUrl(exportedUrl: self.videoUrl!)
            }
        
        case .messenger:
            if isPhotoUrl(url: self.imgUrl!){
                self.isProcessing = false
                ICFBShareManager.shareImageToFacebook(imageUrl: self.imgUrl!, isMessenger: true)
            }
            else{
                ShareManager.shareInstace.shareExportedUrl(exportedUrl: self.videoUrl!)
            }
        default:
            if isPhotoUrl(url: self.imgUrl!){
                self.shareWithSMS()
            }
        }
    }
}


extension ViewController: ShareManagerDelegate{
    
    func currentSharePhasset(phasset: PHAsset) {
        self.isProcessing = false
        if !isInstagramBtn{
            switch currentSelectedShareOption {
            case .saved:
                print("NEED TO ALERT SHOW SAVED SUCCEFULLY")
            case .fb:
                ICFBShareManager.shareVideoToFacebook(phasset: phasset, isMessenger: false)
            case .messenger:
                ICFBShareManager.shareVideoToFacebook(phasset: phasset, isMessenger: true)
            default:
                break
            }
        }
        else{
            isInstagramBtn = false
            shareToInstagram(phaseet: phasset)
        }
    }
}

//MARK: Instagram Share
extension ViewController{
    
    func shareToInstagram(phaseet: PHAsset) -> Void {
        self.isProcessing = false
        let url = URL(string: "instagram://library?LocalIdentifier=\(phaseet.localIdentifier)")!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Instagram is not installed")
        }
    }
    
    func sharePhotoAsInstagramStory() ->Void{
        
        if let storiesUrl = URL(string: "instagram-stories://share") {
            if UIApplication.shared.canOpenURL(storiesUrl) {
                guard let image = UIImage(contentsOfFile: imgUrl!.path) else { return }
                guard let imageData = image.pngData() else { return }
                let pasteboardItems: [String: Any] = [
                    "com.instagram.sharedSticker.stickerImage": imageData,
                    "com.instagram.sharedSticker.backgroundTopColor": "#636e72",
                    "com.instagram.sharedSticker.backgroundBottomColor": "#b2bec3"
                ]
                let pasteboardOptions = [
                    UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
                ]
                UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)
                
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Sorry the application is not installed")
            }
        }
    }
    
    func shareVideoAsInstagramStory() -> Void {
        guard let videoUrl = videoUrl else {
            debugPrint("video.m4v not found")
            return
        }
        do {
            let video = try Data(contentsOf: videoUrl)
            if let storiesUrl = URL(string: "instagram-stories://share") {
                if UIApplication.shared.canOpenURL(storiesUrl) {
                    let pasteboardItems: [String: Any] = [
                        "com.instagram.sharedSticker.backgroundVideo": video,
                        "com.instagram.sharedSticker.backgroundTopColor": "#636e72",
                        "com.instagram.sharedSticker.backgroundBottomColor": "#b2bec3"
                    ]
                    let pasteboardOptions = [
                        UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
                    ]
                    UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                    UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("Sorry the application is not installed")
                }
            }
        } catch {
           print(error)
           return
        }
    }
}

//MARK: - Fb Share Story
extension ViewController{
    
    func shareImageAsFbStory(shareUrl: URL, shareTypeLink: String) -> Void {
        
        do {
            let data = try Data(contentsOf: shareUrl)
            if let storiesUrl = URL(string: "facebook-stories://share") {
                if UIApplication.shared.canOpenURL(storiesUrl) {
                    //"com.facebook.sharedSticker.backgroundImage"
                    let pasteboardItems: [String: Any] = [
                        shareTypeLink: data,
                       "com.facebook.sharedSticker.appID": FB_APP_ID
                    ]
                    let pasteboardOptions = [
                        UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
                    ]
                    UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                    UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("Sorry the application is not installed")
                }
            }
        } catch {
            print(error)
            return
        }
        self.isProcessing = false
    }
}

//MARK: - default,E - mail,and SMS Share
extension ViewController: MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate{
    
    func defaultShareOption() {
        var shareItems: [AnyHashable]?
        
        shareItems = [self.videoUrl]
        //Ref: https://newbedev.com/ios13-share-sheet-how-to-set-preview-thumbnail-when-sharing-uiimage
        if let items = shareItems {
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityViewController.modalPresentationStyle = .popover
                if let popover = activityViewController.popoverPresentationController {
                    popover.sourceView = self.view
                    popover.sourceRect = view.bounds
                    popover.permittedArrowDirections = UIPopoverArrowDirection.down
                }
            }
            /*activityViewController.completionWithItemsHandler = { activity, success, items, error in
             self.resetCollectionViewSelectionStatus()
             }*/
            present(activityViewController, animated: true) {
                self.isProcessing = false
            }
        }
    }
    
    func shareWithEmail() {
        self.isProcessing = false
        
        if (MFMailComposeViewController.canSendMail() == true) {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setSubject("Great Video Created By Square Fit")
            mailComposeViewController.setMessageBody("DownLoad This App", isHTML: false)
            
            let fileextension = imgUrl!.fileExtension
            var fileMIMEType  = "video/\(fileextension)"
            var fileName = "video"
            
            let fileData = try? Data(contentsOf: self.imgUrl!)
            if isPhotoUrl(url: imgUrl!){
                fileMIMEType  = "image/\(fileextension)"
                fileName = "image"
            }
            mailComposeViewController.addAttachmentData(fileData!, mimeType: fileMIMEType, fileName: "\(fileName).\(fileextension)")
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else {
            /*ERAlertController.showAlert("Email Not Setup Yet :(", message: "Please Setup Email & Try Again. Thanks :)", isCancel: false, okButtonTitle: "OK", cancelButtonTitle: "", completion: nil)
            self.resetCollectionViewSelectionStatus()*/
        }
    }
    
    func shareWithSMS() {
        self.isProcessing = false
        if !MFMessageComposeViewController.canSendText() {
           /* ERAlertController.showAlert("Error!", message: "This Device Not Supported to send sms", isCancel: false, okButtonTitle: "OK", cancelButtonTitle: "", completion: nil)
            self.resetCollectionViewSelectionStatus()*/
            return
        }
        let message = "Great Video created by Square Fit app"
        
        let picker = MFMessageComposeViewController()
        picker.messageComposeDelegate = self
        
        picker.body = message
        
        /*if !isPhotoUrl(url: self.videoUrl!) {
            let vData = try? Data(contentsOf: videoUrl!)
            if let vData = vData {
                picker.addAttachmentData(vData, typeIdentifier: "video/mp4", filename: "video.mp4")
            }
        } else {
            let image = image
            let imageData = imageToShare?.jpegData(compressionQuality: 1.0)
            if let imageData = imageData {
                picker.addAttachmentData(imageData, typeIdentifier: "img/jpeg", filename: "image.jpg")
            }
        }*/
        let image = UIImage(contentsOfFile: self.imgUrl!.path)!
        let imageData = image.jpegData(compressionQuality: 1.0)
        if let imageData = imageData {
            picker.addAttachmentData(imageData, typeIdentifier: "img/jpeg", filename: "image.jpg")
        }
        present(picker, animated: true)
    }
    
    //MARK: -  MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Swift.Error?) {
        
        if let _ = error {
            //Show error alert
            controller.dismiss(animated: true)
            return
        }
        switch result {
        case .cancelled:
            print("Cancelled")
        case .failed:
            print("Failed to send")
        case .saved:
            print("Saved")
        case .sent:
            print("Email Sent")
        @unknown default:
            break
        }
        controller.dismiss(animated: true)
    }
    
    //MARK: - MFMessageComposeViewControllerDelegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            break
        case .failed:
            break
        case .sent:
            break
        default:
            print("Something wrong")
        }
        controller.dismiss(animated: true, completion: nil)
    }
}



