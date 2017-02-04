//
//  Food.swift
//  FreeBites
//
//  Created by Orlando G. Rodriguez on 1/31/17.
//  Copyright © 2017 Orlando G. Rodriguez. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

struct Food {
    var name:String
    var description:String
    var uid:String
    var creator:String
    
    var latitude:Double
    var longitude:Double
    
    init(uid:String, name:String, description:String, creator:String, latitude:Double, longitude:Double) {
        self.name = name
        self.description = description
        self.uid = uid
        self.creator = creator
        self.latitude = latitude
        self.longitude = longitude
    }
}
