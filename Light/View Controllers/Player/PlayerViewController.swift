//
//  PlayerViewController.swift
//  Light
//
//  Created by apple on 08/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit
import MTCircularSlider
import AVFoundation
import AVKit

let videoContaxtObserver: UnsafeMutableRawPointer = UnsafeMutableRawPointer(bitPattern: 1)!

class PlayerViewController: CustomNavBar {
    let playerObserverKey = "currentItem.loadedTimeRanges"
    var timeObserver:Any?
    var isInitializePlayer = true
    
    @IBOutlet weak var progressContainerView: MTCircularSlider!
    @IBOutlet weak var sessionTitleLabel:UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var autherNameLabel: UILabel!
    @IBOutlet weak var sessionDescriptionTv: UITextView!
    
    @IBOutlet weak var audioControls: UIStackView!
    @IBOutlet weak var videoControls: UIView!
    
    @IBOutlet var timeLabel:UILabel!
    @IBOutlet var audioTimeLabel:UILabel!
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    @IBOutlet var videoSlider: UISlider!
    
    @IBOutlet var videoPlayPauseButton: UIButton!
    @IBOutlet var audioPlayPauseButton:UIButton!
    
    var durationInSeconds = 0.0
    var currentTimedurationInSeconds = 0.0
    
    var player : Player = Player()
    var playerController:AVPlayerViewController!
    var videoPlayer: AVPlayer?
    var videoPlayerItem:AVPlayerItem?
    var slider : MTCircularSlider?
    var maxTime: CGFloat = 90
    var currentTime: CGFloat = 0
    var selectedCategory:DailySessionModel?
    var isExpandVideoView = false
    var condition = ""
    
    var isPayerPaused = ""
    
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        sessionTitleLabel.text = selectedCategory?.sessionName ?? ""
        autherNameLabel.text = selectedCategory?.sessionAuthor?.authorName ?? ""
        sessionDescriptionTv.text = selectedCategory?.sessionDescription ?? ""
        
