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

        let certUrl = URL(fileURLWithPath: dir+"/tls.cert")

        do {
            try filemgr.removeItem(at: certUrl)
        }
        catch let error as NSError {
            print("Error deleting tls.cert: \(error)")
        }

        let keyUrl = URL(fileURLWithPath: dir+"/tls.key")

        do {
            try filemgr.removeItem(at: keyUrl)
        }
        catch let error as NSError {
            print("Error deleting tls.key: \(error)")
        }

        print("Current dir: \(dir)")
        print("conf dir: \(path)")
        print("conf: \(tt)")

        appDir = dir

//        DispatchQueue.global(qos: .userInitiated).async {
//            LndbindingsStart(dir)
//        }

        let button = UIButton(frame: CGRect(x: 50, y: 50, width: 200, height: 50))
        button.backgroundColor = .green
        button.setTitle("push me", for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        self.view.addSubview(button)
    }

    @objc
    func buttonPressed() {

        print("Button tapped")
        let certUrl = URL(fileURLWithPath: appDir+"/tls.cert")
        let macaroonUrl = URL(fileURLWithPath: appDir+"/admin.macaroon")
        print("certUrl: \(certUrl). Macaroon: \(macaroonUrl)")
//        let certificateURL = Bundle.main.url(forResource: "tls",
//                                             withExtension: "cert")
//        print("cert url: \(certificateURL)")
        let certificates = try! String(contentsOf: certUrl)

        print("certificates: \(certificates)")

        let macaroonData = try! Data(contentsOf: macaroonUrl)


        let client = Lnrpc_LightningServiceClient(address: "localhost:10009", certificates: certificates, host: nil)
        client.metadata.add(key: "macaroon", value: macaroonData.hexEncodedString())
        let getInfo = Lnrpc_GetInfoRequest()

//        let resp = try? client.getInfo(getInfo)

        do {
            let resp = try client.getInfo(getInfo)
            print("response: \(resp)")
//        _ = try client.getInfo(getInfo) { responseMessage, callResult in
//            if let responseMessage = responseMessage {
//                print("got response \(responseMessage)")
//            } else {
//                print("No response received. \(callResult)")
//            }
//        }
        } catch {
            print("catch: \(error)")
        }
//        print("response \(resp)")
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

