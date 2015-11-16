//
//  main.swift
//  Kaleidoscope
//
//  Created by Matthew Cheok on 15/11/15.
//  Copyright © 2015 Matthew Cheok. All rights reserved.
//

import Foundation

let source = multiline(
    "def foo(x, y)",
    "  x + y * 2 + (4 + 5) / 3",
    "",
    "foo(3, 4)"
)

let lexer = Lexer(input: source)
let tokens = lexer.tokenize()
print(tokens)

let parser = Parser(tokens: tokens)
do {
    print(try parser.parse())
}
catch {
    print(error)
}