        ServiceHelper.shared.currentButtonState = ""
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("Setting Shut Down"), object: nil)
        NotificationCenter.default.addObserver(forName: Notification.Name("Setting Shut Down"), object: nil, queue: nil) {[weak self] (notification ) in
            //  if let time  = ServiceHelper.shared.currentVideoTime{
            
            self?.condition = "ComingFormSetting"
            
            if  ServiceHelper.shared.currentButtonState == "play"{
                
                self?.videoPlayer?.pause()
            }else {
                
                self?.videoPlayer?.play()
                
            }
            
          
            
            //self?.videoPlayer?.seek(to: time)
            // }
            
        }
        
        
        if isInitializePlayer == true {
            self.timeLabel.text = "00:00/00:00"
            self.audioTimeLabel.text = "00:00"
            self.videoSlider.value = 0
            do {
                try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                try? AVAudioSession.sharedInstance().setActive(true)
            }
            
            if selectedCategory?.sessionType == 2 {
                
                self.setUpProgressView()
                progressContainerView.valueMaximum = 1.0
                progressContainerView.valueMinimum = 0.0
            } else {
                
                self.setVideoView()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if condition == "ComingFormSetting"{
            
            if audioPlayPauseButton.currentImage == UIImage(named: "icn_play_black"){
                
                audioPlayPauseButton.setImage(UIImage(named: "icn_play_black"), for: .normal)
                
            }else {
                
                // audioPlayPauseButton.setImage(UIImage(named: "icn_pause_black"), for: .selected)
            }
            
            if #available(iOS 12.0, *) {
            self.navigationController?.navigationBar.barTintColor = UIColor.bgColor
            }
            
            
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        print("viewDidAppear")
        if #available(iOS 12.0, *) {
            self.navigationController?.navigationBar.barTintColor = UIColor.bgColor
            }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        videoPlayer?.pause()
        
        print("viewWillDisappear")
        
    }
    
    deinit {
        
        print("denit called ")
        //                if isExpandVideoView == false {
        //                    if let observer = timeObserver {
        //
        //                        videoPlayer?.removeTimeObserver(observer)
        //                        videoPlayer?.pause()
        //                        timeObserver = nil
        //                    }
        //                }else{
        //
        //                    print("Is Expandable is true ")
        //
        //                }
        
        
        indicator.stopAnimating()
        
    }
    
    public func disconnectAVPlayer() {
        AVPlayerViewController().player = nil
    }
    
    public func reconnectAVPlayer() {
        AVPlayerViewController().player = self.videoPlayer
    }
    
    func setUpProgressView() {
        
        //ServiceHelper.shared.showIndicator()
        self.indicator.startAnimating()
        self.progressContainerView.isHidden = false
        self.videoContainer.isHidden = true
        
        self.videoControls.isHidden = true
        self.audioControls.isHidden = false
        
        //         self.progressContainerView?.addTarget(self, action: #selector(seekValueChanged(sender:)), for: .touchDown)
        //        self.progressContainerView?.addTarget(self, action: #selector(seekValueChanged(sender:)), for: .touchDownRepeat)
        
        self.progressContainerView?.addTarget(self, action: #selector(seekValueChanged(sender:)), for: .touchDragInside)
        
        
        //        public static var touchDragExit: UIControl.Event { get }
        //
        //        public static var touchUpInside: UIControl.Event { get }
        //
        //        public static var touchUpOutside: UIControl.Event { get }
        //
        //        public static var touchCancel: UIControl.Event { get }
        
        DispatchQueue.main.async {
            if let sessionLink = self.selectedCategory?.sessionUrl {
                
                
                //                if   self.condition == "ComingFormSetting"{
                //
                //
                //                }else {
                //
                guard let videoURL = URL(string: sessionLink.replacingOccurrences(of: " ", with: "%20")) else {return}
                self.videoPlayerItem = AVPlayerItem(url: videoURL)
                self.videoPlayer = AVPlayer(playerItem: self.videoPlayerItem)
                
                // self.videoPlayer?.removeObserver(self, forKeyPath: self.playerObserverKey, context: nil)
                
                // self.videoPlayer?.addObserver(self, forKeyPath: self.playerObserverKey, options: .new, context: videoContaxtObserver)
                
                self.videoPlayer?.play()
                
                //                if  self.condition == "ComingFormSetting"{
                //
                //                    if let timeNew  = ServiceHelper.shared.currentVideoTime{
                //                        let interval = CMTime(value: timeNew.value, timescale: timeNew.timescale)
                //
                //                        self.timeObserver = self.videoPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: {[weak self] (progressTime) in
                //
                //                            print("Progress Time /\(progressTime)")
                //                            let currentSeconds = CMTimeGetSeconds(progressTime)
                //
                //                            // let durationValues = self.secondsToHoursMinutesSeconds(seconds: Int(self.durationInSeconds))
                //
                //                            if  let currentValue
                //                                = self?.secondsToHoursMinutesSeconds(seconds: Int(currentSeconds)){
                //
                //                                print(String(format: "%02d:%02d", currentValue.1, currentValue.2))
                //
                //                                                           self?.audioTimeLabel.text = String(format: "%02d:%02d", currentValue.1, currentValue.2)
                //                            }
                //
                //
                //                            //                    print("Duration \(durationValues.0),,,,\(durationValues.1)...\(durationValues.2)")
                //                            //                    print("Current \(currentValue.1),,,,\(currentValue.2)")
                //                            //
                //
                //
                //
                //                            if self?.audioTimeLabel.text != "00:00"{
                //
                //                                //  ServiceHelper.shared.stopIndicator()
                //
                //                                self?.indicator.stopAnimating()
                //
                //                            }
                //
                //                            if let duration = self?.videoPlayer?.currentItem?.duration {
                //                                let durationSecond = CMTimeGetSeconds(duration)
                //                                self?.progressContainerView.value = CGFloat(Float(currentSeconds/durationSecond))
                //
                //                            }
                //                        })
                //
                //
                //                        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
                //                    }
                //                }
                
                
                //  else {
                let interval = CMTime(value: 1, timescale: 2)
                
                self.timeObserver = self.videoPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: {[weak self] (progressTime) in
                    
                    print("Progress Time /\(progressTime)")
                    let currentSeconds = CMTimeGetSeconds(progressTime)
                    
                    // let durationValues = self.secondsToHoursMinutesSeconds(seconds: Int(self.durationInSeconds))
                    if let currentValue = self?.secondsToHoursMinutesSeconds(seconds: Int(currentSeconds)){
                        
                        print(String(format: "%02d:%02d", currentValue.1, currentValue.2))
                        
                        print("Current value 1 \(currentValue.1)")
                        print("Current value 2 \(currentValue.2)")
                        
                        self?.audioTimeLabel.text = String(format: "%02d:%02d", currentValue.1, currentValue.2)
                        
                        
                        
                    }
                    //                    print("Duration \(durationValues.0),,,,\(durationValues.1)...\(durationValues.2)")
                    //                    print("Current \(currentValue.1),,,,\(currentValue.2)")
                    //
                    
                    
                    
                    
                    
                    if let duration = self?.videoPlayer?.currentItem?.duration {
                        let durationSecond = CMTimeGetSeconds(duration)
                        print("duration Second\(durationSecond)")
                        self?.progressContainerView.value = CGFloat(Float(currentSeconds/durationSecond))
                        
                        print("proress Duration\(self?.progressContainerView.value)")
                        
                        if (Float(currentSeconds/durationSecond))  != 0.0 {
                            
                            self?.indicator.stopAnimating()
                            
                        }
                    }
                })
                
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
                
                //   }
                
                
                //}
                
            }
        }
        
        let attributes = [
            /* Track */
            Attributes.minTrackTint(.white),
            Attributes.maxTrackTint(.white),
            Attributes.trackWidth(CGFloat(2.0)),
            Attributes.trackShadowRadius(CGFloat(0)),
            Attributes.trackShadowDepth(CGFloat(0)),
            Attributes.trackMinAngle(CGFloat(90)),
            Attributes.trackMaxAngle(CGFloat(360+90)),
            
            /* Thumb */
            Attributes.hasThumb(true),
            Attributes.thumbTint(UIColor.white),
            Attributes.thumbRadius(CGFloat(10.0)),
            Attributes.thumbShadowRadius(CGFloat(0)),
            Attributes.thumbShadowDepth(CGFloat(0))
        ]
        
        
        self.progressContainerView?.applyAttributes(attributes)
        
        self.progressContainerView?.valueMinimum = 0
        self.progressContainerView?.valueMaximum = self.maxTime
    }
    
    func setVideoView() {
        
        self.indicator.startAnimating()
        
        self.progressContainerView.isHidden = true
        self.videoContainer.isHidden = false
        self.videoControls.isHidden = false
        self.audioControls.isHidden = true
        
        self.videoSlider?.addTarget(self, action: #selector(videoSeekValueChanged(sender:)), for: .valueChanged)
        // WITH AVPlayerLayer
        DispatchQueue.main.async {
            if let sessionLink = self.selectedCategory?.sessionUrl {
                
                guard let videoURL = URL(string: sessionLink.replacingOccurrences(of: " ", with: "%20")) else {return}
                
                self.videoPlayerItem = AVPlayerItem(url: videoURL)
                self.videoPlayer = AVPlayer(playerItem: self.videoPlayerItem)
                
                let playerLayer = AVPlayerLayer(player: self.videoPlayer)
                playerLayer.videoGravity = .resizeAspectFill
                playerLayer.frame = self.videoView.bounds
                
                
                //                if let observerContaxt = self.videoPlayer?.observationInfo {
                //                    self.videoPlayer?.removeObserver(self, forKeyPath: self.playerObserverKey, context: observerContaxt)
                //                }
                //                self.videoPlayer?.addObserver(self, forKeyPath: self.playerObserverKey, options: .new, context: videoContaxtObserver)
                
                
                self.videoView.layer.addSublayer(playerLayer)
                self.videoPlayer?.play()
                
                
                
                let interval = CMTime(value: 1, timescale: 2)
                
                self.timeObserver = self.videoPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: {[weak self] (progressTime) in
                    let currentSeconds = CMTimeGetSeconds(progressTime)
                    
                    if let durationValues = self?.secondsToHoursMinutesSeconds(seconds: Int(self?.durationInSeconds ?? 0.0)){
                        
                        let durationMinute =  String(format: "%02d", durationValues.1)
                        let durationSeconds = String(format: "%02d", durationValues.2)
                        
                        if  let currentValue = self?.secondsToHoursMinutesSeconds(seconds: Int(currentSeconds)){
                            
                            let currentMinute = String(format: "%02d", currentValue.1)
                            let currentSecond = String(format: "%02d", currentValue.2)
                            
                            self?.timeLabel.text = "\(currentMinute):\(currentSecond)/\(durationMinute):\(durationSeconds)"
                        }
                    }
                    
                    
                    if self?.audioTimeLabel.text != "00:00"{
                        
                        //  ServiceHelper.shared.stopIndicator()
                        
                        self?.indicator.stopAnimating()
                        
                    }
                    
                    if let duration = self?.videoPlayer?.currentItem?.duration {
                        let durationSecond = CMTimeGetSeconds(duration)
                        self?.videoSlider.value = Float(currentSeconds/durationSecond)
                    }
                })
                
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
                
                
            }
        }
        
        /// WITH PLAYER POD
        //        DispatchQueue.main.async {
        //            self.player.playerDelegate = self
        //            self.player.playbackDelegate = self
        //            self.player.view.frame = self.videoView.bounds
        //            self.player.url =  URL(string: (self.selectedCategory?.sessionUrl ?? "").replacingOccurrences(of: " ", with: "%20"))
        //            self.player.playFromBeginning()
        //
        //            self.addChild(self.player)
        //            self.videoView.addSubview(self.player.view)
        //            self.player.didMove(toParent: self)
        //            self.player.fillMode = .resizeAspectFill
        //        }
        
        
        // WITH AVPlayerViewController
        
        //        DispatchQueue.main.async {
        //            guard let url = URL(string: (self.selectedCategory?.sessionUrl ?? "").replacingOccurrences(of: " ", with: "%20")) else {return}
        //            let avplayer = AVPlayer(url: url )
        //
        //
        //            let playerController = AVPlayerViewController()
        //            playerController.player = avplayer
        //            playerController.view.frame = CGRect(x: 0, y: 0, width: self.videoView.frame.size.width, height: self.videoView.frame.size.height)
        //            playerController.showsPlaybackControls = false
        //            self.addChild(playerController)
        //
        //            // Add sub view in your view
        //            self.videoView.addSubview(playerController.view)
        //            self.videoView.contentMode = .scaleAspectFill
        //            playerController.player?.play()
        //
        //        }
    }
    
    @objc func seekValueChanged(sender: MTCircularSlider){
        
        
        if let duration = videoPlayer?.currentItem?.duration{
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(sender.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            
            videoPlayer?.seek(to: seekTime, completionHandler: { (bool) in
                
            })
        }
        
        print(sender.value)
    }
    
    @objc func videoSeekValueChanged(sender: UISlider){
        if let duration = videoPlayer?.currentItem?.duration{
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(sender.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            
            videoPlayer?.seek(to: seekTime, completionHandler: { (bool) in
                
            })
        }
        
        
        print(sender.value)
    }
    
    @IBAction func playVideoBttnAction(sender: UIButton) {
        
        
        // sender.isSelected = !sender.isSelected
        if videoPlayer?.rate != 0 {
            videoPlayer?.pause()
            audioPlayPauseButton.setImage(UIImage(named: "icn_play_black"), for: .normal)
            ServiceHelper.shared.currentButtonState = "play"
            // sender.isSelected = true
        } else {
            videoPlayer?.play()
            
            audioPlayPauseButton.setImage(UIImage(named: "icn_pause_black"), for: .normal)
            ServiceHelper.shared.currentButtonState = ""
            //  sender.isSelected = false
            
        }
    }
    
    @IBAction func moveToFormardAction(){
        guard let duration  = videoPlayer?.currentItem?.duration else{
            return
        }
        guard let currentTime = videoPlayer?.currentTime() else{return}
        let playerCurrentTime = CMTimeGetSeconds(currentTime)
        
        let newTime = playerCurrentTime + 10
        
        if newTime < CMTimeGetSeconds(duration) {
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            print(time2)
            
            videoPlayer?.seek(to: time2)
        }else {
            
        }
    }
    
    @IBAction func moveToBackwordAction(){
        guard let currentTime = videoPlayer?.currentTime() else{return}
        
        let playerCurrentTime = CMTimeGetSeconds(currentTime)
        var newTime = playerCurrentTime - 10
        
        if newTime < 0 {
            newTime = 0
        }
        let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        
        videoPlayer?.seek(to: time2)
    }
    
    @IBAction func fullScreenAction(){
        isExpandVideoView = true
        playerController = AVPlayerViewController()
        playerController.delegate = self
        playerController.player = self.videoPlayer
        playerController.player?.play()
        self.present(playerController, animated: true, completion: nil)
    }
    
    //MARK: Avplayer notification
    
    @objc func playerDidFinishPlaying(){
        //    if GlobalVariable.isDailySession  == false {
        //        videoPlayer?.seek(to: CMTime.zero)
        //
        //        videoPlayer?.pause()
        //        videoPlayPauseButton.isSelected = true
        //        audioPlayPauseButton.isSelected = true
        //
        //        return
        //    }
        
        let vc : ReviewViewController = ReviewViewController.instantiate()
        vc.delegate = self
        vc.session = selectedCategory
        
        if isExpandVideoView == true {
            playerController?.dismiss(animated: true, completion: {
                // self.videoPlayer?.removeObserver(self, forKeyPath: self.playerObserverKey)
                self.present(vc, animated: true, completion: nil)
            })
        } else {
            // videoPlayer?.removeObserver(self, forKeyPath: self.playerObserverKey)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK: Avplayer observers
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //        print(change)
        //        print("-----> " , context)
        if keyPath == self.playerObserverKey {
            
            //print(keyPath)
            // dump(indicator.stopAnimating())
            // dump(indicator)
            // indicator.stopAnimating()
            
            if let duration = videoPlayer?.currentItem?.duration {
                durationInSeconds = CMTimeGetSeconds(duration)
            }
        }
    }
    
    
    //    override func removeObserver(_ observer: NSObject, forKeyPath keyPath: String, context: UnsafeMutableRawPointer?) {
    //
    //
    //        if keyPath == self.playerObserverKey{
    //           self.videoPlayer?.removeObserver(self, forKeyPath: self.playerObserverKey, context: nil)
    //    }
    //    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
}
extension PlayerViewController : PlayerDelegate, PlayerPlaybackDelegate {
    
    func playerReady(_ player: Player) {
        
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
        
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        
    }
    
    func player(_ player: Player, didFailWithError error: Error?) {
        print(error?.localizedDescription ?? "")
    }
    
    func playerCurrentTimeDidChange(_ player: Player) {
        print(player.currentTime)
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
        
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
        
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
        
    }
    
    func playerPlaybackDidLoop(_ player: Player) {
        
    }
    
}
extension PlayerViewController : popToRootVCDelegate {
    
    func popToRootVC() {
        isInitializePlayer = false
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

extension PlayerViewController:AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        isExpandVideoView = true
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        isExpandVideoView = false
        videoPlayer?.play()
        playVideoBttnAction(sender: videoPlayPauseButton)
        
    }
}
