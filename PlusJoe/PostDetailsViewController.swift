//
//  PostDetailsViewController.swift
//  PlusJoe
//
//  Created by D on 4/18/15.
//  Copyright (c) 2015 PlusJoe. All rights reserved.
//

import Foundation


class PostDetailsViewController : UIViewController {
    @IBOutlet weak var backNavButton: UIBarButtonItem!
    
    var post:PJPost? 
    
    @IBOutlet weak var postNumberLabel: UILabel!
    @IBOutlet weak var imagesView: UIView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var fee: UILabel!
    @IBOutlet weak var postBody: UILabel!


    var postNumberText = ""
    
    @IBAction func backButtonAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        backNavButton.title = "\u{f053}"
        if let font = UIFont(name: "FontAwesome", size: 20) {
            backNavButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
    
        postNumberLabel.text = postNumberText
        postBody.text = post?.body
        price.text = "$\((post?.price)!)"
        fee.text = "$\((post?.fee)!)"
    }


}
