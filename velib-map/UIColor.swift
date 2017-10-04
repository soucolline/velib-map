//
//  UIColor.swift
//  swiftUV
//
//  Created by Thomas Guilleminot on 15/03/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  public class func fromInteger(red: Int, green: Int, blue: Int) -> UIColor {
    return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
  }
  
  public final class func colorFromIntegerWithAlpha(color: UInt32) -> UIColor {
    let r: UInt8 = UInt8(color >> 24)
    let g: UInt8 = UInt8((color << 8) >> 24)
    let b: UInt8 = UInt8((color << 16) >> 24)
    let a: UInt8 = UInt8((color << 24) >> 24)
    
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a))
  }
  
  public final class func colorFromInteger(color: UInt32) -> UIColor {
    return UIColor.colorFromIntegerWithAlpha(color: (color << 8) + 255)
  }
}
