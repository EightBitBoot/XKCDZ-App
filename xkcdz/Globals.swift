//
//  Globals.swift
//  xkcdz
//
//  Created by Adin W-T on 1/2/24.
//

import Foundation
import RealmSwift

let XKCDZ_SCHEMA_VERSION: UInt64 = 0
let XKCDZ_SHARED_REALM_CONFIG = Realm.Configuration(schemaVersion: XKCDZ_SCHEMA_VERSION)
