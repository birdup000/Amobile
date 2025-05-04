//
//  SpeechStreamRecognizer.swift
//  Runner
//
//  Created by edy on 2024/4/16.
//
import AVFoundation
import Speech

class SpeechStreamRecognizer {
    static let shared = SpeechStreamRecognizer()
    
    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var lastRecognizedText: String = "" // latest accepeted recognized text
    // private var previousRecognizedText: String = ""
    let languageDic = [
        "CN": "zh-CN",
        "EN": "en-US",
        "RU": "ru-RU",
        "KR": "ko-KR",
        "JP": "ja-JP",
        "ES": "es-ES",
        "FR": "fr-FR",
        "DE": "de-DE",
        "NL": "nl-NL",
        "NB": "nb-NO",
        "DA": "da-DK",
        "SV": "sv-SE",
        "FI": "fi-FI",
        "IT": "it-IT"
    ]
    
    let dateFormatter = DateFormatter()
    
    private var lastTranscription: SFTranscription? // cache to make contrast between near results
    private var cacheString = "" // cache stream recognized formattedString
    
    private let wakeWord = "agixt"
    
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    private init() {
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        if #available(iOS 13.0, *) {
            Task {
                do {
                    guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                        throw RecognizerError.notAuthorizedToRecognize
                    }
                    /*
                     guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                     throw RecognizerError.notPermittedToRecord
                     }*/
                } catch {
                    print("SFSpeechRecognizer------permission error----\(error)")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func startRecognition(identifier: String) {
        lastTranscription = nil
        self.lastRecognizedText = ""
        cacheString = ""
        
        let localIdentifier = languageDic[identifier]
        print("startRecognition----localIdentifier----\(localIdentifier)--identifier---\(identifier)---")
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: localIdentifier ?? "en-US"))  // en-US zh-CN en-US
        guard let recognizer = recognizer else {
            print("Speech recognizer is not available")
            return
        }
        
        guard recognizer.isAvailable else {
            print("startRecognition recognizer is not available")
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //try audioSession.setCategory(.record)
            try audioSession.setCategory(.playback, options: .mixWithOthers)
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("Failed to create recognition request")
            return
        }
        recognitionRequest.shouldReportPartialResults = true //true
        recognitionRequest.requiresOnDeviceRecognition = true
        
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] (result, error) in
            guard let self = self else { return }
            if let error = error {
                print("SpeechRecognizer Recognition error: \(error)")
            } else if let result = result {
                let transcription = result.bestTranscription.formattedString
                self.processTranscription(transcription)
                
                if lastTranscription == nil {
                    cacheString = result.bestTranscription.formattedString
                } else {
                    if (result.bestTranscription.segments.count < lastTranscription?.segments.count ?? 1 || result.bestTranscription.segments.count == 1) {
                        self.lastRecognizedText += cacheString
                        cacheString = ""
                    } else {
                        cacheString = result.bestTranscription.formattedString
                    }
                }
                
                lastTranscription = result.bestTranscription
            }
        }
    }
    
    func stopRecognition() {
        print("stopRecognition-----self.lastRecognizedText-------\(self.lastRecognizedText)------cacheString----------\(cacheString)---")
        self.lastRecognizedText += cacheString
        
        // First display the transcription on the glasses
        DispatchQueue.main.async {
            // Show transcription on glasses display first
            let transcriptionDict: [String: Any] = ["display_transcription": self.lastRecognizedText]
            BluetoothManager.shared.channel.invokeMethod("displayTranscription", arguments: transcriptionDict)
            
            // Then after a delay, send the transcription to the AI assistant
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                BluetoothManager.shared.blueSpeechSink?(["script": self.lastRecognizedText])
            }
        }
        
        recognitionTask?.cancel()
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error stop audio session: \(error)")
            return
        }
        recognitionRequest = nil
        recognitionTask = nil
        recognizer = nil
    }
    
    func appendPCMData(_ pcmData: Data) {
        print("appendPCMData-------pcmData------\(pcmData.count)--")
        guard let recognitionRequest = recognitionRequest else {
            print("Recognition request is not available")
            return
        }

        let audioFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: false)!
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(pcmData.count) / audioFormat.streamDescription.pointee.mBytesPerFrame) else {
            print("Failed to create audio buffer")
            return
        }
        audioBuffer.frameLength = audioBuffer.frameCapacity

        pcmData.withUnsafeBytes { (bufferPointer: UnsafeRawBufferPointer) in
            if let audioDataPointer = bufferPointer.baseAddress?.assumingMemoryBound(to: Int16.self) {
                let audioBufferPointer = audioBuffer.int16ChannelData?.pointee
                audioBufferPointer?.initialize(from: audioDataPointer, count: pcmData.count / MemoryLayout<Int16>.size)
                recognitionRequest.append(audioBuffer)
            } else {
                print("Failed to get pointer to audio data")
            }
        }
    }
    
    func startWakeWordDetection() {
        startRecognition(identifier: "EN")
    }

    func processTranscription(_ transcription: String) {
        if transcription.lowercased().contains(wakeWord) {
            triggerAGiXTWorkflow(transcription)
        }
    }

    private func triggerAGiXTWorkflow(_ transcription: String) {
        print("Wake word detected: \(transcription)")
        
        // Extract the command after the wake word
        if let range = transcription.range(of: wakeWord, options: .caseInsensitive) {
            let commandStart = transcription.index(range.upperBound, offsetBy: 0)
            let commandText = String(transcription[commandStart...]).trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Send command to AGiXT workflow via Flutter method channel
            DispatchQueue.main.async {
                let commandDict: [String: Any] = ["transcription": commandText]
                BluetoothManager.shared.channel.invokeMethod("processVoiceCommand", arguments: commandDict)
            }
        }
    }
    
    // Method to automatically start wake word detection when app starts
    func autoStartWakeWordDetection() {
        // Start continuous listening for wake word
        startWakeWordDetection()
        
        // Setup timer to periodically restart recognition if it stops
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            if self?.recognitionTask == nil {
                self?.startWakeWordDetection()
            }
        }
    }
}

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}


