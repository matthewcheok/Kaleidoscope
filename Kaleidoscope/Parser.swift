//
//  Parser.swift
//  Kaleidoscope
//
//  Created by Matthew Cheok on 15/11/15.
//  Copyright © 2015 Matthew Cheok. All rights reserved.
//

import Foundation

enum Errors: Error {
    case unexpectedToken
    case undefinedOperator(String)
    
    case expectedCharacter(Character)
    case expectedExpression
    case expectedArgumentList
    case expectedFunctionName
}

class Parser {
    let tokens: [Token]
    var index = 0
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func peekCurrentToken() -> Token {
        return tokens[index]
    }
    
    func popCurrentToken() -> Token {
        defer { index += 1 }
        return tokens[index]
    }
    
    func parseNumber() throws -> ExprNode {
        guard case let Token.number(value) = popCurrentToken() else {
            throw Errors.unexpectedToken
        }
        return NumberNode(value: value)
    }
    
    func parseExpression() throws -> ExprNode {
        let node = try parsePrimary()
        return try parseBinaryOp(node)
    }
    
    func parseParens() throws -> ExprNode {
        guard case Token.parensOpen = popCurrentToken() else {
            throw Errors.expectedCharacter("(")
        }
        
        let exp = try parseExpression()

        guard case Token.parensClose = popCurrentToken() else {
            throw Errors.expectedCharacter(")")
        }
    
        return exp
    }
    
    func parseIdentifier() throws -> ExprNode {
        guard case let Token.identifier(name) = popCurrentToken() else {
            throw Errors.unexpectedToken
        }

        guard case Token.parensOpen = peekCurrentToken() else {
            return VariableNode(name: name)
        }
        popCurrentToken()
        
        var arguments = [ExprNode]()
        if case Token.parensClose = peekCurrentToken() {
        }
        else {
            while true {
                let argument = try parseExpression()
                arguments.append(argument)
                
                if case Token.parensClose = peekCurrentToken() {
                    break
                }
                
                guard case Token.comma = popCurrentToken() else {
                    throw Errors.expectedArgumentList
                }
            }
        }
        
        popCurrentToken()
        return CallNode(callee: name, arguments: arguments)
    }
    
    func parsePrimary() throws -> ExprNode {
        switch (peekCurrentToken()) {
        case .identifier:
            return try parseIdentifier()
        case .number:
            return try parseNumber()
        case .parensOpen:
            return try parseParens()
        default:
            throw Errors.expectedExpression
        }
    }
    
    let operatorPrecedence: [String: Int] = [
        "+": 20,
        "-": 20,
        "*": 40,
        "/": 40
    ]
    
    func getCurrentTokenPrecedence() throws -> Int {
        guard index < tokens.count else {
            return -1
        }
        
        guard case let Token.other(op) = peekCurrentToken() else {
            return -1
        }
        
        guard let precedence = operatorPrecedence[op] else {
            throw Errors.undefinedOperator(op)
        }

        return precedence
    }
    
    func parseBinaryOp(_ node: ExprNode, exprPrecedence: Int = 0) throws -> ExprNode {
        var lhs = node
        while true {
            let tokenPrecedence = try getCurrentTokenPrecedence()
            if tokenPrecedence < exprPrecedence {
                return lhs
            }
            
            guard case let Token.other(op) = popCurrentToken() else {
                throw Errors.unexpectedToken
            }
            
            var rhs = try parsePrimary()
            let nextPrecedence = try getCurrentTokenPrecedence()
            
            if tokenPrecedence < nextPrecedence {
                rhs = try parseBinaryOp(rhs, exprPrecedence: tokenPrecedence+1)
            }
            lhs = BinaryOpNode(op: op, lhs: lhs, rhs: rhs)
        }
    }
    
    func parsePrototype() throws -> PrototypeNode {
        guard case let Token.identifier(name) = popCurrentToken() else {
            throw Errors.expectedFunctionName
        }
        
        guard case Token.parensOpen = popCurrentToken() else {
            throw Errors.expectedCharacter("(")
        }
        
        var argumentNames = [String]()
        while case let Token.identifier(name) = peekCurrentToken() {
            popCurrentToken()
            argumentNames.append(name)
            
            if case Token.parensClose = peekCurrentToken() {
                break
            }
            
            guard case Token.comma = popCurrentToken() else {
                throw Errors.expectedArgumentList
            }
        }
        
        // remove ")"
        popCurrentToken()
        
        return PrototypeNode(name: name, argumentNames: argumentNames)
    }
    
    func parseDefinition() throws -> FunctionNode {
        popCurrentToken()
        let prototype = try parsePrototype()
        let body = try parseExpression()
        return FunctionNode(prototype: prototype, body: body)
    }
    
    func parseTopLevelExpr() throws -> FunctionNode {
        let prototype = PrototypeNode(name: "", argumentNames: [])
        let body = try parseExpression()
        return FunctionNode(prototype: prototype, body: body)
    }
    
    func parse() throws -> [Any] {
        index = 0
        
        var nodes = [Any]()
        while index < tokens.count {
            switch peekCurrentToken() {
            case .define:
                let node = try parseDefinition()
                nodes.append(node)
            default:
                let expr = try parseExpression()
                nodes.append(expr)
            }
        }
        
        return nodes
    }
}
