//
//  LoginViewController.swift
//  Twitter
//
//  Created by Doan Cong Toan on 7/19/16.
//  Copyright © 2016 Toan Qri. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(sender: UIButton) {
        TwitterClient.sharedInstance.login({
            self.performSegueWithIdentifier("TweetsSegue", sender: self)
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let tweetsViewController = storyboard.instantiateViewControllerWithIdentifier("TweetsViewController") as! TweetsViewController
//            tweetsViewController.automaticallyAdjustsScrollViewInsets = false
//            let navigationController = UINavigationController(rootViewController: tweetsViewController)    
//            self.presentViewController(navigationController, animated: true, completion: nil)
        }) { (error: NSError) in
            print("error: \(error.localizedDescription)")
        }
    }
}
