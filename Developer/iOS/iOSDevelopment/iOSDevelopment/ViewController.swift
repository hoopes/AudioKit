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
    
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playbackButton: UIButton! {
        didSet {
            playbackButton.isHidden = true
        }
    }
    
    var recording = false {
        didSet {
            update(recordingState: recording)
        }
    }
    
    let mic = AKMicrophone()
    let micMixer = AKMixer()
    let outputMixer = AKMixer()
    lazy var recorder: AKNodeRecorder? = try? AKNodeRecorder(node: micMixer)
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
    
    @IBAction func toggleRecording(_ sender: UIButton) {
        recording = !recording
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
        
        if recordingState {
            
            playbackButton.isHidden = true
            recordButton.setTitle("Recording", for: .normal)
            
            do {
                try recorder?.record()
            } catch {
                print(error)
            }
            
        } else {
            recordButton.setTitle("Record", for: .normal)
            
            recorder?.stop()
            
            if let recordedFile = recorder?.audioFile {
                
                audioFile = recordedFile
                
                playbackButton.isHidden = false
                
                recordedFile.exportAsynchronously(name: "test.caf", baseDir: .documents, exportFormat: .caf) { (audioFile, error) in
                    
                    if let error = error {
                        print("Failed to export! \(error)")
                    } else {
                        print("Successfully exported the audio file")
                        try? self.recorder?.reset()
                    }
                }
            }
        }
    }
}


//import AudioKit
//import AudioKitUI
//import UIKit
//
//class ViewController: UIViewController {
//
//    @IBOutlet weak var button1: UIButton!
//    @IBOutlet weak var sliderLabel1: UILabel!
//    @IBOutlet weak var slider1: UISlider!
//    @IBOutlet weak var sliderLabel2: UILabel!
//    @IBOutlet weak var slider2: UISlider!
//    @IBOutlet weak var outputTextView: UITextView!
//
//    // Define components
//    var oscillator = AKOscillator()
//    var booster = AKBooster()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        sliderLabel1.text = "Gain"
//        sliderLabel2.text = "Ramp Duration"
//        button1.titleLabel?.text = "Start"
//    }
//
//    @IBAction func start(_ sender: UIButton) {
//
//        oscillator >>> booster
//        booster.gain = 0
//
//        AudioKit.output = booster
//        do {
//            try AudioKit.start()
//        } catch {
//            AKLog("AudioKit did not start!")
//        }
//        sender.isEnabled = false
//
//    }
//
//    @IBAction func button1(_ sender: UIButton) {
//        if oscillator.isPlaying {
//            oscillator.stop()
//            button1.titleLabel?.text = "Start"
//            updateText("Stopped")
//        } else {
//            oscillator.start()
//            button1.titleLabel?.text = "Stop"
//            updateText("Playing \(Int(oscillator.frequency))Hz")
//        }
//    }
//    @IBAction func slid1(_ sender: UISlider) {
//        booster.gain = Double(slider1.value)
//        updateText("booster gain = \(booster.gain)")
//    }
//
//    @IBAction func slid2(_ sender: UISlider) {
//        booster.rampDuration = Double(slider2.value)
//        updateText("booster ramp duration = \(booster.rampDuration)")
//    }
//
//    func updateText(_ input: String) {
//        DispatchQueue.main.async(execute: {
//            self.outputTextView.text = "\(input)\n\(self.outputTextView.text!)"
//        })
//    }
//
//    @IBAction func clearText(_ sender: AnyObject) {
//        DispatchQueue.main.async(execute: {
//            self.outputTextView.text = ""
//        })
//    }
//}
