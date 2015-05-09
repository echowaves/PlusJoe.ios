//
//  ChatViewController.swift
//  PlusJoe
//
//  Created by D on 5/3/15.
//  Copyright (c) 2015 PlusJoe. All rights reserved.
//

import Foundation

class ChatViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backNavButton: UIBarButtonItem!
    
    @IBOutlet weak var chatMessageBody: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    // conversation should always be passed from chid controller
    var conversation:PJConversation?
    
    var chatMessages:[PJChatMessage] = [PJChatMessage]()
    
    
    
    @IBAction func backButtonAction(sender: AnyObject) {
        if chatMessages.count == 0 {
            conversation?.deleteInBackgroundWithBlock({ (sucseeded:Bool, error:NSError?) -> Void in})
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        backNavButton.title = "\u{f053}"
        if let font = UIFont(name: "FontAwesome", size: 20) {
            backNavButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        
        
        self.tableView.delegate      =   self
        self.tableView.dataSource    =   self
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        
        chatMessageBody.becomeFirstResponder()
        chatMessageBody.text = ""
        countLabel.text = "+" + String(140)
        countLabel.textColor = UIColor.blueColor()
        chatMessageBody.textColor = UIColor.lightGrayColor()
        chatMessageBody.delegate = self
        
        
        sendButton.setTitle("\u{f1d8}", forState: .Normal)
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.retrieveAllMessages()
    }
    
    func retrieveAllMessages() -> Void {
        PJChatMessage.loadAllChatMessages(conversation!,
            succeeded: { (results) -> () in
                self.chatMessages = results
                self.tableView.reloadData()
                
            }) { (error) -> () in
                let alertMessage = UIAlertController(title: nil, message: "Error.", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                alertMessage.addAction(ok)
                self.presentViewController(alertMessage, animated: true, completion: nil)
        }
    }
    
    
    
    func textViewDidChange(textView: UITextView) {
        //        NSLog("text changed: \(textView.text)")
        
        
        var countChars = count(textView.text)
        countLabel.text = "+" + String(140 - countChars)
        
        if(countChars > 130) {
            countLabel.textColor = UIColor.redColor()
        } else {
            countLabel.textColor = UIColor.blueColor()
        }
        
        while(countChars > 140) {
            chatMessageBody.text = dropLast(chatMessageBody.text)
            countChars--
            countLabel.text = "+" + String(140 - countChars)
        }
    }
    
    
    
    @IBAction func sendReplyAction(sender: AnyObject) {
        
        if textView.text == "" || textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 1 {
            let alertMessage = UIAlertController(title: "Warning", message: "You reply can't be empty. Try again.", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
            alertMessage.addAction(ok)
            presentViewController(alertMessage, animated: true, completion: nil)
        } else {
            PJChatMessage.createChatMessage(conversation!,
                body: chatMessageBody.text,
                createdBy: DEVICE_UUID,
                success: { (result) -> () in
                    self.chatMessages.insert(result, atIndex: 0)
                }, failed: { (error) -> () in
                    let alertMessage = UIAlertController(title: "Error", message: "Failed replying. Try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
                    alertMessage.addAction(ok)
                    self.presentViewController(alertMessage, animated: true, completion: nil)
            })
            
            
        }
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("there are \(chatMessages.count) chat messages")
        return self.chatMessages.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ChatTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("chat_cell") as! ChatTableViewCell
        let chatMessage = chatMessages[indexPath.row]
        
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy hh:mm a"
        cell.postedAt.text = String(format: "%@", df.stringFromDate(chatMessage.createdAt!))
        
        NSLog("Rendering ReplyPost")
        cell.body.text = chatMessage.body
        
        if chatMessage.createdBy == DEVICE_UUID {
            cell.postedAt.text = "I said - \(cell.postedAt.text!)"
        } else {
            cell.postedAt.text = "replied to me - \(cell.postedAt.text!)"
        }
        
        
        return cell
    }
    
}
