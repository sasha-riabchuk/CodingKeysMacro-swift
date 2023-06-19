import MacroLibrary

@CodingKeysMacro<Address>([
    \.buildingNumber: "building_number"
])
struct Address: Codable {
    var buildingNumber: String?
    let city: String?
    let cityPart: String?
    let district: String?
    let country: String?
    let registryBuildingNumber: String?
    let street: String?
    let zipCode: String?
}

