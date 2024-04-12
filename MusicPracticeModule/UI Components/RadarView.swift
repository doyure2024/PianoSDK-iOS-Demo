//
//  RadarView.swift
//  MusicPracticeModule
//
//  Created by Race Li on 2021/7/20.
//

import UIKit

class RadarView: UIView {
    
    // Data
    private var data: [RadarModel]!
    // Number of edges
    private var side: Int!
    // Line layer
    private var shapeLayer: CAShapeLayer!
    // Region layer
    private var reginLayer: CAShapeLayer!
    // Text layer
    private var textShapeLayer: CAShapeLayer!
    // Solid dots at the vertices
    private var dotsShapeLayer: CAShapeLayer!
    // Text font
    private var font: UIFont!
    // Line color
    private var lineColor: UIColor!
    // Text color
    private var titleTextColor: CGColor!
    // Line width
    private var lineWidth: CGFloat!
    // Color of the drawing area
    private var drawAreaColor: UIColor!
    private var dotRadius: CGFloat!
    private var dotColor: UIColor!
    
    // View width, height
    private var width: CGFloat!
    // Center point
    private var centerX: CGFloat!
    private var centerY: CGFloat!
    // Radial radius
    private var radius: CGFloat!
    
    // Coordinates of the vertices of the octagon
    private var nightNodeArray: [CGPoint]!
    // Gap, fine-tuning
    private var space: CGFloat = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initData(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - private methods
private extension RadarView {
    
    /// Initialize data
    ///
    /// - Parameter frame: frame
    func initData(frame: CGRect) {
        width = min(frame.size.width, frame.size.height)
        centerX = frame.size.width / 2
        centerY = frame.size.height / 2
        radius = width / 2 * 0.7
        font = UIFont.systemFont(ofSize: 14)
        lineWidth = 1
        dotRadius = 5
        nightNodeArray = [CGPoint]()
        
        let angle: CGFloat = CGFloat(Double.pi * 2 / Double(8))
        
        for node in 0..<8 {
            let x: CGFloat = radius * sin(angle / 2 + angle * CGFloat(node)) + centerX
            let y: CGFloat = radius * cos(angle / 2 + angle * CGFloat(node)) + centerY
//            print("\(node)  x: \(x), y: \(y)")
            nightNodeArray.append(CGPoint(x: x, y: y))
        }
        
        titleTextColor = UIColor.black.cgColor
        lineColor = UIColor.black
        drawAreaColor = UIColor.init(red: 1, green: 0, blue: 0, alpha: 0.2)
        dotColor = drawAreaColor
    }
    
    /// Update UI
    func updateLayer() {
        //        if data.count == 0 {
        //            return
        //        }
        // Drawn Path Path
        let path = CGMutablePath()
        // Spacing between mesh radii
        let radiuSpace: CGFloat = radius / CGFloat((side - 1))
        // Angle
        let angle: CGFloat = CGFloat(Double.pi * 2 / Double(side))
        let centerPoint = CGPoint(x: centerX, y: centerY)
        
        for ring in 0..<side {
            let currentRadius: CGFloat = CGFloat(ring) * radiuSpace
            var array = [CGPoint]()
            for node in 0..<side {
                let x: CGFloat = currentRadius * CGFloat(sin(angle / 2 + angle * CGFloat(node))) + centerX
                let y: CGFloat = currentRadius * CGFloat(cos(angle / 2 + angle * CGFloat(node))) + centerY
                let currentPoint = CGPoint(x: x, y: y)
                array.append(currentPoint)
                path.addLines(between: [currentPoint, centerPoint])
            }
            array.append(array[0])
            path.addLines(between: array)
        }
        
        let percentPath = CGMutablePath()
        var array = [CGPoint]()
        for node in 0..<side {
            let x: CGFloat = radius * sin(angle / 2 + angle * CGFloat(node)) * data[node].percent + centerX
            let y: CGFloat = radius * cos(angle / 2 + angle * CGFloat(node)) * data[node].percent + centerY
            array.append(CGPoint(x: x, y: y))
        }
        percentPath.addLines(between: array)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.35)
        if shapeLayer == nil {
            shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.backgroundColor = UIColor.clear.cgColor
            shapeLayer.path = path
            shapeLayer.lineWidth = lineWidth
            shapeLayer.strokeColor = lineColor.cgColor
            shapeLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            layer.insertSublayer(shapeLayer, at: 0)
        } else {
            shapeLayer.path = path
        }
        
        if reginLayer == nil {
            reginLayer = CAShapeLayer()
            reginLayer.fillColor = drawAreaColor.cgColor
            reginLayer.backgroundColor = UIColor.clear.cgColor
            reginLayer.path = percentPath
            reginLayer.lineWidth = lineWidth
            reginLayer.strokeColor = dotColor.cgColor
            reginLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            
            layer.insertSublayer(reginLayer, above: shapeLayer)
            
            
        } else {
            reginLayer.path = percentPath
        }
        
        if dotsShapeLayer != nil {
            dotsShapeLayer.removeFromSuperlayer()
        }
        
        dotsShapeLayer = CAShapeLayer()
        dotsShapeLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        layer.insertSublayer(dotsShapeLayer, above: reginLayer)
        
        for item in array {
            let dotLayer = CATextLayer()
            dotLayer.cornerRadius = dotRadius
            dotLayer.frame = CGRect(x: item.x - dotRadius, y: item.y - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
            dotLayer.backgroundColor = dotColor.cgColor
            dotsShapeLayer.addSublayer(dotLayer)
        }
        
        if textShapeLayer != nil {
            textShapeLayer.removeFromSuperlayer()
        }
        
        //TODO Optimization
//                if textShapeLayer == nil {
        textShapeLayer = CAShapeLayer()
        textShapeLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        layer.insertSublayer(textShapeLayer, above: reginLayer)
//                } else {
//        layer.insertSublayer(textShapeLayer, above: reginLayer)
//                }
        
        for node in 0..<side {
            let size = getViewHeight(content: data[node].title)
            var x: CGFloat = (radius + size.height * 0) * sin(angle / 2 + angle * CGFloat(node)) + centerX
            var y: CGFloat = (radius + size.height * 0) * cos(angle / 2 + angle * CGFloat(node)) + centerY
            let textLayer = CATextLayer()
            textLayer.fontSize = 14
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.alignmentMode = CATextLayerAlignmentMode.center
            textLayer.foregroundColor = titleTextColor
            textLayer.backgroundColor = UIColor.clear.cgColor
            textLayer.string = data[node].title //"\(node)\(data[node].title)"
            
            // Optimizing the distance and positioning adjustments between the font and mesh structure
            if x >= nightNodeArray[4].x && x <= nightNodeArray[3].x && y < frame.size.height / 2 {
                x = x - size.width / 2
                y = y - size.height - space
            } else if x > nightNodeArray[5].x && x < nightNodeArray[4].x &&
                y > nightNodeArray[4].y && y < nightNodeArray[5].y {
                x = x - size.width / 3 * 2
                y = y - size.height - space
            } else if y >= nightNodeArray[5].y && y <= nightNodeArray[6].y && x < frame.size.width / 2 {
                if y > frame.size.height / 2 {
                    x = x - size.width - space
                    y = y - size.height / 3
                } else {
                    x = x - size.width - space
                    y = y - size.height / 3 * 2
                }
            } else if x > nightNodeArray[6].x && x < nightNodeArray[7].x &&
                y > nightNodeArray[6].y && y < nightNodeArray[7].y {
                x = x - size.width / 2
                y = y + space
            } else if x >= nightNodeArray[7].x && x <= nightNodeArray[0].x && y > frame.size.height / 2 {
                x = x - size.width / 2
                y = y + space
            } else if x > nightNodeArray[0].x && x < nightNodeArray[1].x &&
                y > nightNodeArray[1].y && y < nightNodeArray[0].y {
                x = x - size.width / 5 * 2
                y = y + space
            } else if y >= nightNodeArray[2].y && y <= nightNodeArray[1].y && x > frame.size.width / 2 {
                x = x + space
                y = y - size.width / 3
            } else if x > nightNodeArray[3].x && x < nightNodeArray[2].x &&
                y > nightNodeArray[3].y && y < nightNodeArray[2].y {
                x = x + space
                y = y - size.height
            }
            
            textLayer.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            textShapeLayer.addSublayer(textLayer)
        }
        
        UIView.commitAnimations()
        
    }
    
    /// Getting the width and height of text
    ///
    /// - Parameter content: Text content
    /// - Returns: Text height
    func getViewHeight(content: String) -> CGRect {
        let size = content.boundingRect(with: CGSize(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return size
    }
}

//MARK: - public methods
extension RadarView {
    
    /// Set data
    ///
    /// - Parameter data: Data list
    func setData(data: [RadarModel]) {
        //        print("setData:\(data)")
        self.data = data
        self.side = self.data.count
        self.updateLayer()
    }
    
    /// Set text color
    ///
    /// - Parameter color: Color
    func setTextColor(color: UIColor) {
        if color == nil {
            return
        }
        self.titleTextColor = color.cgColor
    }
    
    /// Set text font
    ///
    /// - Parameter font: Font
    func setTextFont(font: UIFont) {
        if font == nil {
            return
        }
        self.font = font
    }
    
    /// Set line color
    ///
    /// - Parameter font: Color
    func setLineColor(color: UIColor) {
        if color == nil {
            return
        }
        self.lineColor = color
    }
    
    /// Set line width
    ///
    /// - Parameter width: Width
    func setLineWidth(width: CGFloat) {
        if width == nil {
            return
        }
        self.lineWidth = width
    }
    
    /// Set solid dot color
    ///
    /// - Parameter color: Color
    func setDotColor(color: UIColor) {
        if color == nil {
            return
        }
        self.dotColor = color
    }
    
    /// Set solid dot radius
    ///
    /// - Parameter radius: Radius
    func setDotRadius(radius: CGFloat) {
        if radius == nil {
            return
        }
        self.dotRadius = radius
    }
    
    /// Set color of the shaded area
    ///
    /// - Parameter color: Color
    func setDrawAreaColor(color: UIColor) {
        if color == nil {
            return
        }
        self.drawAreaColor = color
    }
    
    /// Manually load once
    func load() {
        self.updateLayer()
    }
    
}
