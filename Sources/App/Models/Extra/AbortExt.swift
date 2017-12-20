//
//  AbortExt.swift
//  App
//
//  Created by hai phung on 12/7/17.
//


import HTTP
import Node

extension Abort {

    init(status: Status, errors: [ResponseError]) {
        self.status = status
        let data = errors.map { (error) -> StructuredData in
            let key = StructuredData.string(error.key)
            let value = StructuredData.string(error.value)
            return StructuredData.object([
                ResponseError.key: key,
                ResponseError.valueKey: value
                ])
        }
        self.metadata = Node(data, in: nil)
        self.reason = status.reasonPhrase
        self.identifier = status.localizedDescription
        self.possibleCauses = []
        self.suggestedFixes = []
        self.documentationLinks = []
        self.stackOverflowQuestions = []
        self.gitHubIssues = []
        self.file = #file
        self.line = #line
        self.column = #column
    }
}
