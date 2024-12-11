//
//  Sound.swift
//  
//
//  Created by Jacob W Esselstyn on 4/12/23, based on twostraws/Subsonic on Github by Hacking with Swift.
//

import AVFoundation
import SwiftUI

/// The main class responsible for loading and playing sounds.
public class MySoundController: NSObject, AVAudioPlayerDelegate {
	
	/// When bound to some SwiftUI state, this controls how an audio player
	/// responds when playing for a second time.
	public enum PlayMode {
		/// Restarting a sound should start from the beginning each time.
		case reset

		/// Restarting a sound should pick up where it left off, or start from the
		/// beginning if it ended previously.
		case `continue`
	}

	/// With AVAudioPlayer, specifying -1 for `numberOfLoops` means the
	/// audio should loop forever. To avoid exposing that in this library, we wrap
	/// the repeat count inside this custom struct, allowing `.continuous` instead.
	public struct RepeatCount: ExpressibleByIntegerLiteral, Equatable {
		public static let continuous: RepeatCount = -1
		public let value: Int

		public init(integerLiteral value: Int) {
			self.value = value
		}
	}

	/// This class is *not* designed to be instantiated; please use the `shared` singleton.
	override private init() { }

	/// The main access point to this class. It's a singleton because sounds must
	/// be loaded and stored in order to continue playing after calling play().
	public static let shared = MySoundController()

	/// The collection of AVAudioPlayer instances that are currently playing.
	private var playingSounds = Set<AVAudioPlayer>()

	/// Loads, prepares, then plays a single sound from your bundle.
	/// - Parameters:
	///   - sound: The name of the sound file you want to load.
	///   - bundle: The bundle containing the sound file. Defaults to the main bundle.
	///   - volume: How loud to play this sound relative to other sounds in your app,
	///   specified in the range 0 (no volume) to 1 (maximum volume).
	///   - pan: Pans Audio. 0 is center, -1.0 is full left, 1.0 is full right.
	///   - repeatCount: How many times to repeat this sound. Specifying 0 here
	///   (the default) will play the sound only once.
	///   - timeInterval: The time in seconds for which playback is delayed.
	public func play(sound: String, from bundle: Bundle = .main, volume: Float = 1, pan: Float = 0, repeatCount: RepeatCount = 0, after timeInterval: TimeInterval? = nil) {
		guard UserDefaults.standard.bool(forKey: "isSoundEnabled") == true else { return }
		DispatchQueue.global().async {
			guard let player = self.prepare(sound: sound, from: bundle) else { return }

			player.numberOfLoops = repeatCount.value
			player.volume = volume
			player.delegate = self
			player.pan = pan
			
			if let timeInterval {
				player.play(atTime: player.deviceCurrentTime+timeInterval)
			} else {
				player.play()
			}

			// We need to keep track of all sounds that are currently
			// being managed by us, so we insert them into the
			// `playingSounds` set on the main queue.
			DispatchQueue.main.async {
				self.playingSounds.insert(player)
			}
		}
	}

	/// Prepares a sound for playback, sending back the audio player for you to
	/// use however you want.
	/// - Parameters:
	///   - sound: The name of the sound file you want to load.
	///   - bundle: The bundle containing the sound file. Defaults to the main bundle.
	/// - Returns: The prepared AVAudioPlayer instance, ready to play.
	@discardableResult///
	public func prepare(sound: String, from bundle: Bundle = .main) -> AVAudioPlayer? {
		guard let url = bundle.url(forResource: sound, withExtension: nil) else {
			print("Failed to find \(sound) in \(bundle.bundleURL.lastPathComponent).")
			return nil
		}

		guard let player = try? AVAudioPlayer(contentsOf: url) else {
			print("Failed to load \(sound) from \(bundle.bundleURL.lastPathComponent).")
			return nil
		}

		player.prepareToPlay()
		return player
	}

	/// Called when one of our sounds has finished, so we can remove it from the
	/// set of active sounds and Swift can release the memory.
	public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		playingSounds.remove(player)
	}

	
	/// Pauses one specific sound file currently being played centrally by Subsonic.
	public func pause(sound: String) {
		for playingSound in playingSounds {
			if playingSound.url?.lastPathComponent == sound {
				playingSound.pause()
			}
		}
	}
	
	/// Stops one specific sound file currently being played centrally by Subsonic.
	public func stop(sound: String) {
		for playingSound in playingSounds {
			if playingSound.url?.lastPathComponent == sound {
				playingSound.stop()
			}
		}
	}

	/// Stops all sounds currently being played centrally by Subsonic.
	public func stopAllManagedSounds() {
		for playingSound in playingSounds {
			playingSound.stop()
		}
	}
}

