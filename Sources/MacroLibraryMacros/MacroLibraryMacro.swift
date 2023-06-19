import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// A struct that defines a macro for automatically generating CodingKeys
public struct CodingKeysMacro: MemberMacro {
    
    /// Defines the types of errors that can occur in CodingKeysMacro
    private enum CodingKeysError: Error {
        case invalidDeclarationSyntax
        case keyPathNotFound
    }
    
    /// A function that generates an array of `DeclSyntax` based on the given attribute syntax,
    /// declaration and context.
    /// - Parameters:
    ///   - node: An `AttributeSyntax` that represents the syntax of an attribute.
    ///   - declaration: A `Declaration` that represents the syntax of a declaration.
    ///   - context: A `Context` that represents the context of the macro expansion.
    /// - Throws: Throws an error of type `CodingKeysError` if an invalid declaration syntax is encountered.
    /// - Returns: Returns an array of `DeclSyntax`.
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
            return  Self.generateDefaultCodingKeys(structDecl)
        }
        
        let strings = stringSegmentSyntax.compactMap({ $0.content })
        let members = structDecl.memberBlock.members
        let variableDecl = members.compactMap { $0.decl.as(VariableDeclSyntax.self)?.bindings }
        let variables = variableDecl.compactMap({$0.first?.pattern})
        var valueTuple: [(KeyPathComponentListSyntax, TokenSyntax)] = []
        
        for (key, value) in zip(keyPathSyntax, strings) {
            valueTuple.append((key, value))
        }
        
        let parameters = variables
            .map { variable in
                if valueTuple.contains(where: { (key, value) in
                    guard let key = key.first?.component else { return false }
                    return "\(key)" == "\(variable)"
                }){
                    guard let index = valueTuple.firstIndex(where: { (key, value) in
                        guard let key = key.first?.component else { return false }
                        return "\(key)" == "\(variable)"
                    }) else { return "case \(variable)" }
                    return  """
                    case \(variable) = "\(valueTuple[index].1.text)"
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
    
    /// A function that generates default coding keys.
    /// - Parameter structDecSyntax: A `StructDeclSyntax` that represents the syntax of a struct declaration.
    /// - Returns: Returns an array of `DeclSyntax`.
    public static func generateDefaultCodingKeys(_ structDecSyntax: StructDeclSyntax) -> [DeclSyntax] {
        let members = structDecSyntax.memberBlock.members
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
}

/// A struct that defines a compiler plugin.
/// The plugin provides macros.
@main
struct MacroLibraryPlugin: CompilerPlugin {
    /// An array of Macro types provided by the plugin.
    let providingMacros: [Macro.Type] = [
        CodingKeysMacro.self
    ]
}
