//
//  WaveProtocol.swift
//  WaveDemo
//
//  Created by 邱云翔 on 2019/8/12.
//  Copyright © 2019 邱云翔. All rights reserved.
//

import UIKit

struct WaveCalculateConfiguration {
    var intervalTime : Float //完整的一个波浪所需要的时间
    var waveCenter : CGPoint //波浪中心
    var startRadius : Float //起始半径
    var endRadius : Float //结束半径
    var cumulationRadius : Float  //不断变化的半径
    var intervalRadius : Float //每个帧率需要变动的值
    var waveCount : UInt //同时存在波浪最多的个数
    var valueArray : Array<Float> //视图中需要使用的数据
    var criticalArray : Array<Float> //临界值数组
    var currentMaxIndex : Int //当前达到最大的视图下标
    var maxStopIndex : Int //停止时最大的下标
    var fps : Float //fps
    
    //配置默认值
    init(intervalTime : Float = 1,waveCenter : CGPoint = CGPoint.init(x: 0, y: 0),startRadius : Float = 0.0,endRadius : Float = 0.0,cumulationRadius : Float = 0.0,intervalRadius : Float = 0.0,waveCount : UInt = 1,valueArray : Array<Float> = Array<Float>(),criticalArray : Array<Float> = Array(),currentMaxIndex : Int = -1,maxStopIndex : Int = -1,fps : Float = 60) {
        self.intervalTime = intervalTime
        self.waveCenter = waveCenter
        self.startRadius = startRadius
        self.endRadius = endRadius
        self.cumulationRadius = cumulationRadius
        self.intervalRadius = intervalRadius
        self.waveCount = waveCount
        self.valueArray = valueArray
        self.criticalArray = criticalArray
        self.currentMaxIndex = currentMaxIndex
        self.maxStopIndex = maxStopIndex
        self.fps = fps
    }
}

//波纹计算协议
protocol WaveCalculateProtocol where Self : UIView {
    var waveConfiguration : WaveCalculateConfiguration {get set} //波浪参数配置
    var startAnimationTimer : Timer? {get set}
    var stopAnimationTimer : Timer? {get set}
    
    //处理视图
    func detailViews()
}

extension WaveCalculateProtocol {
    
    //初始化 && 重置 数据
    func resetData() {
        waveConfiguration.valueArray.removeAll()
        waveConfiguration.criticalArray.removeAll()
        waveConfiguration.currentMaxIndex = -1
        waveConfiguration.maxStopIndex = -1
    }
    
    //开始动画
    func startAnimation() {
        if waveConfiguration.waveCount <= 0 {
            return
        }
        //处理参数
        let radiusOffset = waveConfiguration.endRadius - waveConfiguration.startRadius
        waveConfiguration.intervalRadius = radiusOffset / waveConfiguration.intervalTime / waveConfiguration.fps
        waveConfiguration.cumulationRadius = waveConfiguration.startRadius
        
        //临界值处理
        let waveInterval = radiusOffset / Float(waveConfiguration.waveCount)
        for i in 0..<waveConfiguration.waveCount {
            waveConfiguration.valueArray.append(waveConfiguration.startRadius)
            waveConfiguration.criticalArray.append(waveInterval * Float(i) + waveConfiguration.startRadius)
        }
        startAnimationTimer = Timer.init(timeInterval: TimeInterval(1.0/Float(waveConfiguration.fps)), repeats: true, block: {[weak self] (timer) in
            self?.computingRadius(type: true,complete: nil)
        })
        RunLoop.current.add(startAnimationTimer!, forMode: RunLoop.Mode.common)
    }
    
    //结束动画
    func stopAnimation(complete:((_ : Bool) -> Void)!) {
        if waveConfiguration.waveCount <= 0 || startAnimationTimer == nil || stopAnimationTimer != nil {
            return
        }
        //获取此时应该有的排序规则
        let maxValue = waveConfiguration.valueArray.max()
        //从当前位置逐步放大
        waveConfiguration.maxStopIndex = waveConfiguration.valueArray.firstIndex(of: maxValue!)!
        
        //
        if startAnimationTimer != nil {
            startAnimationTimer?.invalidate()
        }
        if stopAnimationTimer != nil {
            stopAnimationTimer?.invalidate()
        }
        //
        stopAnimationTimer = Timer.init(timeInterval: TimeInterval(1.0/Float(waveConfiguration.fps)), repeats: true, block: {[weak self] (timer) in
            self?.computingRadius(type: false,complete: complete)
        })
        RunLoop.current.add(stopAnimationTimer!, forMode: RunLoop.Mode.common)
    }
    
    //计算半径变化
    func computingRadius(type:Bool,complete:((_ : Bool) -> Void)?) {
        if waveConfiguration.cumulationRadius <= waveConfiguration.endRadius {
            waveConfiguration.cumulationRadius += waveConfiguration.intervalRadius
        }
        for i in 0..<waveConfiguration.valueArray.count {
            if waveConfiguration.valueArray[i] >= waveConfiguration.endRadius {
                //清0
                waveConfiguration.currentMaxIndex = i
                if type == true {
                    waveConfiguration.valueArray[i] = waveConfiguration.startRadius
                } else {
                    waveConfiguration.valueArray[i] = waveConfiguration.endRadius
                }
            }
            
            //处理各个值开始的临界
            if waveConfiguration.cumulationRadius >= waveConfiguration.criticalArray[i] {
                waveConfiguration.valueArray[i] += waveConfiguration.intervalRadius
            }
        }
        
        if waveConfiguration.cumulationRadius > waveConfiguration.endRadius {
            //重置
            waveConfiguration.cumulationRadius = waveConfiguration.endRadius
        }
        
        //处理停止时的计算问题
        if  type == false {
            var valueMax = true
            for value in waveConfiguration.valueArray {
                if value < waveConfiguration.endRadius {
                    valueMax = false
                }
            }
            if valueMax == true && complete != nil {
                complete!(true)
                if stopAnimationTimer != nil {
                    stopAnimationTimer!.invalidate()
                }
                return
            }
        }
        self.detailViews()
    }
}