/// Responsible for loading and playing a single sound attached to a SwiftUI view.
public class MySoundPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
	/// A Boolean representing whether this sound is currently playing.
	@Published public var isPlaying = false

	/// The internal audio player being managed by this object.
	private var audioPlayer: AVAudioPlayer?

	/// How loud to play this sound relative to other sounds in your app,
	/// specified in the range 0 (no volume) to 1 (maximum volume).
	public var volume: Double {
		didSet {
			audioPlayer?.volume = Float(volume)
		}
	}

	/// Number of times to repeat this sound. Specifying 0 here (the default) will play the sound only once.
	public var repeatCount: MySoundController.RepeatCount {
		didSet {
			audioPlayer?.numberOfLoops = repeatCount.value
		}
	}

	/// Whether playback should restart from the beginning each time, or
	/// continue from the last playback point.
	public var playMode: MySoundController.PlayMode


	/// Creates a new instance by looking for a particular sound filename in a bundle of your choosing.of `.reset`.
	/// - Parameters:
	///   - sound: The name of the sound file you want to load.
	///   - bundle: The bundle containing the sound file. Defaults to the main bundle.
	///   - volume: How loud to play this sound relative to other sounds in your app,
	///     specified in the range 0 (no volume) to 1 (maximum volume).
	///   - repeatCount: How many times to repeat this sound. Specifying 0 here
	///     (the default) will play the sound only once.
	///   - playMode: Whether playback should restart from the beginning each time, or
	///     continue from the last playback point.
	public init(sound: String, bundle: Bundle = .main, volume: Double = 1.0, repeatCount: MySoundController.RepeatCount = 0, playMode: MySoundController.PlayMode = .reset) {
		audioPlayer = MySoundController.shared.prepare(sound: sound, from: bundle)

		self.volume = volume
		self.repeatCount = repeatCount
		self.playMode = playMode

		super.init()

		audioPlayer?.delegate = self
	}

	/// Plays the current sound. If `playMode` is set to `.reset` this will play from the beginning,
	/// otherwise it will play from where the sound last left off.
	public func play() {
		guard UserDefaults.standard.bool(forKey: "isSoundEnabled") == true else { return }
		
		isPlaying = true

		if playMode == .reset {
			audioPlayer?.currentTime = 0
		}

		audioPlayer?.play()
	}

	/// Stops the audio from playing.
	public func stop() {
		audioPlayer?.stop()
	}

	public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		isPlaying = false
	}
}

/// Attaches sounds to a SwiftUI view so they can play based on some program state.
public struct MySoundPlayerModifier: ViewModifier {
	/// Internal class responsible for communicating AVAudioPlayer events back to our SwiftUI modifier.
	private class PlayerModifierDelegate: NSObject, AVAudioPlayerDelegate {
		/// The function to be called when a sound has finished playing.
		var onFinish: ((Bool) -> Void)?

		/// Called by an AVAudioPlayer when it finishes.
		/// - Parameters:
		///   - player: The audio player in question.
		///   - flag: Whether playback finished successfully or not.
		func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
			onFinish?(flag)
		}
	}

	/// The name of the sound file you want to load.
	let sound: String

	/// The bundle containing the sound file. Defaults to the main bundle.
	var from: Bundle = .main

	/// Tracks whether the sound should currently be playing or not.
	@Binding var isPlaying: Bool

	/// How loud to play this sound relative to other sounds in your app,
	/// specified in the range 0 (no volume) to 1 (maximum volume).
	let volume: Double

	/// How many times to repeat this sound. Specifying 0 here (the default)
	/// will play the sound only once.
	let repeatCount: MySoundController.RepeatCount

	/// Whether playback should restart from the beginning each time, or
	/// continue from the last playback point.
	var playMode: MySoundController.PlayMode = .reset

	/// Our internal audio player, marked @State to keep it alive when our
	/// modifier is recreated.
	@State private var audioPlayer: AVAudioPlayer?

	/// The delegate for our internal audio player, marked @State to keep it
	/// alive when our modifier is recreated.
	@State private var audioPlayerDelegate: PlayerModifierDelegate?

	public func body(content: Content) -> some View {
		content
			.onChange(of: isPlaying) {
				if isPlaying {
					guard UserDefaults.standard.bool(forKey: "isSoundEnabled") == true else { return }
					
					// When `playMode` is set to `.reset` we need to make sure
					// all play requests start at time 0.
					if playMode == .reset {
						audioPlayer?.currentTime = 0
					}

					audioPlayer?.play()
				} else {
					audioPlayer?.stop()
				}
			}
			.onAppear(perform: prepareAudio)
			.onChange(of: volume) { updateAudio() }
			.onChange(of: repeatCount) { updateAudio() }
			.onChange(of: sound) { prepareAudio() }
			.onChange(of: from) { prepareAudio() }
	}

	/// Called to initialize all our audio, either because we're just setting up or
	/// because we're changing sound/bundle.
	///
	/// Doing this work here rather than in an initializer stop SwiftUI from recreating the
	/// audio data every time the view is changed, and also delays the work of loading
	/// audio until the responsible view is actually visible.
	private func prepareAudio() {
		// This SwiftUI modifier is a struct, so we can't set ourselves
		// up as the delegate for our AVAudioPlayer. So, instead we
		// have a little shim: we create a dedicated `PlayerDelegate`
		// class instance that acts as the audio delegate, and forwards
		// its `audioPlayerDidFinishPlaying()` on to us as a callback.
		audioPlayerDelegate = PlayerModifierDelegate()

		// Load the audio player, but *do not* play – playback should
		// only happen when the isPlaying Boolean becomes true.
		audioPlayer = MySoundController.shared.prepare(sound: sound, from: from)
		audioPlayerDelegate?.onFinish = audioFinished
		audioPlayer?.delegate = audioPlayerDelegate

		updateAudio()
	}

	/// Changes the playback parameters for an existing sound.
	private func updateAudio() {
		audioPlayer?.volume = Float(volume)
		audioPlayer?.numberOfLoops = repeatCount.value
	}

	/// Called when our internal player has finished playing, and sets the `isPlaying` Boolean back to false.
	func audioFinished(_ successfully: Bool) {
		isPlaying = false
	}
}

