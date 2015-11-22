//
//  Post.swift
//  Social Network App
//
//  Created by Alexander Besson on 2015-11-20.
//  Copyright © 2015 Alexander Besson. All rights reserved.
//

import Foundation

class Post {
    private var _postDescription: String!
    private var _imageURL: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    
    var postDescription: String {
        return _postDescription
    }
    
    var imageURL: String? {
        return _imageURL
    }
    
    var likes: Int {
        return _likes
    }
    
    var username: String {
        return _username
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(description: String, imageURl: String?, username: String) {
        self._postDescription = description
        self._imageURL = imageURl
        self._username = username
    }
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        
        if let imageURL = dictionary["imageURL"] as? String {
            self._imageURL = imageURL
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        
    }
}
