//
//  UIView+ext.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 13.10.2023.
//

import UIKit

typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)

enum GradientOrientation {
  case topRightBottomLeft
  case topLeftBottomRight
  case horizontal
  case vertical

  var startPoint: CGPoint {
    return points.startPoint
  }

  var endPoint: CGPoint {
    return points.endPoint
  }

  var points: GradientPoints {
    switch self {
    case .topRightBottomLeft:
      return (CGPoint(x: 0.0, y: 1.0), CGPoint(x: 1.0, y: 0.0))
    case .topLeftBottomRight:
      return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 1.0, y: 1.0))
    case .horizontal:
      return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 1.0, y: 0.0))
    case .vertical:
      return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.0, y: 1.0))
    }
  }
}

extension UIView {
    func hide() {
        isHidden = true
    }
    
    func show() {
        isHidden = false
    }
    
    func addGradientBorder(colors: [UIColor], orientation: GradientOrientation, width: CGFloat, cornerRadius: CGFloat) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = orientation.startPoint
        gradientLayer.endPoint = orientation.endPoint
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = width
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        layer.addSublayer(gradientLayer)
    }
}
