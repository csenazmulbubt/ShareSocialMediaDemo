//
//  ShareView.swift
//  ShareSocialMediaDemo
//
//  Created by Nazmul on 29/05/2022.
//

import UIKit
import Foundation
import AVFoundation
import AVKit

protocol ShareViewDelegate: AnyObject {
    func selectedShareOption(shareOption: shareOptionType)
    func instagramShareBtnClickd()
}

class ShareView: UIView{
    
    @IBOutlet var mainContainerView: UIView!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var contentContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentContainerViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var playerView: ICPlaybackView!
    
    @IBOutlet weak var playPauseBtn: UIButton!
    
    @IBOutlet weak var instagramContainerView: UIView!
    @IBOutlet weak var shareOptionCollectionView: UICollectionView!
    
    weak var delegate: ShareViewDelegate?
    var isFirst = false
    let shareOptions = shareOptionType.allCases
    var shareUrl: URL?
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isFirst {
            isFirst = true
            self.layoutIfNeeded()
            if let url = shareUrl {
                let size = self.getVideoORImageSizeBasedOnUrl(url: url)
                let rect = AVMakeRect(aspectRatio: size, insideRect: topView.bounds)
                contentContainerViewWidthConstraint.constant = rect.width
                contentContainerViewHeightConstraint.constant = rect.height
                contentContainerView.backgroundColor = UIColor.blue
                self.layoutIfNeeded()
            }
        }
    }
    
    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("ShareView", owner: self, options: nil)
        self.mainContainerView.frame = self.bounds
        self.mainContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.initialSetup()
        self.addSubview(self.mainContainerView)
    }
    
    func initialSetup() -> Void {
        self.instagramContainerView.layer.cornerRadius = 8
        self.registerCollectionViewCell()
        self.setCollectionViewFlowLayout()
    }
    
    //MARK: Registration nib file and Set Delegate, Datasource
    fileprivate func registerCollectionViewCell(){
        self.shareOptionCollectionView.delegate = self
        self.shareOptionCollectionView.dataSource = self
        let menuNib = UINib(nibName: ShareCollectionViewCell.id, bundle: nil)
        self.shareOptionCollectionView.register(menuNib, forCellWithReuseIdentifier: ShareCollectionViewCell.id)
    }
    
    fileprivate func setCollectionViewFlowLayout(){
        
        if let layoutMenu1 = self.shareOptionCollectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            layoutMenu1.scrollDirection = .horizontal
            layoutMenu1.minimumLineSpacing = 8
            layoutMenu1.minimumInteritemSpacing = 8
        }
        self.shareOptionCollectionView.contentInset = UIEdgeInsets.zero //UIEdgeInsets(top: 0, left: 16, bottom: 2.5, right: 16)
    }
    
    //MARK: - tappedOnInstagramButton
    @IBAction func tappedOnInstagramButton(_ sender: UIButton) {
        delegate?.instagramShareBtnClickd()
    }
    
    // playPauseBtnAction
    @IBAction func playPauseBtnAction(_ sender: UIButton) {
        
    }
}

//MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension ShareView: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shareOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShareCollectionViewCell.id, for: indexPath) as! ShareCollectionViewCell
        cell.shareIconImageView.image = UIImage(named: self.shareOptions[indexPath.item].info.imageName)
        cell.shareNameLabel.text = self.shareOptions[indexPath.item].info.description
        return cell
    }
    
    // UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.selectedShareOption(shareOption: self.shareOptions[indexPath.item])
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension ShareView: UICollectionViewDelegateFlowLayout{
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.bounds.size.width - 24)/4.5
        return CGSize(width: width, height: collectionView.bounds.height)
    }
}

//MARK: - setupContentView
extension ShareView{
    
    private func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
       let size = track.naturalSize.applying(track.preferredTransform)
       return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    func getVideoORImageSizeBasedOnUrl(url: URL) -> CGSize {
        
        let fileextension = url.fileExtension
        switch fileextension.lowercased(){
        case "mp4","mov":
            self.setUpPlayer(videoUrl: url)
            return resolutionForLocalVideo(url: url)!
        default:
            let image = UIImage(contentsOfFile: url.path)!
            self.setupImageView(image: image)
            return image.size
        }
    }
    
    func setupImageView(image: UIImage) -> Void {
        self.playerView.isHidden = true
        self.playPauseBtn.isHidden = true
        self.imageView.image = image
    }
    
    func setUpPlayer(videoUrl: URL) -> Void {
        self.playVideoWithURL(videoUrl)
    }
    
    func playVideoWithURL(_ videoURL: URL) -> Void{
        let videoAsset = AVAsset(url: videoURL)
        playerItem = AVPlayerItem.init(asset: videoAsset)
        player = AVPlayer.init(playerItem: self.playerItem)
        player?.replaceCurrentItem(with: self.playerItem)
        player?.volume = 1.0
        playerView.setPlayer(self.player)
        playerView.setVideoFillMode(AVLayerVideoGravity.resizeAspectFill.rawValue)
        player?.play()
    }
}


