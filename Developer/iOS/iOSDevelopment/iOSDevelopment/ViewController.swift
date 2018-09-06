//
//  ViewController.swift
//  iOSDevelopment
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var micButton: UIButton! {
        didSet {
            micButton.isHidden = true
        }
    }
    
    @IBOutlet weak var playbackButton: UIButton! {
        didSet {
            playbackButton.isHidden = true
        }
    }
    
    @IBOutlet weak var cartButton: UIButton! {
        didSet {
            cartButton.isHidden = true
        }
    }
    
    let mic = AKMicrophone()
    var micMixer: AKMixer!
    var micBooster: AKBooster!
    
    var cartMixer: AKMixer!
    var cartPlayer: AKPlayer?
    
    var outputMixer: AKMixer!
    
    var recorder: AKNodeRecorder?
    var recordingMixer: AKMixer!
    var recordingOutputMixer: AKMixer!

    var player: AKPlayer?
    var audioFile: AVAudioFile?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("GETTING STARTED")
        
        do {
            AKSettings.bufferLength = .short // 128 samples
            try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
        } catch {
            AKLog("Could not set session category.")
        }
        
        AKSettings.defaultToSpeaker = true

        micMixer = AKMixer(mic)
        micBooster = AKBooster(micMixer)

        // Load the cart playing object
        let path = Bundle.main.path(forResource: "audio1", ofType: ".wav")
        let url = URL(fileURLWithPath: path!)
        cartPlayer = AKPlayer(url: url)
        cartPlayer?.isLooping = true
        
        // Setup the cart mixer
        cartMixer = AKMixer(cartPlayer)
        
        recordingMixer = AKMixer(cartMixer, micBooster)
        recorder = try? AKNodeRecorder(node: recordingMixer)
        
        // Pass the recording mixer through an output mixer whose volume
        // is 0 so it's not heard in the output. If we don't do this, audio
        // is not pulled through the recording mixer at all
        recordingOutputMixer = AKMixer(recordingMixer)
        recordingOutputMixer.volume = 0
        
        outputMixer = AKMixer(cartMixer, recordingOutputMixer)

        stopMic()
        stopCart()

        AudioKit.output = outputMixer
        
        do {
            try AudioKit.start()
        } catch {
            print("AudioKit did not start! \(error)")
        }
    }
    
    @IBAction func toggleMic(_ sender: Any) {

        if mic.isStarted {
            AKLog("Toggling mic off")
            stopMic()
        } else {
            AKLog("Toggling mic on")
            startMic()
        }
    }
    
    private func startMic() {
        // micBooster.gain = 1
        micButton.setTitle("Turn Mic Off", for: .normal)
        mic.start()
    }
    
    private func stopMic() {
        micButton.setTitle("Turn Mic On", for: .normal)
        // micBooster.gain = 0
        mic.stop()
    }
    
    @IBAction func toggleCart(_ sender: UIButton) {
        
        if cartPlayer?.isPlaying == true {
            AKLog("Toggling cart off")
            stopCart()
        } else {
            AKLog("Toggling cart on")
            startCart()
        }
    }
    
    private func startCart() {
        cartButton.setTitle("Turn Cart Off", for: .normal)
        cartPlayer?.play()
    }
    
    private func stopCart() {
        cartButton.setTitle("Turn Cart On", for: .normal)
        cartPlayer?.stop()
        
    }
    
    @IBAction func toggleRecording(_ sender: UIButton) {
        if recorder!.isRecording {
            
            AKLog("Stopping recording and loading the player with the file")
            
            recordButton.setTitle("Start Recording", for: .normal)
            
            recorder?.stop()
            
            stopMic()
            stopCart()

            if let recordedFile = recorder?.audioFile {
                
                micButton.isHidden = true
                cartButton.isHidden = true
                playbackButton.isHidden = false
                
                if player == nil {
                    
                    player = AKPlayer(audioFile: recordedFile)
                    outputMixer.connect(input: player!)
                    
                    player?.completionHandler = {
                        DispatchQueue.main.async {
                            self.playbackButton.setTitle("Play Recording", for: .normal)
                            self.recordButton.isHidden = false
                        }
                    }

                } else {
                    player?.load(audioFile: recordedFile)
                }
                
                recordedFile.exportAsynchronously(name: "hoopes-test.m4a",
                                                  baseDir: .documents,
                                                  exportFormat: .m4a) { (audioFile, error) in

                    if let error = error {
                        print("Failed to export! \(error)")
                    } else {
                        print("Successfully exported the audio file")
                        try? self.recorder?.reset()
                    }
                }
            }

        }
        else {
            micButton.isHidden = false
            cartButton.isHidden = false
            playbackButton.isHidden = true
            recordButton.setTitle("Recording", for: .normal)
            
            do {
                try recorder?.record()
            } catch {
                print(error)
            }
        }
    }

    @IBAction func togglePlaying(_ sender: UIButton) {
        
        if player?.isPlaying == true {
            player?.stop()
            sender.setTitle("Play Recording", for: .normal)
            recordButton.isHidden = false
        } else {
            recordButton.isHidden = true
            player?.play()
            sender.setTitle("Stop Playing", for: .normal)
        }
    }
}
