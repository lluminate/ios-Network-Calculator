//
//  ContentView.swift
//  ios Network Calculator
//
//  Created by Victor Yang on 2023-07-22.
//

import SwiftUI

let maskBitsOptions = [
    "30",
    "29",
    "28",
    "27",
    "26",
    "25",
    "24",
    "23",
    "22",
    "21",
    "20",
    "19",
    "18",
    "17",
    "16",
    "15",
    "14",
    "13",
    "12",
    "11",
    "10",
    "9",
    "8",
    "7",
    "6",
    "5",
    "4",
    "3",
    "2",
    "1"
]

let subnetMaskOptions = [
    "255.255.255.252",
    "255.255.255.248",
    "255.255.255.240",
    "255.255.255.224",
    "255.255.255.192",
    "255.255.255.128",
    "255.255.255.0",
    "255.255.254.0",
    "255.255.252.0",
    "255.255.248.0",
    "255.255.240.0",
    "255.255.224.0",
    "255.255.192.0",
    "255.255.128.0",
    "255.255.0.0",
    "255.254.0.0",
    "255.252.0.0",
    "255.248.0.0",
    "255.240.0.0",
    "255.224.0.0",
    "255.192.0.0",
    "255.128.0.0",
    "255.0.0.0",
    "254.0.0.0",
    "252.0.0.0",
    "248.0.0.0",
    "240.0.0.0",
    "224.0.0.0",
    "192.0.0.0",
    "128.0.0.0"
]

let hostsOptions = [
    "2",
    "6",
    "14",
    "30",
    "62",
    "126",
    "254",
    "510",
    "1022",
    "2046",
    "4094",
    "8190",
    "16382",
    "32766",
    "65534",
    "131070",
    "262142",
    "524286",
    "1048574",
    "2097150",
    "4194302",
    "8388606",
    "16777214",
    "33554430",
    "67108862",
    "134217726",
    "268435454",
    "536870910",
    "1073741822",
    "2147483646"
]

struct ContentView: View {
    @State private var maskBitsSelection = "30"
    @State private var subnetMaskSelection = "255.255.255.252"
    @State private var hostsSelection = "2"
    @State private var ipInput = "192.168.0.2"
    @State private var selectedRadioOption = "Dec"
    
