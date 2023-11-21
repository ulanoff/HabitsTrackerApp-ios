//
//  UIImage+ext.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 21.11.2023.
//

import UIKit

extension UIImage {
    static func gradientImage(bounds: CGRect, colors: [UIColor]) -> UIImage {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = bounds
            gradientLayer.colors = colors.map(\.cgColor)

            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

            let renderer = UIGraphicsImageRenderer(bounds: bounds)

            return renderer.image { ctx in
                gradientLayer.render(in: ctx.cgContext)
            }
        }
}
