//
//  ViewController.swift
//  UNTAGGER
//
//  Created by Hunter Maximillion Monk on 5/10/15.
//  Copyright (c) 2015 Hunter Maximillion Monk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            // User is already logged in, do work such as go to next view controller.
            returnUserData("me/photos", after:nil)
        } else {
            let loginView = FBSDKLoginButton()
            loginView.center = view.center
            loginView.readPermissions = ["public_profile", "user_photos"]
            loginView.delegate = self
            view.addSubview(loginView)
        }
        
        let recognizer = UITapGestureRecognizer(target: self, action: "pictureTapped")
        imageView.addGestureRecognizer(recognizer)
    }
    var i = 0
    func pictureTapped() {
        print("pictureTapped(\(i))")
        
        if i < images.count {
            let image = images[i]
            imageView.image = image
            ++i
        }
        
    }
    
    func returnUserData(url:String, after:String?) {
        let params:[String:String]!
        
        if after == nil {
            params = ["fields" : "images","limit":"10"]
        } else {
            params = ["fields" : "images","limit":"10", "after":after!]
        }
        
        let graphRequest = FBSDKGraphRequest(graphPath: url, parameters: params)
        graphRequest.startWithCompletionHandler({
            (connection, result, error) -> Void in
            
            if error != nil {
                UIAlertController().displayMessage(error.localizedDescription)
            } else {
                let paging = result.valueForKey("paging")
                print("paging:\(paging)")
                
                let cursors = paging?.valueForKey("cursors")
                
                if let after = cursors?.valueForKey("after") as? String {
                    self.returnUserData("me/photos", after: after)
                }
                
                let data = result.valueForKey("data") as! NSArray
                
                for imageData in data {
                    
                    let image = imageData["images"] as! NSArray
                    let largestImage = image[0] as! NSDictionary
                    
                    let source = largestImage.valueForKey("source") as! String
                    
                    self.addImageSrcToArray(source)
                    
                }
              
            }
        })
    }
    
    func addImageSrcToArray(source:String) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            
            let image = UIImage(data: NSData(contentsOfURL: NSURL(string: source)!)!)!
            
            self.images.append(image)
            print("added image")
        }
        
    }
    
    func addImagesToArray(array:NSArray) {
        
        for item in array {
            
            let source = item.valueForKey("source") as! String
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                
                let image = UIImage(data: NSData(contentsOfURL: NSURL(string: source)!)!)!
                
                self.images.append(image)
                print("added image")
            }
        }
        
    }


}

extension ViewController: FBSDKLoginButtonDelegate {
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("photos") {
                // Do work
                returnUserData("me/photos", after:nil)
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out")
    }
    
}