    var body: some View {
        VStack {
            Text("NETWORK CALCULATOR")
                .padding(.bottom, 50)
            .font(.title.bold())
            
            Grid(alignment: .leading) {
                GridRow {
                    Text("IP:")
                    TextField(
                        "Type here...",
                        text: $ipInput
                    )
                    .frame(maxWidth: 200)
                }
                
                GridRow {
                    Text("Mask Bits:")
                    Picker("Select mask bits", selection: $maskBitsSelection) {
                        ForEach(maskBitsOptions, id: \.self) {
                            Text($0)
                        }
                    }.onChange(of: maskBitsSelection) {
                        let (_, subnetMask, hosts) = maskBitsFunction(maskBits: Int(maskBitsSelection) ?? 0)
                        subnetMaskSelection = subnetMask
                        hostsSelection = String(hosts)
                    }
                }
                
                
                GridRow {
                    Text("Subnet Mask:")
                    Picker("Select subnet mask", selection: $subnetMaskSelection) {
                        ForEach(subnetMaskOptions, id: \.self) {
                            Text($0)
                        }
                    }.onChange(of: subnetMaskSelection) {
                        let (maskBits, _, hosts) = subnetMaskFunction(subnetMask: subnetMaskSelection)
                        maskBitsSelection = String(maskBits)
                        hostsSelection = String(hosts)
                    }
                }
                
                GridRow {
                    Text("Hosts:")
                    Picker("Select hosts", selection: $hostsSelection) {
                        ForEach(hostsOptions, id: \.self) {
                            Text($0)
                        }
                    }.onChange(of: hostsSelection) {
                        let (maskBits, subnetMask, _) = hostsFunction(hosts: Int(hostsSelection) ?? 0)
                        maskBitsSelection = String(maskBits)
                        subnetMaskSelection = subnetMask
                    }
                }
            }
            
            
            Picker(selection: $selectedRadioOption, label: Text("Notation Selection")) {
                Text("Dec").tag("Dec")
                Text("Hex").tag("Hex")
                Text("Bin").tag("Bin")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if isValidIPAddress(ipInput) {
                TabView(selection: $selectedRadioOption) {
                    let (upperRange, lowerRange, broadcast) = ipRange(maskBits: Int(maskBitsSelection) ?? 0, ip: ipInput)
                    Grid(alignment: .leading) {
                        GridRow {
                            Text("Network:")
                            Text(ipToNetwork(ipInput) + "/" + maskBitsSelection)
                        }
                        GridRow {
                            Text("Netmask:")
                            Text(subnetMaskSelection)
                        }
                        GridRow {
                            Text("IP Range:")
                            Text(lowerRange)
                        }
                        GridRow {
                            Text("")
                            Text(upperRange)
                        }
                        GridRow {
                            Text("Hosts:")
                            Text(hostsSelection)
                        }
                        GridRow {
                            Text("Broadcast:")
                            Text(broadcast)
                        }
                    }.tag("Dec").padding()
                    
                    Grid(alignment: .leading) {
                        GridRow {
                            Text("Network:")
                            Text(ipToHex(ipToNetwork(ipInput)) + "/" + String(format: "%02X", Int(maskBitsSelection) ?? 0))
                        }
                        GridRow {
                            Text("Netmask:")
                            Text(ipToHex(subnetMaskSelection))
                        }
                        GridRow {
                            Text("IP Range:")
                            Text(ipToHex(lowerRange))
                        }
                        GridRow {
                            Text("")
                            Text(ipToHex(upperRange))
                        }
                        GridRow {
                            Text("Hosts:")
                            Text(String(format: "%02X", Int(hostsSelection) ?? 0))
                        }
                        GridRow {
                            Text("Broadcast:")
                            Text(ipToHex(broadcast))
                        }
                    }.tag("Hex").padding()
                    
                    Grid(alignment: .leading) {
                        GridRow {
                            Text("Network:")
                            Text(ipToBinary(ipToNetwork(ipInput))).minimumScaleFactor(0.01).scaledToFit()
                        }
                        GridRow {
                            Text("Netmask:")
                            Text(ipToBinary(ipToNetwork(ipInput))).minimumScaleFactor(0.01).scaledToFit()
                        }
                        GridRow {
                            Text("IP Range:")
                            Text(ipToBinary(lowerRange)).minimumScaleFactor(0.01).scaledToFit()
                        }
                        GridRow {
                            Text("")
                            Text(ipToBinary(upperRange)).minimumScaleFactor(0.01).scaledToFit()
                        }
                        GridRow {
                            Text("Broadcast:")
                            Text(ipToBinary(broadcast)).minimumScaleFactor(0.01).scaledToFit()
                        }
                    }.tag("Bin").padding()
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(maxHeight: 200)
            } else {
                TabView(selection: $selectedRadioOption) {
                    Text("Invalid IP Address").tag("Dec")
                    Text("Invalid IP Address").tag("Hex")
                    Text("Invalid IP Address").tag("Bin")
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(maxHeight: 200)
            }
        }
    }
}

extension String {
    func paddedToLength(_ length: Int, withPad padCharacter: String) -> String? {
        if length <= count {
            return self
        }
        
        var paddedString = self
        while paddedString.count < length {
            paddedString = padCharacter + paddedString
        }
        
        return paddedString
    }
}

func ipToHex(_ ip: String) -> String {
    var hex = ""
    for i in ip.split(separator: ".") {
        hex += String(format: "%02X", Int(i) ?? 0) + "."
    }
    return String(hex.dropLast(1))
}

func ipToBinary(_ ip: String) -> String {
    var binary = ""
    let octets = ip.split(separator: ".")
    
    for octetString in octets {
        if let octetInt = Int(octetString), let octetBinary = String(octetInt, radix: 2).paddedToLength(8, withPad: "0") {
            binary += octetBinary
        }
    }
    
    return binary
}

func binaryToIP(_ binary: String) -> String {
    var ip = ""
    var startIndex = binary.startIndex
    var endIndex = binary.index(startIndex, offsetBy: 8, limitedBy: binary.endIndex) ?? binary.endIndex

    while startIndex < binary.endIndex {
        let octetBinary = binary[startIndex..<endIndex]
        if let octetInt = Int(octetBinary, radix: 2) {
            ip += "\(octetInt)"
        }
        
        startIndex = endIndex
        endIndex = binary.index(startIndex, offsetBy: 8, limitedBy: binary.endIndex) ?? binary.endIndex

        if startIndex < binary.endIndex {
            ip += "."
        }
    }
    
    return ip
}

func ipToNetwork(_ ip: String) -> String {
    let binaryIP = ipToBinary(ip)
    let networkBinary = String(binaryIP.prefix(binaryIP.count - 8) + "00000000")
    return binaryToIP(networkBinary)
}

func isValidIPAddress(_ ip: String) -> Bool {
    let segments = ip.split(separator: ".")
    
    if segments.count != 4 {
        return false
    }
    
    for segment in segments {
        guard let intValue = Int(segment) else {
            return false
        }
        
        if !(0...225).contains(intValue) {
            return false
        }
    }
    
    return true
}

func ipRange(maskBits: Int, ip: String) -> (String, String, String) {
    var lower = ""
    var upper = ""

    for _ in 0..<(32 - maskBits) {
        lower += "0"
        upper += "1"
    }

    let binaryIP = ipToBinary(ip)
    let networkPart = String(binaryIP.prefix(binaryIP.count - (32 - maskBits)))
    let broadcastBinary = networkPart + upper
    lower = String(lower.dropLast()) + "1"
    upper = String(upper.dropLast()) + "0"

    let lowerIP = binaryToIP(networkPart + lower)
    let upperIP = binaryToIP(networkPart + upper)
    let broadcastIP = binaryToIP(broadcastBinary)

    return (String(lowerIP), String(upperIP), String(broadcastIP))
}

func maskBitsFunction(maskBits: Int) -> (Int, String, Int) {
    let hosts = Int(pow(2, Double(32 - maskBits))) - 2
    var binary = ""
    var subnetMask = ""

    for _ in 0..<maskBits {
        binary += "1"
    }
    
    for _ in 0..<(32 - maskBits) {
        binary += "0"
    }

    for i in stride(from: 0, to: binary.count, by: 8) {
        let startIndex = binary.index(binary.startIndex, offsetBy: i)
        let endIndex = binary.index(startIndex, offsetBy: 8, limitedBy: binary.endIndex) ?? binary.endIndex
        let octetBinary = binary[startIndex..<endIndex]
        if let octetInt = Int(octetBinary, radix: 2) {
            subnetMask += "\(octetInt)"
        }
        
        if i < binary.count - 8 {
            subnetMask += "."
        }
    }

    return (maskBits, subnetMask, hosts)
}

func subnetMaskFunction(subnetMask: String) -> (Int, String, Int) {
    var maskBits = 0
    var binary = ""

    for octetString in subnetMask.split(separator: ".") {
        if let octetInt = Int(octetString), let octetBinary = String(octetInt, radix: 2).paddedToLength(8, withPad: "0") {
            binary += octetBinary
            for bit in octetBinary {
                if bit == "1" {
                    maskBits += 1
                }
            }
        }
    }

    return (maskBits, subnetMask, Int(pow(2, Double(32 - maskBits))) - 2)
}

func hostsFunction(hosts: Int) -> (Int, String, Int) {
    let maskBits = 32 - Int(log2(Double(hosts + 2)))
    var binary = ""
    var subnetMask = ""

    for _ in 0..<maskBits {
        binary += "1"
    }

    for _ in 0..<(32 - maskBits) {
        binary += "0"
    }

    for i in stride(from: 0, to: binary.count, by: 8) {
        let startIndex = binary.index(binary.startIndex, offsetBy: i)
        let endIndex = binary.index(startIndex, offsetBy: 8, limitedBy: binary.endIndex) ?? binary.endIndex
        let octetBinary = binary[startIndex..<endIndex]
        if let octetInt = Int(octetBinary, radix: 2) {
            subnetMask += "\(octetInt)"
        }

        if i < binary.count - 8 {
            subnetMask += "."
        }
    }

    return (maskBits, subnetMask, hosts)
}

#Preview {
    ContentView()
}
