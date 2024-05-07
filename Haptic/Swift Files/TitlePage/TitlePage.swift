//TITLE SCREEN

import AVKit
import AVFoundation
import UIKit
import Foundation
import CoreText
import WatchConnectivity
import UserNotifications
import CoreBluetooth
    
class TitlePage: UIViewController, WCSessionDelegate, UNUserNotificationCenterDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource {
    var session: WCSession?
    let button = UIButton(type: .system)
    let button2 = UIButton(type: .system)
    var centralManager: CBCentralManager!
    var writableCharacteristic: CBCharacteristic?
    var connectedPeripheral: CBPeripheral?
    var discoveredPeripherals: [CBPeripheral] = []
    var isLedOn = false
    let yourCharacteristicUUID = CBUUID(string: "0000FFE1-0000-1000-8000-00805F9B34FB")
    var devicesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    
    override func viewDidLoad() {
            super.viewDidLoad()
        
        devicesTableView.delegate = self
            devicesTableView.dataSource = self
            view.addSubview(devicesTableView)
        
        NSLayoutConstraint.activate([
               devicesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
               devicesTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
               devicesTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
               devicesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
           ])
           
           devicesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        if #available(iOS 13.0, *) {
                    // Override user interface style to light mode for this view controller
                    overrideUserInterfaceStyle = .light
                }
        centralManager = CBCentralManager(delegate: self, queue: nil)
               self.view.backgroundColor = .black
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("Notification permission granted.")
                } else if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
            }
               // Setup Watch Connectivity session
               if WCSession.isSupported() {
                   session = WCSession.default
                   session?.delegate = self
                   session?.activate()
               }
               
               // Create the button

               button.setTitle("Buzz Watch", for: .normal)
               button.setTitleColor(.black, for: .normal)
               button.backgroundColor = .white
               button.layer.cornerRadius = 10
               button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
               
               // Set button frame or use Auto Layout
               button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
               button.center = view.center
                button.isHidden = true
               // Add the button to the view
               self.view.addSubview(button)
        
        button2.setTitle("Light Show", for: .normal)
        button2.setTitleColor(.black, for: .normal)
        button2.backgroundColor = .white
        button2.layer.cornerRadius = 10
        button2.addTarget(self, action: #selector(button2Tapped), for: .touchUpInside)
        
        // Set button frame or use Auto Layout
        button2.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        button2.center = view.center
        button2.center.y = button.center.y + (button.frame.size.height * 2)
        button2.isHidden = true
        // Add the button to the view
        self.view.addSubview(button2)
       
        
        }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }

   
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(String(describing: peripheral.name))")

        // This checks if the discovered peripheral is not already in your array to avoid duplicates
        if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredPeripherals.append(peripheral)
            
            // Reload your UITableView on the main thread to display the newly discovered peripheral
            DispatchQueue.main.async {
                self.devicesTableView.reloadData()
            }
        }

        // Specific action for "BT05" peripheral
        if peripheral.name == "BT05" || peripheral.name == "DSD TECH" {
            centralManager.stopScan() // Stop scanning to save battery
            centralManager.connect(peripheral, options: nil) // Attempt to connect
        }
    }
    
   
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "HM-10")")
        connectedPeripheral = peripheral
        if peripheral.name == "BT05" || peripheral.name == "DSD TECH" {
            DispatchQueue.main.async {
                self.devicesTableView.isHidden = true  // Hide the tableView
                self.button.isHidden = false  // Show the button
                self.button2.isHidden = false
            }
        }
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedPeripheral = discoveredPeripherals[indexPath.row]
            centralManager.connect(selectedPeripheral, options: nil)
            // Optionally, show a loading indicator until connection is successful
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return discoveredPeripherals.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
           let peripheral = discoveredPeripherals[indexPath.row]
           cell.textLabel?.text = peripheral.name ?? "Unknown Device"
           return cell
       }

   
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            print("No services found")
            return
        }
        
        for service in services {
            // Discover characteristics for each service, replace nil with specific characteristic UUIDs if needed
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

  

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error receiving notification for characteristic \(characteristic.uuid): \(error.localizedDescription)")
            return
        }

        guard let data = characteristic.value else {
            print("No data received for characteristic \(characteristic.uuid)")
            return
        }

        // Optionally, convert data to a string if expected data is text
        let valueString = String(data: data, encoding: .utf8)
        print("Received notification for \(characteristic.uuid): \(valueString ?? "nil")")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics for service \(service.uuid): \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            print("No characteristics found for service \(service.uuid)")
            return
        }
        
        for characteristic in characteristics {
            print("Discovered characteristic \(characteristic.uuid)")

            // Subscribe to notifications for characteristics that support it
            if characteristic.properties.contains(.notify) || characteristic.properties.contains(.indicate) {
                peripheral.setNotifyValue(true, for: characteristic)
                print("Subscribed to notifications for \(characteristic.uuid)")
            }
        }
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            // Print out each discovered characteristic for debugging
            print("Discovered characteristic \(characteristic.uuid)")
            
            // Subscribe to notifications for characteristics that support it
            if characteristic.properties.contains(.notify) || characteristic.properties.contains(.indicate) {
                print("Subscribing to notifications for \(characteristic.uuid)")
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            // Check if this characteristic is the one you want to write to and if it supports writing
            if characteristic.uuid.isEqual(CBUUID(string: "0000FFE1-0000-1000-8000-00805F9B34FB")) {
                // Save this characteristic if you'll need to write to it later
                writableCharacteristic = characteristic
                
                // Check how to write based on characteristic's properties
                if characteristic.properties.contains(.writeWithoutResponse) {
                    // Prepare your command data
                    let commandString = "TOG\n"
                    if let data = commandString.data(using: .utf8) {
                        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
                        print("Writing \(commandString) to \(characteristic.uuid) with type .withoutResponse")
                    }
                } else if characteristic.properties.contains(.write) {
                    // Prepare your command data
                    let commandString = "TOG\n"
                    if let data = commandString.data(using: .utf8) {
                        peripheral.writeValue(data, for: characteristic, type: .withResponse)
                        print("Writing \(commandString) to \(characteristic.uuid) with type .withResponse")
                    }
                } else {
                    print("Characteristic \(characteristic.uuid) does not support writing.")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing to characteristic \(characteristic.uuid): \(error.localizedDescription)")
        } else {
            print("Successfully wrote to characteristic \(characteristic.uuid)")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Present the notification content while the app is in the foreground.
        // You can customize this to include sound, badge, banner, or list options.
        completionHandler([.banner, .sound])
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // Call your button tap action or directly call the method here
            buttonTapped()
        }
    }
    
    @objc func button2Tapped() {
        // TOG the LED state
           isLedOn = !isLedOn
        print("BUTTON TAP")
           // Prepare the command string based on the new state
        let commandString = "Lit\n"
           guard let data = commandString.data(using: .utf8) else { return }

           // Check if we have a connected peripheral and a writable characteristic
           guard let peripheral = connectedPeripheral, let characteristic = writableCharacteristic else {
               print("Peripheral or characteristic not available.")
               return
           }
           // Check the characteristic's properties to decide how to write the data
           if characteristic.properties.contains(.writeWithoutResponse) {
               print("Without Response Button")
               peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
           } else if characteristic.properties.contains(.write) {
               print("With Response Button")
               peripheral.writeValue(data, for: characteristic, type: .withResponse)
           } else {
               print("Characteristic does not support write operations")
               return
           }

           print("Sent \(commandString.trimmingCharacters(in: .whitespacesAndNewlines)) command to the peripheral.")
        
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "Haptic Trigger!", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "The watch should buzz now.", arguments: nil)
            content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "com.yourcompany.app.hapticFeedback", content: content, trigger: trigger) // Note: `trigger` is nil
        
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error : Error?) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            }
        
        
           // Check if the session is reachable
           if let validSession = session, validSession.isReachable {
               // Send a message to the Watch app
               let message = ["action": "hapticFeedback"]
               validSession.sendMessage(message, replyHandler: nil, errorHandler: nil)
           }
        
        // Generate haptic feedback
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()

            // Check if the session is reachable
            if session?.isReachable == true {
                // Send a message to the Watch app
                let message = ["action": "hapticFeedback"]
                session?.sendMessage(message, replyHandler: nil, errorHandler: { error in
                    print("Error sending message to Apple Watch: \(error.localizedDescription)")
                })
            }
        
       }
    
    
    
    @objc func buttonTapped() {
        // TOG the LED state
           isLedOn = !isLedOn
        print("BUTTON TAP")
           // Prepare the command string based on the new state
        let commandString = "TOG\n"
           guard let data = commandString.data(using: .utf8) else { return }

           // Check if we have a connected peripheral and a writable characteristic
           guard let peripheral = connectedPeripheral, let characteristic = writableCharacteristic else {
               print("Peripheral or characteristic not available.")
               return
           }
           // Check the characteristic's properties to decide how to write the data
           if characteristic.properties.contains(.writeWithoutResponse) {
               print("Without Response Button")
               peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
           } else if characteristic.properties.contains(.write) {
               print("With Response Button")
               peripheral.writeValue(data, for: characteristic, type: .withResponse)
           } else {
               print("Characteristic does not support write operations")
               return
           }

           print("Sent \(commandString.trimmingCharacters(in: .whitespacesAndNewlines)) command to the peripheral.")
        
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "Haptic Trigger!", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "The watch should buzz now.", arguments: nil)
            content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "com.yourcompany.app.hapticFeedback", content: content, trigger: trigger) // Note: `trigger` is nil
        
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error : Error?) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            }
        
        
           // Check if the session is reachable
           if let validSession = session, validSession.isReachable {
               // Send a message to the Watch app
               let message = ["action": "hapticFeedback"]
               validSession.sendMessage(message, replyHandler: nil, errorHandler: nil)
           }
        
        // Generate haptic feedback
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()

            // Check if the session is reachable
            if session?.isReachable == true {
                // Send a message to the Watch app
                let message = ["action": "hapticFeedback"]
                session?.sendMessage(message, replyHandler: nil, errorHandler: { error in
                    print("Error sending message to Apple Watch: \(error.localizedDescription)")
                })
            }
        
       }
       
       // WCSessionDelegate methods
       func sessionDidBecomeInactive(_ session: WCSession) {}
       func sessionDidDeactivate(_ session: WCSession) {}
       func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
   }
    
 
    
    
    

