//
//  TweetComposeViewController.swift
//  Twitter
//
//  Created by Doan Cong Toan on 7/23/16.
//  Copyright © 2016 Toan Qri. All rights reserved.
//

import UIKit

class TweetComposeViewController: UIViewController {
    
    @IBOutlet weak var statusField: UITextView!
    @IBOutlet weak var charactersCountLabel: UILabel!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var inReplyLabel: UILabel!
    
    @IBOutlet weak var controlToBottomConstraint: NSLayoutConstraint!
    
    var tweet: Tweet?
    
    var isReplyTo = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        statusField.delegate = self
        statusField.text = "What's happening?"
        statusField.textColor = UIColor.lightGrayColor()
        
        tweetButton.enabled = false
        inReplyLabel.text = nil
        
        if let tweet = tweet {
            if let name = tweet.user?.name, screenName = tweet.user?.screenName {
                isReplyTo = true
                inReplyLabel.text = "In reply to \(name)"
                statusField.text = "@\(screenName) "
                statusField.textColor = UIColor.blackColor()
                textViewDidChange(statusField)
                statusField.becomeFirstResponder()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.controlToBottomConstraint.constant += keyboardSize.height
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.controlToBottomConstraint.constant -= keyboardSize.height
            })
        }
    }
    
    
    @IBAction func onCalcel(sender: UIBarButtonItem) {
        statusField.resignFirstResponder()
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onTweet(sender: UIButton) {
        let parameters: NSMutableDictionary = [
            "status": statusField.text!
        ]
        if isReplyTo {
            if let tweet = tweet {
                if let id = tweet.id {
                    parameters["in_reply_to_status_id"] = id
                }
            }
        }
        
        TwitterClient.sharedInstance.newTweet(
            parameters,
            success: { (tweet: Tweet) in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("addTweetNotification", object: nil, userInfo: ["newTweet" : tweet])
                    self.statusField.resignFirstResponder()
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                })
            },
            failure: { (error: NSError) in
                print("Error \(error.localizedDescription)")
            }
        )
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension TweetComposeViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
            textView.becomeFirstResponder()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What's happening?"
            textView.textColor = UIColor.lightGrayColor()
            textView.resignFirstResponder()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if isReplyTo {
            if let tweet = tweet {
                if let screenName = tweet.user?.screenName {
                    let text = (statusField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                    if text.stringByReplacingOccurrencesOfString(screenName, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil) != "@" {
                        print("\(text) \(screenName)")
                        isReplyTo = false
                        inReplyLabel.text = nil
                        inReplyLabel.sizeToFit()
                    }
                }
            }
        }
        
        let tweetCurrentCharacterCount = statusField.text.characters.count
        let tweetRemainingCharacterCount = 140 - tweetCurrentCharacterCount
        charactersCountLabel.text = "\(tweetRemainingCharacterCount)"
        if tweetCurrentCharacterCount > 0 {
            tweetButton.enabled = true
            if tweetRemainingCharacterCount >= 0 {
                charactersCountLabel.textColor = UIColor.lightGrayColor()
                tweetButton.enabled = true
            } else {
                charactersCountLabel.textColor = UIColor.redColor()
                tweetButton.enabled = false
            }
        } else {
            tweetButton.enabled = false
        }
    }
}