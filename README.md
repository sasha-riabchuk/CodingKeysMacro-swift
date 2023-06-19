# Swift CodingKeys Macro Library

Swift CodingKeys Macro Library is an incredibly powerful Swift Compiler Plugin that introduces an automated way to generate `CodingKeys` for Codable structs in Swift. This eliminates the need for manually declaring `CodingKeys` enumeration for every Codable struct, saving you valuable time and reducing the possibility of human errors.

## Why Swift CodingKeys Macro Library is Super

1\. **Automation**: No need to manually write `CodingKeys` for each property. This library does that for you!

2\. **Reduced Errors**: Manual errors that occur while writing `CodingKeys` manually are significantly reduced.

3\. **Time-Saving**: Less time spent on boilerplate means more time for writing the code that matters.

4\. **Flexibility**: You have the freedom to specify custom string representation for any property.


## How to Use

Using this library is super simple. Here's an example:

```swift

import SwiftCodingKeysMacroLibrary

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

```

Just apply the `@CodingKeysMacro<Type>` annotation to your Codable struct and the library will take care of the rest. It will generate the `CodingKeys` enumeration for your Codable struct.

The example above will generate the following `CodingKeys`:

```swift

enum CodingKeys: String, CodingKey {
    case buildingNumber = "building_number"
    case city
    case cityPart
    case district
    case country
    case registryBuildingNumber
    case street
    case zipCode
}

```
