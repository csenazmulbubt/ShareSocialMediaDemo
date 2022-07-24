//
//  ShareOptionEnum.swift
//  ShareSocialMediaDemo
//
//  Created by Nazmul on 24/06/2022.
//

import Foundation
import UIKit

enum shareOptionType: CaseIterable {
    case saved
    case instagramStory
    case fb
    case fbStory
    case messenger
    case sms
    case emial
    case more

    var info: (imageName: String, description: String) {
        switch self {
        case .instagramStory:
            print("SOMETHING WRONG")
            return ("insta_story", "Insta-Story")
        case .saved:
            return ("save", "Saved")
        case .fb:
            return ("facebook", "Facebook")
        case .messenger:
            return ("messenger", "Messenger")
        case .more:
            return ("more", "More")
        case .sms:
            return ("sms", "Sms")
        case .emial:
            return ("email", "E-Mail")
        case .fbStory:
            return ("fb_story", "Fb-Story")
        }
    }
}
