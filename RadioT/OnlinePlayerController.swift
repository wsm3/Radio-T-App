//
//  OnlinePlayerController.swift
//  RadioT
//
//  Created by Den on 28.06.17.
//  Copyright © 2017 Den. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


class OnlinePlayerController: UIViewController {
    @IBOutlet weak var playOnline: UIImageView!
    var player : AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(hexString: "#3d6575")
        
        
        
        let infoLabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 10, y: 50, width: self.view.frame.width - 10, height: 150))
            label.numberOfLines = 0
            label.text = "Online вещание\nЗапись подкаста производится по субботам, в 23:00мск."
            label.font = UIFont(name: "OpenSans-Semibold", size: 17.0)
            label.textColor = .white
            label.textAlignment = .center
            label.sizeToFit()
            return label
        }()
        
        self.view.addSubview(infoLabel)
        
        
        let audioURL = URL(string: "http://stream.radio-t.com")
        player = AVPlayer(url: audioURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player?.prepareForInterfaceBuilder()
        //player?.play()
       
       
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.playStopBtTab(tapGestureRecognizer:)))
        self.playOnline.isUserInteractionEnabled = true
        self.playOnline.addGestureRecognizer(tapGestureRecognizer)
        
        
        
        var cl: UIButton = {
            var button = UIButton(frame: CGRect(x: self.view.frame.width - 30, y: 20, width: 25, height: 25))
            button.setImage(UIImage(named: "close_blue"), for: UIControlState.normal)
            button.addTarget(self, action: #selector(closeController), for: UIControlEvents.touchUpInside)
            // button.layer.zPosition = 1
            return button
        }()
        
        
        self.view.addSubview(cl)
        
        
    }
    
    
    func playStopBtTab(tapGestureRecognizer: UITapGestureRecognizer)  {
        if (self.player?.isPlaying)! {
            self.playOnline.image = (UIImage(named: "play"))
            self.player?.pause()
            return
        }
        self.playOnline.image = (UIImage(named: "pause"))
        self.player?.play()
        
        
    }
    
    
    func closeController()  {
        print("disss")
        self.dismiss(animated:true)
    }
    
    
    
}




    
    





