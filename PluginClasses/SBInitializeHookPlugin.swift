//
//  ZappGeneralIPHookPlugin.swift
//  Zapp-App
//
//  Created by user on 17/12/2018.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

import Foundation
import ZappPlugins
import SugarBoxSDK


@objc public class SBInitializeHookPlugin : NSObject, ZPAppLoadingHookProtocol,ConnectivityDelegates {
    public func wifiConnected() {
        print("Got SB Wifi")
        let dataDict:[String: String] = ["name": "Amit"]
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SB_SSID_AVAILABLE"), object: nil, userInfo: dataDict)
            
        }
    }
    
    public func wifiDisconnected() {
        print("Got Disconnect")

    }
    
    public func wifiConnectionError(_ message: String) {
        
    }
    
    public func requireAuthentication() {
        print("Auth Required")
        //let sessionStorageUtil = SessionStorageUtils();
       // ZAAppConnector.sharedInstance().storageDelegate

        
    }
    
    public func onAuthenticationSuccess() {
        
    }
    
    public func onAuthenticationError(_ message: String) {
        
    }
    
    
    //MARK: - Consts variables
    public let entryPointKey = "entry_point"
    public let errorMessageKey = "unauthorized_message"
    public let authorizeIpArrayKey = "authorize_ip_array"
    
    public let errorMessageTextStyleKey = "text_style"
    public let errorMessageDialogBgColorKey = "dialog_bg_color"
    

    static var context:SugarBoxContext? = nil

    
    
    //MARK: - public variables
    public var configurationJSON: NSDictionary?
    
    //MARK: - Private variables
    private var ipResult: String? = nil
    
    //MARK: - Mandatory methods
    public required override init() {
        super.init()
    }
    
    public required convenience init(configurationJSON: NSDictionary?) {
        self.init()
        self.configurationJSON = configurationJSON
    }
    
    //MARK: - ZPAppLoadingHookProtocol implementation
    @objc public func executeOnLaunch(completion: (() -> Void)?){
        
        print("inside sugarbox plugin on launch")
        var sdkKey:String?
        var partnerId:String?
        var appVersion:String?
        if let config = configurationJSON
        {
            sdkKey = config.value(forKey: "sdk_key") as? String
            partnerId = config.value(forKey: "partner_id") as? String
            appVersion = config.value(forKey: "app_version") as? String
        }
       // var sdkKey = configuratio
        SBInitializeHookPlugin.context = SugarBoxContext.shared(Credentials.shared(sdkKey ?? "fe40b221-4ac0-458a-bd56-33ffbe3c4b83", partnerId ?? "3", appVersion ?? "1", nil),self)
        completion?()
    }
    
    //MARK: - Private Methods implementation
    private func showErrorDialog(){
        guard let configuration = self.configurationJSON,
            let message = configuration[errorMessageKey] as? String,
            !message.isEmpty,
            let zappStyle = configuration[errorMessageTextStyleKey] as? String,
            !zappStyle.isEmpty,
            let bgColor = configuration[errorMessageDialogBgColorKey] as? String,
            !bgColor.isEmpty
            else {
                return
        }
        
        let errorViewController = ZappHookErrorViewController.init(backgroundColor:bgColor, errorMessage: message, zappStyleKey: zappStyle)
        DispatchQueue.main.async{
            
            let win = UIWindow(frame: UIScreen.main.bounds)
            let vc = UIViewController()
            vc.view.backgroundColor = .clear
            win.rootViewController = vc
            win.windowLevel = UIWindow.Level.alert + 1
            win.makeKeyAndVisible()
            vc.present(errorViewController, animated: true, completion: nil)
            
            //ZAAppConnector.sharedInstance().navigationDelegate.present(errorViewController, presentationType: .push, animated: false)
        }
    }
    
    private func checkValidation() -> Bool{
        if let configuration = self.configurationJSON,
            let ipsStringArray = configuration[authorizeIpArrayKey] as? String{
            let ipsArray = ipsStringArray.components(separatedBy: ",")
            print("result:", self.ipResult as Any, " array:",ipsArray)

            for ip in ipsArray{
                if String(ip) == self.ipResult{
                    print("validation succeded")
                    return true
                }
            }
        }
        print("validation failed")
        return false
    }
    
    
    private func sendURL(url:URL, finished: @escaping ((_ isSucceeded: Bool)->Void)){
        let request = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            if responseError != nil{
                print("Login Request failed with error: \(String(describing: responseError))")
                return finished(false)
            }
            
            if responseData != nil{
                var jsonData:[String:String]?
                do {
                    jsonData = try JSONSerialization.jsonObject(with:responseData!, options: .mutableContainers) as? [String:String]
                }
                catch _ as NSError {
                    return finished(false)
                }
                
                if jsonData?["result"] != nil{
                    self.ipResult = jsonData?["result"]
                    return finished(true)
                }
            }
            return finished(false)
        }
        task.resume()
    }
}
