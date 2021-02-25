import UIKit
import AVKit
import AVFoundation

// MARK: - VideoViewDelegate
@objc protocol VideoViewDelegate: class {
    /// Method called when the VideoView's AVPlayer is ready to play the movie file.
    /// - Parameter item: An AVPlayerItem instance referencing this class' AVPlayer's current item.
    @objc optional func videoPlaybackStatus(_ item: AVPlayerItem?)
}

/**
 Abstract: Custom UIView used to play the video
 */
class VideoView: UIView {
    
    // MARK: - Class Vars
    
    // MARK: - VideoViewDelegate
    var delegate: VideoViewDelegate?
    
    // MARK: - URL
    var url: URL?
    
    // MARK: - AVPlayerLayer
    var playerLayer: AVPlayerLayer?
    
    // MARK: - AVPlayer
    var player: AVPlayer?
    
    /// Initialized Float value used to set the video playback rate
    var rate: Float = 1.0
    
    /// Declared String value for the AVPlayer KVO
    static let status: String = "status"
    
    /// Initialized Boolean used to determine whether the video should loop or not. Defaults to FALSE.
    var isLoopEnabled: Bool = true
    
    /// Initialized AVLayerVideoGravity used to set the AVPlayerLayer's 'videoGravity' property. Defaults to 'resizeAspect'
    var videoGravity: AVLayerVideoGravity = .resizeAspect {
        didSet {
            // MARK: - AVPlayerLayer
            self.playerLayer?.videoGravity = videoGravity
        }
    }
    
    /// Initialized Boolean used to determine whether the video is muted or not. Defaults to FALSE.
    var isMuted: Bool = false {
        didSet {
            // MARK: - AVPlayer
            player?.isMuted = self.isMuted
        }
    }
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didLoad()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // MARK: - AVPlayerLayer
        // Update the layer's frame
        playerLayer?.frame = bounds
    }
    
    func didLoad() {
        frame = bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .clear
        clipsToBounds = true
        layer.masksToBounds = false
        
        // MARK: - AVPlayer
        player = AVPlayer()
        player?.allowsExternalPlayback = false
        player?.rate = 1.0
        player?.isMuted = self.isMuted
        
        // MARK: - AVPlayerLayer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bounds
        playerLayer?.videoGravity = videoGravity
        // Add the AVPlayerLayer to this view's layer
        layer.addSublayer(playerLayer!)
        
        // Add observers
        addObservers()
        
        // Layout the subviews
        layoutSubviews()
    }
    
    // MARK: - Deinit
    deinit {
        // Remove all the observers
        removeObservers()
        
        // Deallocate all the objects
        delegate = nil
        playerLayer = nil
        player = nil
    }
    
    /// Removes all KVO and NotificationCenter observers.
    func removeObservers() {
        // Remove observers
        player?.removeObserver(self, forKeyPath: VideoView.status)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    /// Adds all the associated KVO and NotificationCenter observers.
    func addObservers() {
        // MARK: - KVO
        player?.addObserver(self, forKeyPath: VideoView.status, options: [], context: nil)
        
        // MARK: - NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    /// NOTE: Make sure to call this method if you want the video to stop playing between queues (ie: when multiple videos are preloaded in collecton view cells and you want the previous video to stop playing). Generally this method is suitable for a cell's 'prepareForReuse()' method.
    func deallocate() {
        // MARK: - AVPlayer
        player?.pause()
        player?.replaceCurrentItem(with: nil)
    }
    
    /// Set the video for this view using
    /// - Parameter url: The URL path (whether remote or local) of the video content.
    func setItem(_ url: URL) {
        // Remove the observers
        removeObservers()
        
        //        // MARK: - AVPlayerLayer
        //        playerLayer?.videoGravity = self.videoGravity
        //
        //        // MARK: - AVPlayer
        //        player?.replaceCurrentItem(with: AVPlayerItem(url: url))
        //        player?.isMuted = self.isMuted
        //        player?.externalPlaybackVideoGravity = self.videoGravity
        
        // MARK: - AVPlayer
        player = AVPlayer(url: url)
        player?.allowsExternalPlayback = false
        player?.rate = 1.0
        player?.isMuted = self.isMuted
        
        // MARK: - AVPlayerLayer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bounds
        playerLayer?.videoGravity = videoGravity
        
        if playerLayer?.superlayer != layer {
            // Add the AVPlayerLayer to this view's layer
            layer.addSublayer(playerLayer!)
        }
        
        // Add the observers
        addObservers()
    }
    
    /// Play the current video item.
    /// - Parameter rate: A Float value used to play the video immediately at the specified frame rate. Defaults to 1.0.
    func play(rate: Float = 1.0) {
        // Set the rate
        self.rate = rate
        
        // Execute the following code ONLY if the video is currently NOT playing
        guard player?.timeControlStatus != .playing else {
            print("\(#file) \(#function) - Exiting method because the video is currently NOT playing.")
            return
        }
        
        // Don't disable background audio when movie is playing
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
        } catch let error {
            print("\(#file) \(#function) - Error enabling background audio to play continuously with movie playback \(error.localizedDescription)")
        }
        
        // MARK: - AVPlayer
        self.player?.playImmediately(atRate: rate)
    }
    
    /// Pause the current video item.
    func pause() {
        // MARK: - AVPlayer
        player?.pause()
    }
    
    /// Called when the AVPlayerItem reaches the end of the video.
    /// - Parameter sender: A Notification observer that calls this method.
    @objc func videoDidEnd(_ sender: Notification) {
        // Execute the following if 'isLoopEnabled' is TRUE
        guard isLoopEnabled == true else {
            print("\(#file) \(#function) - Exiting method because 'isLoopEnabled' is FALSE.")
            return
        }
        
        // MARK: - AVPlayer
        player?.pause()
        player?.seek(to: CMTime.zero)
        player?.play()
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Unwrap the object to ensure that it is indeed an AVPlayer
        guard let playerObject = object as? AVPlayer else {
            print("\(#file) \(#function) - Exiting method because the object is NOT an AVPlayer.")
            return
        }
        
        // Ensure that the AVPlayer object is this class' AVPlayer object and that the 'keyPath' value is "status"
        guard playerObject == self.player && keyPath == VideoView.status else {
            print("\(#file) \(#function) - Exiting method because the AVPlayer doesn't reference self and its 'keyPath' is NOT \"status\".")
            return
        }
        
        // MARK: - VideoViewDelegate
        // Call this class' delgate method if the video is ready to play.
        self.delegate?.videoPlaybackStatus!(self.player?.currentItem)
    }
}

