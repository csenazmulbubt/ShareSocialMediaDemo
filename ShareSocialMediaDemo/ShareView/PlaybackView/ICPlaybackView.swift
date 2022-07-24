//
//  ICPlaybackView.swift
//  ShareSocialMediaDemo
//
//  Created by Nazmul on 22/06/2022.
//

import Foundation
import UIKit
import AVFoundation

class ICPlaybackView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    func setPlayer(_ player: AVPlayer?) {
        (layer as? AVPlayerLayer)?.player = player
    }
    
    func removePlayer() {
        (layer as? AVPlayerLayer)?.removeFromSuperlayer()
    }
    
    /* Specifies how the video is displayed within a player layer’s bounds.
     (AVLayerVideoGravityResizeAspect is default) */
    func setVideoFillMode(_ fillMode: String) {
        let playerLayer = layer as? AVPlayerLayer
        playerLayer?.videoGravity = AVLayerVideoGravity.init(rawValue: fillMode)
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
}