extension View {
	/// Plays a single sound immediately.
	/// - Parameters:
	///   - sound: The name of the sound file you want to load.
	///   - bundle: The bundle containing the sound file. Defaults to the main bundle.
	///   - volume: How loud to play this sound relative to other sounds in your app,
	///   specified in the range 0 (no volume) to 1 (maximum volume).
	///   - pan: Pans audio. 0.0 is center, -1.0 is full left, 1.0 is full right.
	///   - repeatCount: How many times to repeat this sound. Specifying 0 here
	///   (the default) will play the sound only once.
	///   - timeInterval: The time in seconds for which playback is delayed.
	public func playSound(_ sound: String, from bundle: Bundle = .main, volume: Float = 1, pan: Float = 0, repeatCount: MySoundController.RepeatCount = 0, after timeInterval: TimeInterval? = nil) {
		MySoundController.shared.play(sound: sound, from: bundle, volume: volume, pan: pan, repeatCount: repeatCount, after: timeInterval)
	}

	/// Plays or stops a single sound based on the `isPlaying` Boolean.
	/// - Parameters:
	///   - sound: The name of the sound file you want to load.
	///   - bundle: The bundle containing the sound file. Defaults to the main bundle.
	///   - isPlaying: A Boolean tracking whether the sound should currently be playing.
	///   - volume: How loud to play this sound relative to other sounds in your app,
	///   specified in the range 0 (no volume) to 1 (maximum volume).
	///   - repeatCount: How many times to repeat this sound. Specifying 0 here
	///   (the default) will play the sound only once.
	///   - playMode: Whether playback should restart from the beginning each time,
	///   or continue from the last playback point. Defaults to `.reset`.
	/// - Returns: A new view that plays the sound when isPlaying becomes true.
	public func sound(_ sound: String, from bundle: Bundle = .main, isPlaying: Binding<Bool>, volume: Double = 1, repeatCount: MySoundController.RepeatCount = .continuous, playMode: MySoundController.PlayMode = .reset) -> some View {
		self.modifier(
			MySoundPlayerModifier(sound: sound, from: bundle, isPlaying: isPlaying, volume: volume, repeatCount: repeatCount, playMode: playMode)
		)
	}

	/// Stops one specific sound played using `play(sound:)`. This will *NOT* stop sounds
	/// that you have bound to your app's state using the `sound()` modifier.
	public func stop(sound: String) {
		MySoundController.shared.stop(sound: sound)
	}

	/// Stops all sounds that were played using `play(sound:)`. This will *NOT* stop sounds
	/// that you have bound to your app's state using the `sound()` modifier.
	public func stopAllManagedSounds() {
		MySoundController.shared.stopAllManagedSounds()
	}
	
}

#if !os(macOS)
extension AVAudioSession.Port {
	/// A list of all ports that are Outputs or I/O.
	public static let allOutputs:[AVAudioSession.Port] = [
		.AVB, .bluetoothHFP, .displayPort, .carAudio, .fireWire, .PCI, .thunderbolt, .usbAudio, .virtual,
		.airPlay, .bluetoothA2DP, .bluetoothLE, .builtInReceiver, .builtInSpeaker, .HDMI, .headphones, .lineOut
	]
	
	/// A list of all ports that are Inputs or I/O.
	public static let allInputs: [AVAudioSession.Port] = [
		.AVB, .bluetoothHFP, .displayPort, .carAudio, .fireWire, .PCI, .thunderbolt, .usbAudio, .virtual,
		.builtInMic, .headsetMic, .lineIn
	]

}
#endif
