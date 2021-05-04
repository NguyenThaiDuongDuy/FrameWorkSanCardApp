//
//  CGPoint+Ext.swift
//  ScanCard
//
//  Created by admin on 14/04/2021.
//

import UIKit
extension CGPoint {
    func convertToPixelCoordinate(to size: CGSize) -> CGPoint {
        CGPoint(x: x * size.width,
                y: y * size.height)
    }
}
