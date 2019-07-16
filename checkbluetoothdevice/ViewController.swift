//
//  ViewController.swift
//  checkbluetoothdevice
//
//  Created by Raymond Nnadi on 19/06/19.
//  Copyright © 2017 Raymond Nnadi. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate,CBPeripheralDelegate
{
    var centralManager: CBCentralManager?
    var peripherals: Array<CBPeripheral> = Array<CBPeripheral>()
    var Rssivalue = [NSNumber]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Initialise CoreBluetooth Central Manager
        centralManager = CBCentralManager.init(delegate: self, queue: DispatchQueue.main, options:nil)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    
    //CoreBluetooth methods
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        if (central.state == .poweredOn)
        {
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
        else
        {
            // do something like alert the user that ble is not on
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {

        //self.centralManager?.connect(peripheral, options: nil)
        peripheral.readRSSI()
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {

        peripheral.readRSSI()
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral)
        {
            //self.centralManager?.connect(peripheral, options: nil)
            peripherals.append(peripheral)
            Rssivalue.append(NSNumber.init(integerLiteral: 0))
            tableView.reloadData()
        }
        self.centralManager?.connect(peripheral, options: nil)
        peripheral.delegate = self
        peripheral.readRSSI()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if peripherals.contains(peripheral)
        {
            Rssivalue[peripherals.index(of: peripheral)!] = RSSI
            tableView.reloadData()
        }
    }
    
    
    //UITableView methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        let peripheral = peripherals[indexPath.row]
        var StringName = ""
        if peripheral.name != "" && peripheral.name != nil
        {
            StringName = String("\(peripheral.name!)")
        }
        else
        {
            StringName = "Unnamed"
        }
        if peripheral.state != CBPeripheralState.connected
        {
            StringName = StringName.appending(" still connect rssi:\(Rssivalue[indexPath.row])")
        }
        else
        {
            StringName = StringName.appending(" not connect rssi:\(Rssivalue[indexPath.row])")
        }
        cell.textLabel?.text = StringName
        for item in cell.contentView.subviews
        {
            if item.tag == -55
            {
                item.removeFromSuperview()
            }
        }
        var oneThing = 4
        if abs(Int(Rssivalue[indexPath.row])) > 20
        {
            oneThing = 3
        }
        if abs(Int(Rssivalue[indexPath.row])) > 40
        {
            oneThing = 2
        }
        if abs(Int(Rssivalue[indexPath.row])) > 60
        {
            oneThing = 1
        }
        if abs(Int(Rssivalue[indexPath.row])) > 80
        {
            oneThing = 0
        }
        if abs(Int(Rssivalue[indexPath.row])) > 100 || abs(Int(Rssivalue[indexPath.row])) == 0
        {
            oneThing = -1
        }
        for index in 0...4
        {
            let xvalue1 = (30/5)*CGFloat(index)+cell.contentView.frame.size.width-30
            let height1 = CGFloat(30/5)+CGFloat(index)*CGFloat(30/5);
            let yvalue1 = 5+30 - CGFloat(index)*CGFloat(30/5);
            let lable2 = UILabel()
            lable2.frame = CGRect(x: xvalue1, y: yvalue1, width: 3, height: height1)
            lable2.tag = -55
            lable2.backgroundColor = UIColor.lightGray
            lable2.textAlignment = .center
            cell.contentView.addSubview(lable2)
            if oneThing >= index
            {
                lable2.backgroundColor = UIColor.blue
            }
        }
        //cell.detailTextLabel?.text = peripheral.identifier.uuidString
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return peripherals.count
    }
}

