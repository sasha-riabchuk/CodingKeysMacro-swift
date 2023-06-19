import MacroLibrary

@CodingKeysMacro<Address>()
struct Address: Codable {
    var buildingNumber: String?
    let city: String?
    let cityPart: String?
    let district: String?
    let country: String?
    let registryBuildingNumber: String?
    let street: String?
    let uirAdrId: String?
    let zipCode: String?
}

