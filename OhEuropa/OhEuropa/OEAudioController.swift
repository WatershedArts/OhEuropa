//
//  OEAudioController.swift
//  OhEuropa
//
//  Created by David Haylock on 06/01/2018.
//  Copyright © 2018 David Haylock. All rights reserved.
//

import Foundation
import StreamingKit
import TweenKit
import AVKit

class OEAudioController: NSObject, STKAudioPlayerDelegate {
	
	var staticAudio = AVAudioPlayer()
	var streamer = STKAudioPlayer()
	var vol = 0.0
	private let scheduler = ActionScheduler()
	
	///------------------------------------------------------------------------------------------
	/// Initializer
	///
	///------------------------------------------------------------------------------------------
	override init() {
		super.init()
		
		var options = STKAudioPlayerOptions()
		options.enableVolumeMixer = true
		
		streamer = STKAudioPlayer(options: options)
		streamer.delegate = self
		
		let audioPath = Bundle.main.path(forResource: "static.mp3", ofType: nil)!
		let url = URL(fileURLWithPath: audioPath)
		
		do {
			staticAudio = try AVAudioPlayer(contentsOf: url)
			staticAudio.volume = 0.0
			staticAudio.numberOfLoops = 10
//			staticAudio.play()
		}
		catch {
			print("Can't Load Static.mp3")
		}
	}
	
	///------------------------------------------------------------------------------------------
	/// Start Playing the Live Stream from Radio.co
	///------------------------------------------------------------------------------------------
	public func startPlayingRadio() {
		streamer.clearQueue()
		streamer.play(URL(string:"https://streams.radio.co/s02776f249/listen")!)
		streamer.volume = 0.0
	}
	
	///------------------------------------------------------------------------------------------
	/// Stop Playing the Live Stream from Radio.co
	///------------------------------------------------------------------------------------------
	public func stopPlayingRadio() {
		let action = InterpolationAction(from: self.streamer.volume, to: 0.00, duration: 5.0, easing: .sineInOut, update: { [unowned self] in self.streamer.volume = $0 })
		action.onBecomeInactive = fadeOutComplete
		scheduler.run(action: action)
	}
	
	///------------------------------------------------------------------------------------------
	/// When the user is inside the inner perimeter
	///------------------------------------------------------------------------------------------
	public func crossFadeStaticAndRadio() {
		startPlayingRadio()
	}
	
	///------------------------------------------------------------------------------------------
	/// When the user is inside the inner perimeter
	///------------------------------------------------------------------------------------------
	public func fadeOutStaticAndFadeUpRadio() {
		let streamingAction = InterpolationAction(from: self.streamer.volume, to: 0.75, duration: 5.0, easing: .sineInOut, update: { [unowned self] in self.streamer.volume = $0 })
		let staticAction = InterpolationAction(from: self.staticAudio.volume, to: 0.0, duration: 5.0, easing: .sineInOut, update: { [unowned self] in self.staticAudio.volume = $0 })
		scheduler.run(action: staticAction)
		scheduler.run(action: streamingAction)
	}
	
	///------------------------------------------------------------------------------------------
	/// Play Static Audio
	///------------------------------------------------------------------------------------------
	public func startPlayingStatic() {
		let action = InterpolationAction(from: 0.0, to: 0.75, duration: 5.0, easing: .sineInOut, update: { [unowned self] in self.staticAudio.volume = $0 })
		self.staticAudio.play()
		scheduler.run(action: action)
	}
	
	///------------------------------------------------------------------------------------------
	/// Stop Static Audio
	///------------------------------------------------------------------------------------------
	public func stopPlayingStatic() {
		let action = InterpolationAction(from: self.staticAudio.volume, to: 0.00, duration: 5.0, easing: .sineInOut, update: { [unowned self] in self.staticAudio.volume = $0 })
		action.onBecomeInactive = staticFadeOutComplete
		scheduler.run(action: action)
	}
	
	///------------------------------------------------------------------------------------------sou
	/// Tween Call back to stop the Radio when finished fading
	///------------------------------------------------------------------------------------------
	private func staticFadeOutComplete() {
		print("Stopped Playing Static")
		staticAudio.stop()
	}
	
	///------------------------------------------------------------------------------------------sou
	/// Tween Call back to stop the Radio when finished fading
	///------------------------------------------------------------------------------------------
	private func fadeOutComplete() {
		print("Stopped Playing Radio")
		streamer.stop()
	}
	
	///------------------------------------------------------------------------------------------
	/// Did we start playing a track
	///
	/// - Parameters:
	///   - audioPlayer: Audio Player
	///   - queueItemId: Queue Item
	///------------------------------------------------------------------------------------------
	func audioPlayer(_ audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
		print("Started Playing")
	}
	
	///------------------------------------------------------------------------------------------
	/// Has the Audio Player finished Buffering
	///
	/// - Parameters:
	///   - audioPlayer: Audio Player
	///   - queueItemId: Queue Item
	///------------------------------------------------------------------------------------------
	func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
		print("Finished Buffering")
	}
	
	///------------------------------------------------------------------------------------------
	/// Audio Player State Change
	///
	/// - Parameters:
	///   - audioPlayer: Audio Player
	///   - state: new state
	///   - previousState: previous state
	///------------------------------------------------------------------------------------------
	func audioPlayer(_ audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
		switch state {
		case STKAudioPlayerState.stopped:
			print("Audio Player Stopped")
			break;
		case STKAudioPlayerState.running:
			print("Audio Player Running")
			break;
		case STKAudioPlayerState.buffering:
			print("Audio Player Buffering")
			break;
		case STKAudioPlayerState.playing:
			print("Audio Player Playing")
			let action = InterpolationAction(from: 0.00, to: 0.15, duration: 5.0, easing: .sineInOut, update: { [unowned self] in self.streamer.volume = $0 })
			scheduler.run(action: action)
			break;
		default:
			break;
		}
	}
	
	///------------------------------------------------------------------------------------------
	/// Stopped Playing Track Manager
	///
	/// - Parameters:
	///   - audioPlayer: Audio Player
	///   - queueItemId: Queue Item
	///   - stopReason: Why did we stop playing
	///   - progress:
	///   - duration:
	///------------------------------------------------------------------------------------------
	func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
		print("Finished Playing \(queueItemId) \(stopReason)")
	}
	
	///------------------------------------------------------------------------------------------
	/// Audio Player Error
	///
	/// - Parameters:
	///   - audioPlayer: Audio Player
	///   - errorCode: What type of Error
	///------------------------------------------------------------------------------------------
	func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
		print("Error: \(errorCode)")
	}
}
