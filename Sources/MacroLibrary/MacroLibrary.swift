// The Swift Programming Language
// https://docs.swift.org/swift-book


//@attached(member, names: named(init))
//public macro Init() = #externalMacro(
//    module: "MacroLibraryMacros",
//    type: "InitMacro"
//)

//@attached(member, names: arbitrary)
//public macro CodingKeysMacro<T>(_ : [PartialKeyPath<T>: String] = [:]) = #externalMacro(
//    module: "MacroLibraryMacros",
//    type: "CodingKeysMacro"
//)

@attached(member, names: arbitrary)
public macro CodingKeysMacro<T>(_ : [PartialKeyPath<T>: String] = [:]) = #externalMacro(
    module: "MacroLibraryMacros",
    type: "CodingKeysMacro"
)
