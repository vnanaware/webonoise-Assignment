
//
//  AFWrapper.swift
//  ThinkGolf
//
//  Created by Mohsin Jamadar on 24/03/17.
//  Copyright © 2017 Vogcalgary App Developer. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit
import SVProgressHUD

@available(iOS 10.0, *)
class AFWrapper: NSObject
{
    
    class func requestGETURL(_ strURL: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        Alamofire.request(strURL).responseJSON { (responseObject) -> Void in
            
            print(responseObject)
            
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                success(resJson)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    
    class func requestPOSTURL(_ strURL : String, params : [String: Any]?, headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void)
    {
        UserDefaults.standard.removeObject(forKey: "status")
        
        Alamofire.request(strURL, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (responseObject) -> Void in
            
            //print(responseObject)
            
            if responseObject.result.isSuccess
            {
                let resJson = JSON(responseObject.result.value!)
                let isStatus=resJson["status"].stringValue
                
                //save info in userDefault
                UserDefaults.standard.set(isStatus, forKey: "status")
                success(resJson)
                if isStatus=="1"
                {
                    success(resJson)
                }
                else
                    if isStatus=="0"
                    {
                        dismissSpinner()
                        //showAlert("Sorry", message: "Sorry unable to fetch data", buttonTitle: "Ok")
                    }
                
                }
            else if responseObject.result.isFailure
            {
                 dismissSpinner()

                let error : Error = responseObject.result.error!
                failure(error)
                //showAlert("Sorry", message: error.localizedDescription, buttonTitle: "Ok")
            }
        }
    }
}
