//
//  AVPlayer + IsPlaying.swift
//  ShareSocialMediaDemo
//
//  Created by Nazmul on 22/06/2022.
//

import Foundation
import AVFoundation

extension AVPlayer {

    var isPlaying: Bool {
        return self.rate != 0 && self.error == nil
    }
}
