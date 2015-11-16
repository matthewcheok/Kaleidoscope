//
//  Nodes.swift
//  Kaleidoscope
//
//  Created by Matthew Cheok on 15/11/15.
//  Copyright © 2015 Matthew Cheok. All rights reserved.
//

import Foundation

public class ExprNode {
}

public class NumberNode: ExprNode, CustomStringConvertible {
    public let value: Float
    public init(value: Float) {
        self.value = value
    }
    
    public var description: String {
        return "NumberNode(\(value))"
    }
}

public class VariableNode: ExprNode, CustomStringConvertible {
    public let name: String
    public init(name: String) {
        self.name = name
    }
    
    public var description: String {
        return "VariableNode(\(name))"
    }
}

public class BinaryOpNode: ExprNode, CustomStringConvertible {
    public let op: String
    public let lhs: ExprNode
    public let rhs: ExprNode
    public init(op: String, lhs: ExprNode, rhs: ExprNode) {
        self.op = op
        self.lhs = lhs
        self.rhs = rhs
    }
    
    public var description: String {
        return "BinaryOpNode(\(op), lhs: \(lhs), rhs: \(rhs))"
    }
}

public class CallNode: ExprNode, CustomStringConvertible {
    public let callee: String
    public let arguments: [ExprNode]
    public init(callee: String, arguments: [ExprNode]) {
        self.callee = callee
        self.arguments = arguments
    }
    
    public var description: String {
        return "CallNode(name: \(callee), argument: \(arguments))"
    }
}

public class PrototypeNode: CustomStringConvertible {
    public let name: String
    public let argumentNames: [String]
    public init(name: String, argumentNames: [String]) {
        self.name = name
        self.argumentNames = argumentNames
    }
    
    public var description: String {
        return "PrototypeNode(name: \(name), argumentNames: \(argumentNames))"
    }
}

public class FunctionNode: CustomStringConvertible {
    public let prototype: PrototypeNode
    public let body: ExprNode
    public init(prototype: PrototypeNode, body: ExprNode) {
        self.prototype = prototype
        self.body = body
    }
    
    public var description: String {
        return "FunctionNode(prototype: \(prototype), body: \(body))"
    }
}