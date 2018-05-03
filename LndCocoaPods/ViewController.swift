//
//  ViewController.swift
//  LndCocoaPods
//
//  Created by Johan Torås Halseth on 04/04/2018.
//  Copyright © 2018 Johan Torås Halseth. All rights reserved.
//

import UIKit
import Lndmobile

class ViewController: UIViewController {

    var appDir: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let filemgr = FileManager.default
        let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)

        let dir = dirPaths[0].path

        let path = Bundle.main.path(forResource: "lnd", ofType: "conf")
        let tt = try? String(contentsOfFile: path!, encoding: .utf8)

        let confFile = dir + "/lnd.conf"

        do {
            try filemgr.removeItem(atPath: confFile)
        }
        catch let error as NSError {
            print("Error deleting lnd.conf: \(error)")
        }

        do {
            try filemgr.copyItem(atPath: path!, toPath: confFile)
        }
        catch let error as NSError {
            print("Error copying lnd.conf: \(error)")
            return
        }

        print("Current dir: \(dir)")
        print("conf dir: \(path)")
        print("conf: \(tt)")

        appDir = dir

        class Callback: NSObject, LndmobileCallbackProtocol {
            func onError(_ p0: Error!) {
                print("error")
            }

            func onResponse(_ p0: Data!) {
                print("started")
            }
        }

        LndmobileStart(dir, Callback())

        let button = UIButton(frame: CGRect(x: 50, y: 50, width: 200, height: 50))
        button.backgroundColor = .green
        button.setTitle("push me", for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        self.view.addSubview(button)
    }

    @objc
    func buttonPressed() {

        print("Button tapped")

        var addr = Lnrpc_NewAddressRequest()
        addr.type = Lnrpc_NewAddressRequest.AddressType.nestedPubkeyHash
//
        let data = try! addr.serializedData()

//        let nodeInfo = Lnrpc_NodeInfoRequest.with {
//            $0.pubKey = "022bb78ab9df617aeaaf37f6644609abb7295fad0c20327bccd41f8d69173ccb49"
//        }
////        nodeInfo.pubKey = "022bb78ab9df617aeaaf37f6644609abb7295fad0c20327bccd41f8d69173ccb49"
//
//        let getInfo = Lnrpc_GetInfoRequest()
//        let data = try! nodeInfo.serializedData()
//        let data = try! getInfo.serializedData()

        class Callback: NSObject, LndmobileCallbackProtocol {
            func onError(_ p0: Error!) {
                print("error: \(p0)")
            }

            func onResponse(_ p0: Data!) {
//                let info = try! Lnrpc_GetInfoResponse(serializedData: p0)
//                let info = try! Lnrpc_NodeInfo(serializedData: p0)
                let info = try! Lnrpc_NewAddressResponse(serializedData: p0)
                print("info: \(info)")
            }
        }

        print("data len: \(data.count)")

        LndmobileNewAddress(data, Callback())
//        LndmobileGetNodeInfo(data, Callback())
//        LndmobileGetInfo(data, Callback())
        print("button done")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}

