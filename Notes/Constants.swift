//
//  Constants.swift
//  Notes
//
//  Created by Pallav Trivedi on 23/08/16.
//  Copyright © 2016 CodeIt. All rights reserved.
//

import Foundation
import UIKit

func colorFromHexString(hexString:String) -> UIColor {
    var rgbValue  = UInt32.min
    let scanner = NSScanner (string: hexString)
    scanner.scanLocation = 1
    scanner.scanHexInt(&rgbValue)
    return UIColor (red: CGFloat((rgbValue & 0xFF0000) >> 16)/255.0, green: CGFloat((rgbValue & 0xFF00) >> 8)/255.0, blue: CGFloat(rgbValue & 0xFF)/255.0, alpha: 1.0)
}
