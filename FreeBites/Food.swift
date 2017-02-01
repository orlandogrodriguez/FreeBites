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
    
    init(uid:String) {
        name = ""
        description = ""
        self.uid = uid
        creator = ""
        latitude = 0.0
        longitude = 0.0
    }
}
