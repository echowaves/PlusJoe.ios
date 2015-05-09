//
//  PJChat.swift
//  PlusJoe
//
//  Created by D on 5/3/15.
//  Copyright (c) 2015 PlusJoe. All rights reserved.
//

//There are only 2 parties in any given chat.
//Each chat message contains an array of both parrites, who participates in the chat, so it can always be queried on both array values.
//We query chat always by post it belongs to and both parties in the array


//To determine all my conversations, select all chat messages that contain my id and have attribute of the first message


import Foundation

class PJChatMessage: PFObject, PFSubclassing {
    static func parseClassName() -> String {
        return "ChatMessages"
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    @NSManaged var conversation: PJConversation
    @NSManaged var body: String // no more then 140 chars
    @NSManaged var createdBy: String // must match one of the partcipants in conversation
    
    
    
    class func loadAllChatMessages(
        conversation: PJConversation,
        succeeded:(results:[PJChatMessage]) -> (),
        failed:(error: NSError!) -> ()
        ) -> () {
            let query = PJChatMessage.query()
            // Interested in locations near user.
            query!.whereKey("conversation", equalTo: conversation)
            query!.orderByDescending("createdAt")
            
            
            query!.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    succeeded(results: objects as! [PJChatMessage])
                } else {
                    // Log details of the failure
                    failed(error: error)
                }
            })
    }
    
    class func loadNewChatMessages(
        since: NSDate,
        conversation: PJConversation,
        succeeded:(results:[PJChatMessage]) -> (),
        failed:(error: NSError!) -> ()
        ) -> () {
            let query = PJChatMessage.query()
            // Interested in locations near user.
            query!.whereKey("conversation", equalTo: conversation)
            query!.whereKey("createdAt", greaterThan: since)
            query!.orderByDescending("createdAt")
            
            
            query!.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    succeeded(results: objects as! [PJChatMessage])
                } else {
                    // Log details of the failure
                    failed(error: error)
                }
            })
    }
    
    class func createChatMessage(
        conversation:PJConversation,
        body:String,
        createdBy:String,
        success:(result: PJChatMessage) -> (),
        failed:(error: NSError!) -> ()
        ) -> () {
            let chatMessage = PJChatMessage(className: PJChatMessage.parseClassName())
            chatMessage.conversation = conversation
            chatMessage.body = body
            chatMessage.createdBy = createdBy
            chatMessage.saveInBackgroundWithBlock { (succeeded:Bool, error:NSError?) -> Void in
                if error == nil {
                    let alert = PJAlert(className: PJAlert.parseClassName())
                    alert.chatMessage = chatMessage
                    alert.read = false
                    alert.target = (conversation.participants[0] == DEVICE_UUID) ? conversation.participants[1] : conversation.participants[0]
                    alert.saveInBackgroundWithBlock({ (succeeded:Bool, error:NSError?) -> Void in })
                    success(result: chatMessage)
                } else {
                    // Log details of the failure
                    failed(error: error)
                }
            }
    }
    
}
