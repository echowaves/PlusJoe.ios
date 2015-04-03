//
//  CreatePostStepThreeViewController.swift
//  PlusJoe
//
//  Created by D on 3/27/15.
//  Copyright (c) 2015 PlusJoe. All rights reserved.
//

import Foundation

// http://rajiev.com/resize-uiimage-in-swift/
extension UIImage {
    public func resize(size:CGSize, completionHandler:(resizedImage:UIImage, data:NSData)->()) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            var newSize:CGSize = size
            let rect = CGRectMake(0, 0, newSize.width, newSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.drawInRect(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imageData = UIImageJPEGRepresentation(newImage, 0.5)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(resizedImage: newImage, data:imageData)
            })
        })
    }
}

class CreatePostStepThreeViewController:
    UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{
    
    @IBOutlet weak var backNavButton: UIBarButtonItem!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var pickPhotoFromLibraryButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var imageThree: UIImageView!
    @IBOutlet weak var imageFour: UIImageView!
    
    let picker = UIImagePickerController()
    
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
        
        nextButton.setTitle("next" + "   \u{f054}", forState: UIControlState.Normal)
        takePhotoButton.setTitle("\u{f030}", forState: UIControlState.Normal)
        pickPhotoFromLibraryButton.setTitle( "\u{f1c5}", forState: UIControlState.Normal)
        
        picker.delegate = self
        
        imageOne.contentMode = .ScaleAspectFill
        imageTwo.contentMode = .ScaleAspectFill
        imageThree.contentMode = .ScaleAspectFill
        imageFour.contentMode = .ScaleAspectFill

        reloadImageViews()

        self.imageOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "image1tapped:"))
        self.imageTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "image2tapped:"))
        self.imageThree.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "image3tapped:"))
        self.imageFour.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "image4tapped:"))
        
        
        showHidePhotoButtons()
    }
    
    func reloadImageViews() {
        if let imageFile1 = UNFINISHED_POST?.image1file.getData() {
            imageOne.image = UIImage(data: imageFile1)
        } else {
            imageOne.image = UIImage()
        }
        if let imageFile2 = UNFINISHED_POST?.image2file.getData() {
            imageTwo.image = UIImage(data: imageFile2)
        } else {
            imageTwo.image = UIImage()
        }
        if let imageFile3 = UNFINISHED_POST?.image3file.getData() {
            imageThree.image = UIImage(data: imageFile3)
        } else {
            imageThree.image = UIImage()
        }
        if let imageFile4 = UNFINISHED_POST?.image4file.getData() {
            imageFour.image = UIImage(data: imageFile4)
        } else {
            imageFour.image = UIImage()
        }
    }
    
    @IBAction func shootPhoto(sender: UIBarButtonItem){
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.cameraCaptureMode = .Photo
        presentViewController(picker, animated: true, completion: nil)

    }
    @IBAction func photoFromLibrary(sender: AnyObject) {
        picker.allowsEditing = false //2
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary 
        presentViewController(picker, animated: true, completion: nil)
//        picker.modalPresentationStyle = .Popover
//        presentViewController(picker, animated: true, completion: nil)//4
//        picker.popoverPresentationController?.barButtonItem = sender as! UIBarButtonItem
    }

    func showHidePhotoButtons() -> () {
        if(UNFINISHED_POST?.image1file.name.rangeOfString("blank.png") == nil
            && UNFINISHED_POST?.image2file.name.rangeOfString("blank.png") == nil
            && UNFINISHED_POST?.image3file.name.rangeOfString("blank.png") == nil
            && UNFINISHED_POST?.image4file.name.rangeOfString("blank.png") == nil) {
                takePhotoButton.hidden = true
                pickPhotoFromLibraryButton.hidden = true
        } else {
            takePhotoButton.hidden = false
            pickPhotoFromLibraryButton.hidden = false
        }
    }
    
    
    func image1tapped(sender: UITapGestureRecognizer) {
        NSLog("image1 tapped")
        if UNFINISHED_POST?.image1file.name.rangeOfString("blank.png") != nil {
            return
        }
        let alertMessage = UIAlertController(title: nil, message: "Delete photo?", preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in})
        let ok =     UIAlertAction(title: "OK",     style: .Default, handler: { (action) -> Void in
            let file2 = UNFINISHED_POST?.image2file
            let file3 = UNFINISHED_POST?.image3file
            let file4 = UNFINISHED_POST?.image4file
            UNFINISHED_POST?.image1file = file2!
            UNFINISHED_POST?.image2file = file3!
            UNFINISHED_POST?.image3file = file4!
            UNFINISHED_POST?.image4file = PFFile(name:"blank.png", data:NSData())
            var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
            actInd.center = self.view.center
            actInd.hidesWhenStopped = true
            actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            self.view.addSubview(actInd)
            self.view.backgroundColor = UIColor.grayColor()
            actInd.startAnimating()
            UNFINISHED_POST?.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                self.reloadImageViews()
                actInd.stopAnimating()
                self.view.backgroundColor = UIColor.whiteColor()
                self.showHidePhotoButtons()
            }
        })
        alertMessage.addAction(cancel)
        alertMessage.addAction(ok)
        presentViewController(alertMessage, animated: true, completion: nil)
        
    }
    func image2tapped(sender: UITapGestureRecognizer) {
        NSLog("image2 tapped")
        if UNFINISHED_POST?.image2file.name.rangeOfString("blank.png") != nil {
            return
        }
        let alertMessage = UIAlertController(title: nil, message: "Delete photo?", preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in})
        let ok =     UIAlertAction(title: "OK",     style: .Default, handler: { (action) -> Void in
            let file3 = UNFINISHED_POST?.image3file
            let file4 = UNFINISHED_POST?.image4file
            UNFINISHED_POST?.image2file = file3!
            UNFINISHED_POST?.image3file = file4!
            UNFINISHED_POST?.image4file = PFFile(name:"blank.png", data:NSData())
            var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
            actInd.center = self.view.center
            actInd.hidesWhenStopped = true
            actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            self.view.addSubview(actInd)
            self.view.backgroundColor = UIColor.grayColor()
            actInd.startAnimating()
            UNFINISHED_POST?.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                self.reloadImageViews()
                actInd.stopAnimating()
                self.view.backgroundColor = UIColor.whiteColor()
                self.showHidePhotoButtons()
            }
        })
        alertMessage.addAction(cancel)
        alertMessage.addAction(ok)
        presentViewController(alertMessage, animated: true, completion: nil)
    }
    
    func image3tapped(sender: UITapGestureRecognizer) {
        NSLog("image3 tapped")
        if UNFINISHED_POST?.image3file.name.rangeOfString("blank.png") != nil {
            return
        }
        let alertMessage = UIAlertController(title: nil, message: "Delete photo?", preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in})
        let ok =     UIAlertAction(title: "OK",     style: .Default, handler: { (action) -> Void in
            let file4 = UNFINISHED_POST?.image4file
            UNFINISHED_POST?.image3file = file4!
            UNFINISHED_POST?.image4file = PFFile(name:"blank.png", data:NSData())
            var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
            actInd.center = self.view.center
            actInd.hidesWhenStopped = true
            actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            self.view.addSubview(actInd)
            self.view.backgroundColor = UIColor.grayColor()
            actInd.startAnimating()
            UNFINISHED_POST?.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                self.reloadImageViews()
                actInd.stopAnimating()
                self.view.backgroundColor = UIColor.whiteColor()
                self.showHidePhotoButtons()
            }
        })
        alertMessage.addAction(cancel)
        alertMessage.addAction(ok)
        presentViewController(alertMessage, animated: true, completion: nil)
    }
    
    func image4tapped(sender: UITapGestureRecognizer) {
        NSLog("image4 tapped")
        if UNFINISHED_POST?.image4file.name.rangeOfString("blank.png") != nil {
            return
        }
        let alertMessage = UIAlertController(title: nil, message: "Delete photo?", preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in})
        let ok =     UIAlertAction(title: "OK",     style: .Default, handler: { (action) -> Void in
            UNFINISHED_POST?.image4file = PFFile(name:"blank.png", data:NSData())
            var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
            actInd.center = self.view.center
            actInd.hidesWhenStopped = true
            actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            self.view.addSubview(actInd)
            self.view.backgroundColor = UIColor.grayColor()
            actInd.startAnimating()
            UNFINISHED_POST?.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                self.reloadImageViews()
                actInd.stopAnimating()
                self.view.backgroundColor = UIColor.whiteColor()
                self.showHidePhotoButtons()
            }
        })
        alertMessage.addAction(cancel)
        alertMessage.addAction(ok)
        presentViewController(alertMessage, animated: true, completion: nil)
    }
    
    //MARK: Delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2

        chosenImage.resize(CGSizeMake(500,500)) { (resizedImage, data) -> () in
            let imageFile = PFFile(name:"image.png", data:data)

            if UNFINISHED_POST?.image1file.name.rangeOfString("blank.png") != nil {
                self.imageOne.image = resizedImage
                UNFINISHED_POST?.image1file = imageFile
            } else if UNFINISHED_POST?.image2file.name.rangeOfString("blank.png") != nil {
                self.imageTwo.image = resizedImage
                UNFINISHED_POST?.image2file = imageFile
            } else if UNFINISHED_POST?.image3file.name.rangeOfString("blank.png") != nil {
                self.imageThree.image = resizedImage
                UNFINISHED_POST?.image3file = imageFile
            } else if UNFINISHED_POST?.image4file.name.rangeOfString("blank.png") != nil {
                self.imageFour.image = resizedImage
                UNFINISHED_POST?.image4file = imageFile
            }
            
            UNFINISHED_POST?.saveInBackgroundWithBlock(nil)
        
            self.showHidePhotoButtons()
            
            self.dismissViewControllerAnimated(true, completion: nil) //5
        }


        
    }

    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
