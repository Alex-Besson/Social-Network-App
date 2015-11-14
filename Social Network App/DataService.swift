//
//  DataService.swift
//  Social Network App
//
//  Created by Alexander Besson on 2015-11-14.
//  Copyright © 2015 Alexander Besson. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "https://the-social-network.firebaseio.com/")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
}