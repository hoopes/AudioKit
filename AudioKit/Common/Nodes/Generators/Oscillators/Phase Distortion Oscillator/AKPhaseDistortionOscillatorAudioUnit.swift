//
//  AKPhaseDistortionOscillatorAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKPhaseDistortionOscillatorAudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AKPhaseDistortionOscillatorParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKPhaseDistortionOscillatorParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var frequency: Double = 440 {
        didSet { setParameter(.frequency, value: frequency) }
    }
    var amplitude: Double = 1 {
        didSet { setParameter(.amplitude, value: amplitude) }
    }
    var phaseDistortion: Double = 0 {
        didSet { setParameter(.phaseDistortion, value: phaseDistortion) }
    }
    var detuningOffset: Double = 0 {
        didSet { setParameter(.detuningOffset, value: detuningOffset) }
    }
    var detuningMultiplier: Double = 1 {
        didSet { setParameter(.detuningMultiplier, value: detuningMultiplier) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        return createPhaseDistortionOscillatorDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let flags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]

        let frequency = AUParameterTree.createParameter(
            withIdentifier: "frequency",
            name: "Frequency (Hz)",
            address: AUParameterAddress(0),
            min: 0,
            max: 20_000,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let amplitude = AUParameterTree.createParameter(
            withIdentifier: "amplitude",
            name: "Amplitude",
            address: AUParameterAddress(1),
            min: 0,
            max: 10,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let phaseDistortion = AUParameterTree.createParameter(
            withIdentifier: "phaseDistortion",
            name: "Amount of distortion, within the range [-1, 1]. 0 is no distortion.",
            address: AUParameterAddress(2),
            min: -1,
            max: 1,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let detuningOffset = AUParameterTree.createParameter(
            withIdentifier: "detuningOffset",
            name: "Frequency offset (Hz)",
            address: AUParameterAddress(3),
            min: -1_000,
            max: 1_000,
            unit: .hertz,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )
        let detuningMultiplier = AUParameterTree.createParameter(
            withIdentifier: "detuningMultiplier",
            name: "Frequency detuning multiplier",
            address: AUParameterAddress(4),
            min: 0.9,
            max: 1.11,
            unit: .generic,
            unitName: nil,
            flags: flags,
            valueStrings: nil,
            dependentParameters: nil
        )

        setParameterTree(AUParameterTree.createTree(withChildren: [frequency, amplitude, phaseDistortion, detuningOffset, detuningMultiplier]))
        frequency.value = 440
        amplitude.value = 1
        phaseDistortion.value = 0
        detuningOffset.value = 0
        detuningMultiplier.value = 1
    }

    public override var canProcessInPlace: Bool { get { return true; } }

}
