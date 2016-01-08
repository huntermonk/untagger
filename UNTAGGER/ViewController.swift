//
//  ViewController.swift
//  UNTAGGER
//
//  Created by Hunter Maximillion Monk on 5/10/15.
//  Copyright (c) 2015 Hunter Maximillion Monk. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
        
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            // User is already logged in, do work such as go to next view controller.
        } else {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "user_photos"]
            loginView.delegate = self
        }
        
        let params = ["fields"]
        
        /*
        let request = FBSDKGraphRequest(graphPath: "/me/photos", parameters: nil)
        request.startWithCompletionHandler { (connection, result, error) -> Void in
            if result != nil {
                println("results\(result)")
            } else {
                println("error\(error)")
            }
        }*/
        returnUserData()
    }
    
    func returnUserData() {
        let params = ["fields" : "images"]
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/photos", parameters: params)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if error != nil {
                // Process error
                print("Error: \(error)")
            } else {
                
                let data = result.valueForKey("data") as! NSArray
                print("data\(data)")
                let first = data[0] as! NSDictionary
                print("first\(first)")
                let images = first["images"] as! NSArray
                print("images \(images)")
                let firstImage = images[0] as! NSDictionary
                
                let source = firstImage.valueForKey("source") as! String
                print("source\(source)")
                
                let imageView = UIImageView(frame: CGRectMake(0, 0, 320, 320))
                imageView.sd_setImageWithURL(NSURL(string: source))
                imageView.clipsToBounds = true
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                imageView.center = self.view.center
                imageView.backgroundColor = UIColor.blackColor()
                self.view.addSubview(imageView)
              
            }
        })
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("photos")
            {
                // Do work
                print("do work?")
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

