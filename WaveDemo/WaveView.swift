//
//  WaveView.swift
//  WaveDemo
//
//  Created by 邱云翔 on 2019/8/12.
//  Copyright © 2019 邱云翔. All rights reserved.
//

import UIKit

class WaveView: UIView,WaveCalculateProtocol {
    
    var startAnimationTimer: Timer?
    
    var stopAnimationTimer: Timer?
    
    
    var waveConfiguration: WaveCalculateConfiguration = WaveCalculateConfiguration.init()
    var layerArray : Array<CAShapeLayer> = Array()
    var backLayer : CAShapeLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        //
        waveConfiguration.waveCenter = CGPoint.init(x: self.bounds.size.width / 2, y: self.bounds.size.width / 2)
        waveConfiguration.waveCount = 4
        waveConfiguration.startRadius = 0.0
        waveConfiguration.endRadius = 80.0
        waveConfiguration.intervalTime = 3
        
//        let colorArray = [UIColor.init(red: 146.0 / 255, green: 231.0 / 255, blue: 174.0 / 255, alpha: 1).cgColor,UIColor.init(red: 131.0 / 255, green: 213.0 / 255, blue: 180.0 / 255, alpha: 1).cgColor,UIColor.init(red: 118.0 / 255, green: 194.0 / 255, blue: 200.0 / 255, alpha: 1).cgColor,UIColor.init(red: 101.0 / 255, green: 174.0 / 255, blue: 217.0 / 255, alpha: 1).cgColor] as Array<CGColor>
        let colorArray = [UIColor.red.cgColor,UIColor.yellow.cgColor,UIColor.blue.cgColor,UIColor.green.cgColor]
        
        for i in 0...3 {
            let layer = CAShapeLayer.init()
            layer.fillColor = colorArray[i]
            layerArray.append(layer)
            self.layer.addSublayer(layer)
        }
        let path = UIBezierPath.init(arcCenter: waveConfiguration.waveCenter, radius: 80, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        backLayer = CAShapeLayer.init()
        backLayer?.path = path.cgPath
        backLayer?.fillColor = UIColor.clear.cgColor
        self.layer.insertSublayer(backLayer!, at: 0)
        
        self.startAnimation()
        
    }
    
    func detailViews() {
        if waveConfiguration.currentMaxIndex != -1 {
            CATransaction.setDisableActions(true)
            self.backLayer?.fillColor = layerArray[waveConfiguration.currentMaxIndex].fillColor
            CATransaction.commit()
        }
        
        for i in 0...3 {
            let path = UIBezierPath.init(arcCenter: waveConfiguration.waveCenter, radius: CGFloat(waveConfiguration.valueArray[i]), startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
            layerArray[i].path = path.cgPath
        }
        
        //把path最小的layer放到最前面
        //
        var tempArray = waveConfiguration.valueArray
        tempArray.sort { (a, b) -> Bool in
            return a <= b //降序
        }
        
        //
        if waveConfiguration.maxStopIndex != -1 {
            //从最大位置开始做停止
            for i in 0...waveConfiguration.valueArray.count - 1 {
                if tempArray[i] < waveConfiguration.endRadius {
                    let index = waveConfiguration.valueArray.firstIndex(of: tempArray[i])
                    self.layer.insertSublayer(layerArray[index!], at: 1);
                }
            }
            
            for i in (0 ..< waveConfiguration.maxStopIndex).reversed() {
                if waveConfiguration.valueArray[i] >= waveConfiguration.endRadius {
                    self.layer.insertSublayer(layerArray[i], at: 1);
                }
            }
            
            for i in (waveConfiguration.maxStopIndex ..< waveConfiguration.valueArray.count).reversed() {
                if waveConfiguration.valueArray[i] >= waveConfiguration.endRadius {
                    self.layer.insertSublayer(layerArray[i], at: 1);
                }
            }
            
        } else {
            for i in 0...waveConfiguration.valueArray.count - 1 {
                let index = waveConfiguration.valueArray.firstIndex(of: tempArray[i])
                self.layer.insertSublayer(layerArray[index!], at: 1);
            }
        }
    }

}
