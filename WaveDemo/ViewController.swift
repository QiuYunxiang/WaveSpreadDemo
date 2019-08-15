//
//  ViewController.swift
//  WaveDemo
//
//  Created by 邱云翔 on 2019/8/12.
//  Copyright © 2019 邱云翔. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var ttt : UIView?
    var lay : CAShapeLayer?
    var vv : WaveView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        vv = WaveView.init(frame: CGRect.init(x: 200, y: 200, width: 100, height: 100))
        self.view.addSubview(vv!)

        let bt = UIButton.init(type: UIButton.ButtonType.custom)
        bt.frame = CGRect.init(x: 200, y: 400, width: 100, height: 100)
        bt.backgroundColor = UIColor.red
        bt.addTarget(self, action: #selector(stopAnimation), for: UIControl.Event.touchUpInside)
        self.view.addSubview(bt)
        
        // Do any additional setup after loading the view.
    }
    
    
    @objc func stopAnimation() {
        self.vv?.stopAnimation(complete: {[weak self] (complete) in
            if complete == true {
                print("完成")
                self!.vv?.removeFromSuperview()
            }
        })
        
    }
}

