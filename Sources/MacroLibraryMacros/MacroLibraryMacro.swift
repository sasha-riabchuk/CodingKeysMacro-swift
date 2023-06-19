import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
//
//public struct InitMacro: MemberMacro {
//    public static func expansion<Declaration, Context>(
//        of node: AttributeSyntax,
//        providingMembersOf declaration: Declaration,
//        in context: Context
//    ) throws -> [DeclSyntax] where Declaration : DeclGroupSyntax, Context : MacroExpansionContext {
//        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
//            return []
//        }
//        
//        let members = structDecl.memberBlock.members
//        let variableDecl = members.compactMap { $0.decl.as(VariableDeclSyntax.self)?.bindings }
//        
//        let variables = variableDecl.compactMap({$0.first?.pattern})
//        
//        let types = variableDecl.compactMap({$0.first?.typeAnnotation?.type})
//        
//        
//        let parameters = zip(variables, types)
//            .map { "\($0.0): \($0.1)"}
//            .joined(separator: ",\n")
//        
//        let assignments = variables
//            .map { "self.\($0) = \($0)"}
//            .joined(separator: "\n")
//        
//        return [
//            """
//            public init(
//                \(raw: parameters)
//            ) {
//                \(raw: assignments)
//            }
//            """
//        ]
//    }
//}

public struct CodingKeysMacro: MemberMacro {
    
    private enum CodingKeysError: Error {
        case invalidDeclarationSyntax
        case keyPathNotFound
    }
    
    public static func expansion<Declaration, Context>(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] where Declaration : DeclGroupSyntax, Context : MacroExpansionContext {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw CodingKeysError.invalidDeclarationSyntax
        }
        
        let attributeSyntax = declaration.attributes?.first?.as(AttributeSyntax.self)
        let tupleSyntax = attributeSyntax?.argument?.as(TupleExprElementListSyntax.self)
        let content = tupleSyntax?.first?.expression.as(DictionaryExprSyntax.self)
        let dictionaryList = content?.content.as(DictionaryElementListSyntax.self)
        let valueExpression = dictionaryList?.compactMap({$0.valueExpression.as(StringLiteralExprSyntax.self)})
        let keyPathExpression = dictionaryList?.compactMap({$0.keyExpression.as(KeyPathExprSyntax.self)})
        
        guard let keyPathSyntax = keyPathExpression?.compactMap({ $0.components }),
              let stringSegmentSyntax = valueExpression?.compactMap({$0.segments.first?.as(StringSegmentSyntax.self)})
        else {
            let members = structDecl.memberBlock.members
            let variableDecl = members.compactMap { $0.decl.as(VariableDeclSyntax.self)?.bindings }
            
            let variables = variableDecl.compactMap({$0.first?.pattern})
            
            let parameters = variables
                .map { variable in
                    return  "case \(variable)"
                }
                .joined(separator: "\n")
            
            return [
                """
                enum CodingKeys: String, CodingKey {
                    \(raw: parameters)
                }
                """
            ]
        }
        
        let strings = stringSegmentSyntax.compactMap({ $0.content })
        
        let members = structDecl.memberBlock.members
        let variableDecl = members.compactMap { $0.decl.as(VariableDeclSyntax.self)?.bindings }
        
        let variables = variableDecl.compactMap({$0.first?.pattern})
        
        var testTuple: [(KeyPathComponentListSyntax, TokenSyntax)] = []
        
        for (key, value) in zip(keyPathSyntax, strings) {
            testTuple.append((key, value))
        }
        
        let parameters = variables
            .map { variable in
                if testTuple.contains(where: { (key, value) in
                    guard let key = key.first?.component else { return false }
                    return "\(key)" == "\(variable)"
                }){
                    guard let index = testTuple.firstIndex(where: { (key, value) in
                        guard let key = key.first?.component else { return false }
                        return "\(key)" == "\(variable)"
                    }) else { return "case \(variable)" }
                    return  """
                    case \(variable) = "\(testTuple[index].1.text)"
                    """
                } else {
                    return  "case \(variable)"
                }
            }
            .joined(separator: "\n")
        
        return [
            """
            enum CodingKeys: String, CodingKey {
                \(raw: parameters)
            }
            """
        ]
    }
}

@main
struct MacroLibraryPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
//        InitMacro.self,
        CodingKeysMacro.self
    ]
}
