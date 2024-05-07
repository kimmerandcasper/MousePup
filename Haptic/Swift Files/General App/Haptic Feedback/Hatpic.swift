import UIKit
import CoreHaptics

import Foundation

class Haptic {
    static var hapticEngine: CHHapticEngine?
    
    
    static func stateTimerFire() {
        if ((TitlePage.loggedInUser == SmerePlayers.player1.name) && ((SmerePlayers.player1.isTurn) || (SmerePlayers.player1.isBidder))) || ((TitlePage.loggedInUser == SmerePlayers.player2.name) && ((SmerePlayers.player2.isTurn) || (SmerePlayers.player2.isBidder))) || ((TitlePage.loggedInUser == SmerePlayers.player3.name) && ((SmerePlayers.player3.isTurn) || (SmerePlayers.player3.isBidder))) || ((TitlePage.loggedInUser == SmerePlayers.player4.name) && ((SmerePlayers.player4.isTurn) || (SmerePlayers.player4.isBidder))) {
            do {
                // Check if the device supports haptics
                guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
                
                // Create and start the haptic engine
                hapticEngine = try CHHapticEngine()
                try hapticEngine?.start()
                
                // Define the haptic pattern
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1) // Sharpness of the haptic. Range is 0 to 1.
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1) // Intensity of the haptic. Range is 0 to 1.
                
                // Create an event (transient or continuous) with the parameters
                let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 0.1) // Duration in seconds
                
                // Create a pattern with the event
                let pattern = try CHHapticPattern(events: [event], parameters: [])
                
                // Create a player to play the pattern
                let player = try hapticEngine?.makePlayer(with: pattern)
                try player?.start(atTime: CHHapticTimeImmediate) // Play immediately
            } catch {
                print("Failed to play custom haptic feedback: \(error)")
            }
        }
    }

static func stateTimerFire2() {
    if ((TitlePage.loggedInUser == SmerePlayers.player1.name) && ((SmerePlayers.player1.isTurn) || (SmerePlayers.player1.isBidder))) || ((TitlePage.loggedInUser == SmerePlayers.player2.name) && ((SmerePlayers.player2.isTurn) || (SmerePlayers.player2.isBidder))) || ((TitlePage.loggedInUser == SmerePlayers.player3.name) && ((SmerePlayers.player3.isTurn) || (SmerePlayers.player3.isBidder))) || ((TitlePage.loggedInUser == SmerePlayers.player4.name) && ((SmerePlayers.player4.isTurn) || (SmerePlayers.player4.isBidder))) {
        do {
            // Check if the device supports haptics
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
            
            // Create and start the haptic engine
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            
            // Define the haptic pattern
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1) // Sharpness of the haptic. Range is 0 to 1.
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1) // Intensity of the haptic. Range is 0 to 1.
            
            // Create an event (transient or continuous) with the parameters
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 2) // Duration in seconds
            
            // Create a pattern with the event
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            
            // Create a player to play the pattern
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate) // Play immediately
        } catch {
            print("Failed to play custom haptic feedback: \(error)")
        }
    }
}

    
    static func bidTappeHaptic() {
        if ((TitlePage.loggedInUser == SmerePlayers.player1.name) && (SmerePlayers.player1.isBidder)) || ((TitlePage.loggedInUser == SmerePlayers.player2.name) && (SmerePlayers.player2.isBidder)) || ((TitlePage.loggedInUser == SmerePlayers.player3.name) && (SmerePlayers.player3.isBidder)) || ((TitlePage.loggedInUser == SmerePlayers.player4.name) && (SmerePlayers.player4.isBidder)) {
            do {
                // Check if the device supports haptics
                guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
                
                // Create and start the haptic engine
                hapticEngine = try CHHapticEngine()
                try hapticEngine?.start()
                
                // Define the haptic pattern
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5) // Sharpness of the haptic. Range is 0 to 1.
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5) // Intensity of the haptic. Range is 0 to 1.
                
                // Create an event (transient or continuous) with the parameters
                let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 0.05) // Duration in seconds
                
                // Create a pattern with the event
                let pattern = try CHHapticPattern(events: [event], parameters: [])
                
                // Create a player to play the pattern
                let player = try hapticEngine?.makePlayer(with: pattern)
                try player?.start(atTime: CHHapticTimeImmediate) // Play immediately
            } catch {
                print("Failed to play custom haptic feedback: \(error)")
            }
        }
    }
    
    
    
    
    static func yourTurnHaptic() {
        do {
            // Check if the device supports haptics
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
            
            // Create and start the haptic engine
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            
            // Define the haptic pattern
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1) // Sharpness of the haptic. Range is 0 to 1.
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1) // Intensity of the haptic. Range is 0 to 1.
            
            // Create an event (transient or continuous) with the parameters
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 0.1) // Duration in seconds
            
            // Create a pattern with the event
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            
            // Create a player to play the pattern
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate) // Play immediately
        } catch {
            print("Failed to play custom haptic feedback: \(error)")
        }
    }
    
}
