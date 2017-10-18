//
//  OfflinePlayerConrtoller.swift
//  RadioT
//
//  Created by Den on 25.06.17.
//  Copyright © 2017 Den. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Kanna
import ActiveLabel

import MediaPlayer

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}






class OfflinePlayerConrtoller: UIViewController {
    
    open var ep_index = 0
    var player : AVPlayer?
    var playbackSlider:UISlider?
    
    @IBOutlet weak var pudDateLb: UILabel!
    
    @IBOutlet weak var numEpLb: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var controllView: UIView!
    @IBOutlet weak var playheadLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var sliderPlaybac: UISlider!
    
    
    @IBOutlet weak var bacBt: UIImageView!
    
    @IBOutlet weak var forBt: UIImageView!
    
    @IBAction func openChatLogBt(_ sender: Any) {
        self.showWEB(self.episod["ep_link"]!+"#disqus_thread")
    }
    
    
    @IBAction func openCommentBt(_ sender: Any) {
        let epn = episod["ep_title"]?.replacingOccurrences(of: "Радио-Т ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.showWEB("https://chat.radio-t.com/logs/radio-t-\(epn!).html")
    }
    
    
    let label = ActiveLabel()
    var audioSlider: UISlider? = {
        let slider = UISlider()
        slider.minimumTrackTintColor = UIColor.init(hexString: "#01bfd7")
        slider.maximumTrackTintColor = UIColor.init(hexString: "#dadddf")
        slider.setThumbImage(UIImage(named: "toggle"), for: UIControlState.normal)
        slider.addTarget(self, action: #selector(changeSlider), for: .valueChanged)
        return slider
    }()
    
    
    
    var playStopBt: UIButton = {
        var button = UIButton(frame: CGRect(x: 20, y: -35, width: 70, height: 70))
        button.setImage(UIImage(named: "pause"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(playStopBtTab), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    
    var closeControllerBt: UIButton = {
        var button = UIButton(frame: CGRect(x: 100, y: -15, width: 30, height: 30))
        button.setImage(UIImage(named: "close_c"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(closeController), for: UIControlEvents.touchUpInside)
        button.alpha = 0.8
        return button
    }()
    
    
    var closeAllBt: UIButton = {
        var button = UIButton(frame: CGRect(x: 20, y: -35, width: 70, height: 70))
        button.setImage(UIImage(named: "close"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(closeAll), for: UIControlEvents.touchUpInside)
        button.alpha = 0.0
        return button
        
    }()
    
    var subjects = [(text: String, href: String, time: String)]()
    
    var episod: Dictionary<String,String> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.episod = ManagerData.sharedManager.podcast.episodes[ep_index]
      
        
        self.numEpLb.textColor = UIColor.init(hexString: "#01bfd7§")
        self.numEpLb.text = episod["ep_title"]?.replacingOccurrences(of: "Радио-Т ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.pudDateLb.text = episod["ep_pubDate"]
        
        
        self.webView.isUserInteractionEnabled = true
        self.webView.scrollView.isScrollEnabled = true
        // self.webView.layer.zPosition = 1
        self.webView.alpha = 0.0
        
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.playBack(tapGestureRecognizer:)))
        self.bacBt.isUserInteractionEnabled = true
        self.bacBt.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(self.playForw(tapGestureRecognizer:)))
        self.forBt.isUserInteractionEnabled = true
        self.forBt.addGestureRecognizer(tapGestureRecognizer1)
        
        
        
        if let doc = HTML(html: (episod["ep_description"])!, encoding: .utf8) {
            for item in doc.xpath("//li") {
                //print(item.at_xpath("a")?["href"])
                //print(item.at_xpath("a")?.text)
                //print(item.at_xpath("em")?.text)
                //
                if let text = item.at_xpath("a")?.text {
                    self.subjects.append((
                        (item.at_xpath("a")?.text)!,
                        (item.at_xpath("a")?["href"])!,
                        (item.at_xpath("em")?.text ?? "")!
                    ))
                }
            }
            
            
            self.subjects.append((
                "Темы наших слушателей",
                "",
                ""
            ))
            
            
            
            
            for item in doc.xpath("//p/em") {
                //print(item.at_xpath("a")?["href"])
                //print(item.at_xpath("a")?.text)
                //print(item.at_xpath("em")?.text)
                //
                if let text = item.text {
                    self.subjects.append((
                        ("---\n"+text),
                        "",
                        ""
                    ))
                }
            }
            
        }
        
        
     
        
        self.closeAllBt.frame = CGRect(x: self.view.frame.width - 80, y: -25, width: 50, height: 50)
        
        
        
        
        
        let audioURL = URL(string: episod["ep_mp3_url"]!)
        player = AVPlayer(url: audioURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player?.prepareForInterfaceBuilder()
        player?.play()
        
        player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: nil, using: {
            (CMTime) -> Void in
            
            self.updateTime()
        })
        
        
        
        self.sliderPlaybac.minimumValue = Float(0.0)
        self.sliderPlaybac.maximumValue = Float(1.0)
        self.sliderPlaybac.minimumTrackTintColor = UIColor.init(hexString: "#01bfd7")
        self.sliderPlaybac.maximumTrackTintColor = UIColor.init(hexString: "#dadddf")
        self.sliderPlaybac.setThumbImage(UIImage(named: "toggle"), for: UIControlState.normal)
        
        self.webView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        
        //http://swiftdeveloperblog.com/code-examples/avplayer-add-periodic-timeobserver-to-update-music-playback-slider/
        //https://stackoverflow.com/questions/44364922/avplayer-how-to-save-the-current-recording-time
        //https://github.com/ewr/AVPlayerSeekDemo
        //https://github.com/tbaranes/AudioPlayerSwift
        
        
        
        self.view.backgroundColor = UIColor.init(hexString: "#3d6575")
        
        
        
        //  self.audioSlider?.frame = CGRect(x: self.sliderPlaybac.frame.origin.x + 20, y: self.sliderPlaybac.frame.origin.y, width: self.sliderPlaybac.frame.width, height: self.sliderPlaybac.frame.height)
        
        // self.controllView.addSubview(self.audioSlider!)
        
        
        self.sliderPlaybac?.addTarget(self, action: #selector(changeSlider), for: .valueChanged)
        
        
        self.sliderPlaybac.alpha = 1
        
        self.controllView.addSubview(playStopBt)
        self.controllView.addSubview(closeAllBt)
        self.controllView.addSubview(closeControllerBt)
        
        
        
        self.label.urlMaximumLength = 20
        
        self.label.customize { label in
            label.text = ""
            for s in self.subjects {
                if s.time.isEmpty {
                    label.text = label.text! + "\(s.text)\n\(s.href)\n"
                } else {
                    label.text = label.text! + "\(s.text)\n#\(s.time.replacingOccurrences(of: ":", with: "_"))\n\(s.href)\n\n"
                }
                
                
            }
            
            label.text = label.text! + "\n\n\n\n\n\n\n\n"
            label.numberOfLines = 0
            label.lineSpacing = 4
            
            
            label.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
            label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
            label.mentionColor = UIColor(red: 238.0/255, green: 85.0/255, blue: 96.0/255, alpha: 1)
            label.URLColor = UIColor.init(hexString: "#01bfd7")
            label.URLSelectedColor = UIColor(red: 82.0/255, green: 190.0/255, blue: 41.0/255, alpha: 1)
            label.hashtagSelectedColor = UIColor(red: 82.0/255, green: 190.0/255, blue: 41.0/255, alpha: 1)
            
            label.handleMentionTap { self.alert("Mention", message: $0) }
            label.handleHashtagTap {
                //self.alert("Hashtag", message: $0)
                
                let arr = $0.characters .split(separator: "_").map(String.init)
               
                
                let time = (Int(arr[0])! * 3600) + (Int(arr[1])! * 60) + Int(arr[2])!
                
                
                
                
                let seekTime = CMTime(value: Int64(time), timescale: 1)
                self.player?.seek(to: seekTime)
            }
            
            label.handleURLTap {
                // self.alert("URL", message: $0.absoluteString)
                
                label.alpha = 0.0
                self.showWEB($0.absoluteString)
            }
            
        }
        
        self.label.frame = CGRect(x: 10, y: 15, width: self.scrollView.frame.width - 50, height: 1000)
        self.scrollView.addSubview(self.label)
        
        self.label.font = UIFont(name: "OpenSans-Semibold", size: 15.0)
        self.label.textColor = .white
        
        
        self.scrollView.contentSize  = CGSize(width: self.view.frame.size.width, height: 1000)
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            do {
                try AVAudioSession.sharedInstance().setActive(true)
              
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
 
        
    }
    
    
    func closeController()  {
         self.player?.replaceCurrentItem(with: nil)
         self.dismiss(animated:true)
    }
    
    func playBack(tapGestureRecognizer: UITapGestureRecognizer)  {
        guard (player?.currentItem?.duration) != nil else{
            return
        }
        
        
        let seekDuration: Float64 = 30
        
        let playerCurrentTime = CMTimeGetSeconds((player?.currentTime())!)
        var newTime = playerCurrentTime - seekDuration
        
        if newTime < 0 {
            newTime = 0
        }
        let time2: CMTime = CMTimeMake(Int64(newTime * 1000 as Float64), 1000)
        player?.seek(to: time2, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        
        
    }
    
    
    func playForw(tapGestureRecognizer: UITapGestureRecognizer)  {
        guard let duration  = player?.currentItem?.duration else{
            return
        }
        
        let seekDuration: Float64 = 30
        
        let playerCurrentTime = CMTimeGetSeconds((player?.currentTime())!)
        let newTime = playerCurrentTime + seekDuration
        
        if newTime < (CMTimeGetSeconds(duration) - seekDuration) {
            
            let time2: CMTime = CMTimeMake(Int64(newTime * 1000 as Float64), 1000)
            player?.seek(to: time2, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            
        }
        
    }
    
    
    func closeAll()  {
        self.webView.alpha = 0.0
        self.closeAllBt.alpha = 0.0
        self.label.alpha = 1.0
        
        
        self.label.frame = CGRect(x: 10, y: 15, width: self.scrollView.frame.width - 50, height: 1000)
        self.webView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.scrollView.alpha = 1.0
    }
    
    func showWEB(_ url:String)  {
        let url = NSURL (string: url);
        let requestObj = NSURLRequest(url: url! as URL);
        self.webView.loadRequest(requestObj as URLRequest);
        
        self.label.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        UIView.animate(withDuration: 1.0, delay:0.1, animations: {
            
            self.webView.alpha = 1.0
            self.webView.frame = self.scrollView.frame
            self.closeAllBt.alpha = 1.0
            self.webView.isUserInteractionEnabled = true
            self.webView.scrollView.isScrollEnabled = true
            //self.scrollView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.scrollView.alpha = 0.0
            
        }, completion: { finished in
            
        })
        
        
    }
    
    func playStopBtTab()  {
        if (self.player?.isPlaying)! {
            self.playStopBt.setImage(UIImage(named: "play"), for: UIControlState.normal)
            self.player?.pause()
            return
        }
        self.playStopBt.setImage(UIImage(named: "pause"), for: UIControlState.normal)
        self.player?.play()
        
    }
    
    
    func changeSlider()  {
        if let duration = self.player?.currentItem?.duration {
            let totalSecond = CMTimeGetSeconds(duration)
            
            let value = Float64((self.sliderPlaybac?.value)!) * totalSecond
            
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            self.player?.seek(to: seekTime)
        }
    }
    
    func getHoursMinutesSecondsFrom(_ seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
        if seconds.isNaN { return (0,0,0) }
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        return (hours, minutes, seconds)
    }
    
    func alert(_ title: String, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        vc.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
    }
    
    
    
    func formatTimeFor(seconds: Double) -> String {
        let result = getHoursMinutesSecondsFrom(seconds)
        let hoursString = "\(result.hours)"
        var minutesString = "\(result.minutes)"
        if minutesString.characters.count == 1 {
            minutesString = "0\(result.minutes)"
        }
        var secondsString = "\(result.seconds)"
        if secondsString.characters.count == 1 {
            secondsString = "0\(result.seconds)"
        }
        var time = "\(hoursString):"
        if result.hours >= 1 {
            time.append("\(minutesString):\(secondsString)")
        }
        else {
            time = "\(minutesString):\(secondsString)"
        }
        return time
    }
    
    
    func updateTime() {
        // Access current item
        if let currentItem = player?.currentItem {
            // Get the current time in seconds
            let playhead = currentItem.currentTime().seconds
            let duration = currentItem.duration.seconds
            // Format seconds for human readable string
            
            // self.sliderPlaybac?.value = Float((self.sliderPlaybac?.value)!) + Float(0.001)
            
          
            
            self.sliderPlaybac?.value = Float(playhead / 10000)
            
            playheadLabel.text = formatTimeFor(seconds: playhead)
            durationLabel.text = formatTimeFor(seconds: duration)
        }
    }
    
    
    
    
}






