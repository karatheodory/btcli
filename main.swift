#!/usr/bin/swift

import IOBluetooth

enum CustomError: Error {
    case noPairedDevices(errCode: Int32 = 1)
    case deviceNotFound(deviceMac: String, errCode: Int32 = 2)
    case deviceNotPaired(deviceMac: String, errCode: Int32 = 3)
    case failedToConnect(deviceMac: String, errCode: Int32 = 4)
    case failedToDisconnect(deviceMac: String, errCode: Int32 = 5)
}

func deviceName(device: IOBluetoothDevice) -> String {
    return device.name ?? "Unknown"
}

class Command {
    let name: String
    let description: String

    init(name: String, description: String) {
        self.name = name
        self.description = description
    }

    func run() throws {
        print("Called '\(name)' command")
    }
}

class ListCommand: Command {
    init() {
        super.init(name: "list", description: "List all paired devices")
    }

    func printDevice(device: IOBluetoothDevice) {
        print("Name: \(deviceName(device: device))")
        print("MAC Address: \(device.addressString ?? "Unknown")")
        print("Connected: \(device.isConnected())")
    }

    override func run() throws {
        guard let devices = IOBluetoothDevice.pairedDevices() else {
            throw CustomError.noPairedDevices()
        }

        for device in devices {
            if let device = device as? IOBluetoothDevice {
                printDevice(device: device)
                print("\n")
            }
        }
        print("\nTotal devices: \(devices.count)\n")
    }
}

class ConnectCommand: Command {
    var deviceMac: String {
        return CommandLine.arguments[2]
    }
    
    init() {
        super.init(name: "connect", description: "Connect to a device")
    }
    
    override func run() throws {
        guard let device = IOBluetoothDevice(addressString: deviceMac) else {
            throw CustomError.deviceNotFound(deviceMac: deviceMac)
        }

        if !device.isPaired() {
            throw CustomError.deviceNotPaired(deviceMac: deviceMac)
        }

        if !device.isConnected() && device.openConnection() == kIOReturnSuccess {
            print("Connected to \(deviceName(device: device))")
        } else {
            throw CustomError.failedToConnect(deviceMac: deviceMac)
        }
    }
}

class DisconnectCommand: Command {
    var deviceMac: String {
        return CommandLine.arguments[2]
    }

    init() {
        super.init(name: "disconnect", description: "Disconnect from a device")
    }

    func disconnectDevice(device: IOBluetoothDevice) throws {
        if device.isConnected() {
            if device.closeConnection() == kIOReturnSuccess {
                print("Disconnected from \(deviceName(device: device))")
            } else {
                throw CustomError.failedToDisconnect(deviceMac: deviceMac)
            }
        } else {
            print("Device \(deviceName(device: device)) is not connected, nothing to do")
        }
    }

    override func run() throws {
        guard let device = IOBluetoothDevice(addressString: deviceMac) else {
            throw CustomError.deviceNotFound(deviceMac: deviceMac)
        }

        try disconnectDevice(device: device)
    }
}

let availableCommands = [
    ListCommand(),
    ConnectCommand(),
    DisconnectCommand()
]

let cmdName = CommandLine.arguments[1]
let cmd = availableCommands.first { $0.name == cmdName }
if cmd == nil {
    print("Unknown command: \(cmdName)")
    exit(1)
}

do {
    try cmd?.run()
    exit(0)
} catch CustomError.noPairedDevices(let errCode) {
    print("No paired devices found")
    exit(errCode)
} catch CustomError.deviceNotFound(let deviceMac, let errCode) {
    print("Device \(deviceMac) not found")
    exit(errCode)
} catch CustomError.deviceNotPaired(let deviceMac, let errCode) {
    print("Device \(deviceMac) is not paired")
    exit(errCode)
} catch CustomError.failedToConnect(let deviceMac, let errCode) {
    print("Failed to connect to \(deviceMac)")
    exit(errCode)
} catch CustomError.failedToDisconnect(let deviceMac, let errCode) {
    print("Failed to disconnect from \(deviceMac)")
    exit(errCode)
}
