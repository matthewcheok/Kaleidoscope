//
//  Lexer.swift
//  Kaleidoscope
//
//  Created by Matthew Cheok on 15/11/15.
//  Copyright © 2015 Matthew Cheok. All rights reserved.
//

import Foundation

public enum Token {
    case Define
    case Identifier(String)
    case Number(Float)
    case ParensOpen
    case ParensClose
    case Comma
    case Other(String)
    
    case BinaryOp(String)
}

typealias TokenGenerator = (String) -> Token?
let tokenList: [(String, TokenGenerator)] = [
    ("[ \t\n]", { _ in nil }),
    ("[a-zA-Z][a-zA-Z0-9]*", { $0 == "def" ? .Define : .Identifier($0) }),
    ("[0-9.]+", { (r: String) in .Number((r as NSString).floatValue) }),
    ("\\(", { _ in .ParensOpen }),
    ("\\)", { _ in .ParensClose }),
    (",", { _ in .Comma }),
    
    ("[+\\-*/]", { .BinaryOp($0) })
]

public class Lexer {
    let input: String
    init(input: String) {
        self.input = input
    }
    public func tokenize() -> [Token] {
        var tokens = [Token]()
        var content = input
        
        while (content.count > 0) {
            var matched = false
            
            for (pattern, generator) in tokenList {
                if let m = content.match(regex: pattern) {
                    if let t = generator(m) {
                        tokens.append(t)
                    }
                    let index = content.index(content.startIndex, offsetBy: m.count) // content.startIndex.advanced(by: m.count)
                    // 'substring(from:)' is deprecated: Please use String slicing subscript with a 'partial range from' operator.
                    //                    content = content.substring(from: index )
                    content = String(content[index...])
                    matched = true
                    break
                }
            }
            
            if !matched {
                //                let index = content.startIndex.advanced(by: 1)
                let index = content.index(content.startIndex, offsetBy: 1)
                let o = String(content[...index]).trimmingCharacters(in: CharacterSet.whitespaces) // content.substringToIndex(index)
                tokens.append(.Other(o))
                content =  String(content[index...]) //  content.substringFromIndex(index)
            }
        }
        return tokens
    }
}

