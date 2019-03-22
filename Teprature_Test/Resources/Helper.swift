//
//  Helper.swift
//
//  Created by Mohsin on 9/4/15.
//  Copyright (c) 2017 All rights reserved.
//

import Foundation
import SVProgressHUD

//MARK: Global xConstants

//MARK: AppDelegate
let appDelegate = UIApplication.shared.delegate as! AppDelegate

//MARK: ScreenSizes
let screenWidth=UIScreen.main.bounds.size.width
let screenHeight=UIScreen.main.bounds.size.height

//MARK: Alerts
let vAlertButtonOk = "Ok"
let vAlertButtonCancel = "Cancel"
let vAlertTitleCommon = ""
let vAlertMessageNetworkConnection = "Make sure your device is connected to the internet."
let vAlertTitleNetworkConnection = "No Internet Connection"


typealias BasicBlock = () -> (Void)

//MARK: Spinner diclarations here
func showSpinner(_ message: String)
{
    SVProgressHUD.show(withStatus: message)
    SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
}

func dismissSpinner()
{
    SVProgressHUD.dismiss()
}

func dismissSpinnerWithError(_ message: String)
{
    SVProgressHUD.showError(withStatus: message)
}

func printLog(_ log: AnyObject?) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS "
    print(formatter.string(from: Date() as Date), terminator: "")
    if log == nil {
        print("nil")
    }
    else {
        print(log!)
    }
}

func dismissModalStack(_ viewController: UIViewController, animated: Bool, completionBlock: BasicBlock?) {
    if viewController.presentingViewController != nil {
        var vc = viewController.presentingViewController!
        while (vc.presentingViewController != nil) {
            vc = vc.presentingViewController!;
        }
        vc.dismiss(animated: animated, completion: nil)
        
        if let c = completionBlock {
            c()
        }
    }
}

func appendAuthorizationHeader(_ token: String?, request: NSMutableURLRequest) {
    if let t = token {
        request.setValue("Bearer \(t)", forHTTPHeaderField: "Authoxfvrization")
    }
}


extension UIColor
{
    convenience public init(r:CGFloat, g:CGFloat, b:CGFloat) {
        
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
