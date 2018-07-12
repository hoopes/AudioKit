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
    
    let mic = AKMicrophone()
    let micMixer = AKMixer()
    
    let outputMixer = AKMixer()
    lazy var recorder: AKNodeRecorder? = try? AKNodeRecorder(node: micMixer)
    
    // Create an "output" for this with no volume
    let recordingOutputMixer: AKMixer = {
        let mixer = AKMixer()
        mixer.volume = 0
        return mixer
    }()
    
    var player = AVAudioPlayerNode()
    var audioFile: AVAudioFile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AKSettings.defaultToSpeaker = true
        
        // Setup the microphone
        mic.connect(to: micMixer)
           .connect(to: recordingOutputMixer)
           .connect(to: outputMixer)
        
        player.connect(to: outputMixer)
        
        AudioKit.output = outputMixer
        
        // Start AudioKit
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
    
    private func stopMic() {
        micButton.setTitle("Turn Mic On", for: .normal)
        // micBooster.gain = 0
        mic.stop()
    }
    
    private func startMic() {
        // micBooster.gain = 1
        micButton.setTitle("Turn Mic Off", for: .normal)
        mic.start()
    }
    
    @IBAction func toggleRecording(_ sender: UIButton) {
        if recorder!.isRecording {
            
            recordButton.setTitle("Start Recording", for: .normal)
            
            recorder?.stop()
            stopMic()
            
            if let recordedFile = recorder?.audioFile {
                
                audioFile = recordedFile
                
                micButton.isHidden = true
                playbackButton.isHidden = false
                
                recordedFile.exportAsynchronously(name: "test.caf",
                                                  baseDir: .documents,
                                                  exportFormat: .caf) { (audioFile, error) in
                    
                    if let error = error {
                        print("Failed to export! \(error)")
                    } else {
                        print("Successfully exported the audio file")
                        try? self.recorder?.reset()
                    }
                }
            }

        } else {
            micButton.isHidden = false
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
        
        if player.isPlaying {
            player.stop()
            sender.setTitle("Play Recording", for: .normal)
            recordButton.isHidden = false
        } else {
            recordButton.isHidden = true
            if let audioFile = self.audioFile {
                player.scheduleFile(audioFile, at: nil, completionHandler: nil)
                player.play()
            }
            sender.setTitle("Stop", for: .normal)
        }
    }
    
    func update(recordingState: Bool) {
        
    }
}
