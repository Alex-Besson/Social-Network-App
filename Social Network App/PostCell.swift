//
//  PostCell.swift
//  Social Network App
//
//  Created by Alexander Besson on 2015-11-14.
//  Copyright © 2015 Alexander Besson. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgShowcase: UIImageView!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var imgHeart: UIImageView!
    
    var post: Post!
    var request: Request?
    var likeRef: Firebase!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        imgHeart.addGestureRecognizer(tap)
        imgHeart.userInteractionEnabled = true
        
    }
    
    override func drawRect(rect: CGRect) {
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2
        imgProfile.clipsToBounds = true
        
        imgShowcase.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(post: Post, img: UIImage?) {
        self.post = post
        
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
    
        self.txtDescription.text = post.postDescription
        self.lblLikes.text = "\(post.likes)"
        
        if post.imageURL != nil {
            
            if img != nil {
                self.imgShowcase.image = img
            } else {
                request = Alamofire.request(.GET, post.imageURL!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.imgShowcase.image = img
                        FeedViewController.imageCache.setObject(img, forKey: self.post.imageURL!)
                    } else {
                        print(err.debugDescription)
                    }
                    
                })
            }
            
        } else {
            self.imgShowcase.hidden = true
        }
    
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                self.imgHeart.image = UIImage(named: "heart-empty")
            } else {
                self.imgHeart.image = UIImage(named: "heart-full")
            }
            
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                self.imgHeart.image = UIImage(named: "heart-full")
                self.post.adjustLike(true)
                self.likeRef.setValue(true)
                
            } else {
                self.imgHeart.image = UIImage(named: "heart-empty")
                self.post.adjustLike(false)
                self.likeRef.removeValue()
                
            }
            
        })

    }

}
