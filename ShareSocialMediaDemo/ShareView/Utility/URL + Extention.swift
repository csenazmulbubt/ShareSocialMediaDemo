//
//  URL + Extention.swift
//  ShareSocialMediaDemo
//
//  Created by Nazmul on 26/06/2022.
//

import Foundation
import UIKit

extension URL {
   var fileName: String {
       self.deletingPathExtension().lastPathComponent
   }

   var fileExtension: String{
       self.pathExtension
   }
}
