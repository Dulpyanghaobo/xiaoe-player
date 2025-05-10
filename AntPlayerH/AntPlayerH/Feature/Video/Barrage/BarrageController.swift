//
//  BarrageController.swift
//  AntPlayerH
//
//  Created by i564407 on 7/31/24.
//

import UIKit
import BarrageRenderer

class BarrageController: UIViewController, BarrageRendererDelegate {
    var isStop: Bool = false
    var renderer: BarrageRenderer!
    var defaultColor: UIColor?
    var timer: Timer?
    var index: Int = 0
    var bulletComments = [DanmakuResponse]() // 数据源

    override func viewDidLoad() {
        super.viewDidLoad()
        initBarrageRenderer()
    }
    
    private func initBarrageRenderer() {
        renderer = BarrageRenderer()
        renderer.smoothness = 0.2
        renderer.delegate = self
        view.addSubview(renderer.view)
        renderer.canvasMargin = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        renderer.view.isUserInteractionEnabled = true
        view.sendSubviewToBack(renderer.view)
        startBarrage()
    }
    
    func startBarrage() {
        isStop = false
        renderer.start()
        startMockingBarrageMessage()
    }
    
    func stopBarrage() {
        isStop = true
        renderer.stop()
        stopMockingBarrageMessage()
    }
    
    func pauseBarrage() {
        
        renderer.pause()
    }
    
    func resumeBarrage() {
        renderer.start()
    }
    
    private func startMockingBarrageMessage() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(autoSendBarrage), userInfo: nil, repeats: true)
    }
    
    private func stopMockingBarrageMessage() {
        timer?.invalidate()
    }
    
    @objc private func autoSendBarrage() {
        let spriteNumber = renderer.spritesNumber(withName: nil)
        if spriteNumber <= 500 {
            sendBulletComments()
        }
    }
    
    func sendBulletComments() {
        if index < bulletComments.count {
            let comment = bulletComments[index]
            let descriptor = bulletCommentDescriptor(withComment: comment)
            renderer.receive(descriptor)
            index += 1
        } else {
            index = 0
        }
    }
    
    private func bulletCommentDescriptor(withComment comment: DanmakuResponse) -> BarrageDescriptor {
        let descriptor = BarrageDescriptor()
        descriptor.spriteName = NSStringFromClass(BarrageWalkTextSprite.self)
        descriptor.params["text"] = comment.content
        descriptor.params["textColor"] = UIColor.init(hex: comment.fontColor ?? "#666666")
        descriptor.params["speed"] = 100 * Double.random(in: 0...1) + 50
        descriptor.params["direction"] = BarrageWalkDirection.R2L.rawValue
        descriptor.params["clickAction"] = {
        }
        return descriptor
    }
    

    
    func barrageRenderer(_ renderer: BarrageRenderer!, spriteStage stage: BarrageSpriteStage, spriteParams params: [AnyHashable : Any]!) {
        let subid = (params["identifier"] as! String).prefix(8)
        if stage == .begin {
//            print("id:\(subid),bizMsgId:\(params["bizMsgId"]!) => entered")
        } else if stage == .end {
//            print("id:\(subid),bizMsgId:\(params["bizMsgId"]!) => left")
        }
    }
}
