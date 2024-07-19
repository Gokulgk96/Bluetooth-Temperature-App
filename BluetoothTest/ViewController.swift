//
//  ViewController.swift
//  BluetoothTest
//
//  Created by Gokul Gopalakrishnan on 25/05/24.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var centralManager: CBCentralManager!
    var peripherals: [String] = []
    var totalPeripheralsDetails: [CBPeripheral] = []
    var connectedPeripheral: CBPeripheral?
    static let serviceUUID = CBUUID(string: "FFE0")
    var transferCharacteristic: CBCharacteristic?
    static let characteristicUUID = CBUUID(string: "FFE1")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(peripherals[indexPath.row]) -- \(totalPeripheralsDetails[indexPath.row].state.rawValue)"
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(totalPeripheralsDetails[indexPath.row])
        centralManager.connect(totalPeripheralsDetails[indexPath.row])
        tableView.reloadData()
    }
    
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("Is Powered Off.")
        case .poweredOn:
            print("Is Powered On.")
            self.centralManager.scanForPeripherals(withServices: nil)
        case .unsupported:
            print("Is Unsupported.")
        case .unauthorized:
            print("Is Unauthorized.")
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        @unknown default:
            print("Error")
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let bluetoothName = peripheral.name, !peripherals.contains(bluetoothName) {
            print(peripheral.identifier.uuidString)
            totalPeripheralsDetails.append(peripheral)
            peripherals.append(bluetoothName)
            print(advertisementData)
        }
        tableView.reloadData()
    }
    
    // In CBCentralManagerDelegate class/extension
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Successfully connected. Store reference to peripheral if not already done.
        peripheral.delegate = self
        self.connectedPeripheral = peripheral
        peripheral.discoverServices([ViewController.serviceUUID])
        print("did Connect")
        print("connected peripheral is = \(String(describing: peripheral.name))")
        print("------------------------")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        self.connectedPeripheral = nil
        print("did Disconnect Peripheral")
        print("Disconnected peripheral is = \(String(describing: peripheral.name))")
        tableView.reloadData()
        print("------------------------")
    }
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        if let error = error {
            return
        }
        
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
            peripheral.discoverCharacteristics([ViewController.characteristicUUID], for: service)
        }
        
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error = error {
            return
        }
        
        // Again, we loop through the array, just in case and check if it's the right one
        guard let serviceCharacteristics = service.characteristics else { return }
        for characteristic in serviceCharacteristics where characteristic.uuid == ViewController.characteristicUUID {
            // If it is, subscribe to it
            transferCharacteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
         //   peripheral.writeValue("Hello".data(using: .utf8)!, for: characteristic, type: .withResponse)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let characteristicData = characteristic.value?.first
           //   let stringFromData = String(data: characteristicData, encoding: .utf8)
        else { return }
        print(characteristic.value)
        print(characteristicData)
        print(type(of: characteristicData))
     //   print(stringFromData)
       // print(type(of: stringFromData))
        print(type(of: characteristic.value))
        temperatureLabel.text = "\(Int(characteristicData)) C"
    }
}
