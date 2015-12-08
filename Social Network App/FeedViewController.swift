//
//  FeedViewController.swift
//  Social Network App
//
//  Created by Alexander Besson on 2015-11-14.
//  Copyright © 2015 Alexander Besson. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var posts = [Post]()
    var imageSelected = false
    
    static var imageCache = NSCache()
    
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var txtPostField: MaterialTextField!
    
    @IBOutlet weak var imgCameraImage: UIImageView!
    
    @IBAction func gestureTapCamera(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func btnPost(sender: AnyObject) {
        
        if let txt = txtPostField.text where txt != "" {
            
            if let img = imgCameraImage.image where imageSelected == true {
                
                let urlString = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlString)!
                let imageData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "09ACJMST8ad96be8d81f92dad091c426e9e7af26".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    
                    multipartFormData.appendBodyPart(data: imageData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    
                    }) { encodingResult in
                        
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.responseJSON(completionHandler: { response in
                                if let info = response.result.value as? Dictionary<String, AnyObject> {
                                    
                                    if let links = info["links"] as? Dictionary<String, AnyObject> {
                                        if let imgLink = links["image_link"] as? String {
                                            print("Link: \(imgLink)")
                                            self.postToFirebase(imgLink)
                                        }
                                    }
                                }
                            })
                        case .Failure(let error):
                            print(error)
                        }
                }
                
            } else {
                self.postToFirebase(nil)
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 358
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value)
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
                
            }
            
            self.tableView.reloadData()
        })
    
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imgCameraImage.image = image
        imageSelected = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        print(post.postDescription)
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as? PostCell {
            cell.request?.cancel()
            var img: UIImage?
            
            if let url = post.imageURL {
                img = FeedViewController.imageCache.objectForKey(url) as? UIImage
                
            }
            
            cell.configureCell(post, img: img)
            return cell
        } else {
            return PostCell()
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageURL == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func postToFirebase(imgURL: String?) {
        var post: Dictionary<String, AnyObject> = [
            "description": txtPostField.text!,
            "likes": 0,
        ]
            
        if imgURL != nil {
            post["imageURL"] = imgURL!
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        txtPostField.text = ""
        imgCameraImage.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
        
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
