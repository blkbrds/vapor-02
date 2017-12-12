//
//  RequestExt.swift
//  VaporReferenceDemoPackageDescription
//
//  Created by Quang Dang N.K on 12/6/17.
//

import HTTP
import Fluent

extension Request {
    
    func page() -> Int {
        guard let node = data["page"], let page = node.wrapped.int, page > 0 else { return 1 }
        return page
    }
}
