/// This playground shows how to make an enum `Codable` given any `Codable` associated value(s).

import Foundation

/// A `Codable` struct to be used for associated value for `SomeEnum`.
struct SomeCodable: Codable {
    let name: String
    let count: Int
}

/// An enum for `Codable` demo
enum SomeEnum {
    case noAssociatedValue
    case intAssociatedValue(Int)
    case stringAssociatedValue(String)
    case codableAssociatedValue(SomeCodable)
    case doubleArrayAssociatedValue([Double])
    case assortedAssociatedValue(Int, String, SomeCodable, [Double])
}

extension SomeEnum: Codable {
    
    // one coding key for each enum case
    private enum CodingKeys: String, CodingKey { case noAvKey, intAvKey, stringAvKey, codableAvKey, doubleArrayAvKey, assortedAvKey }
    
    // for coding the `assortedAssociatedValue` case
    private struct AssortedAssociatedValueCase: Codable {
        let someInt: Int
        let someString: String
        let someCodableValue: SomeCodable
        let someDoubleArrayValue: [Double]
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.noAvKey) {
            self = .noAssociatedValue
        } else if let intAv = try? container.decode(Int.self, forKey: .intAvKey) {
            self = .intAssociatedValue(intAv)
        } else if let stringAv = try? container.decode(String.self, forKey: .stringAvKey) {
            self = .stringAssociatedValue(stringAv)
        } else if let codableAv = try? container.decode(SomeCodable.self, forKey: .codableAvKey) {
            self = .codableAssociatedValue(codableAv)
        } else if let doubleArrayAv = try? container.decode([Double].self, forKey: .doubleArrayAvKey) {
            self = .doubleArrayAssociatedValue(doubleArrayAv)
        } else if let assortedAvCase = try? container.decode(AssortedAssociatedValueCase.self, forKey: .assortedAvKey) {
            self = .assortedAssociatedValue(assortedAvCase.someInt, assortedAvCase.someString, assortedAvCase.someCodableValue, assortedAvCase.someDoubleArrayValue)
        } else {
            fatalError("Failed to decode `\(SomeEnum.self)`")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .noAssociatedValue:
            try container.encode(true, forKey: .noAvKey)
        case .intAssociatedValue(let v):
            try container.encode(v, forKey: .intAvKey)
        case .stringAssociatedValue(let v):
            try container.encode(v, forKey: .stringAvKey)
        case .codableAssociatedValue(let v):
            try container.encode(v, forKey: .codableAvKey)
        case .doubleArrayAssociatedValue(let v):
            try container.encode(v, forKey: .doubleArrayAvKey)
        case .assortedAssociatedValue(let v):
            let caseStruct = AssortedAssociatedValueCase(someInt: v.0, someString: v.1, someCodableValue: v.2, someDoubleArrayValue: v.3)
            try container.encode(caseStruct, forKey: .assortedAvKey)
        }
    }
}

let originalEnum = SomeEnum.assortedAssociatedValue(1, "2", SomeCodable(name: "3", count: 4), [5, 6, 7])
do {
    print("Original enum:", originalEnum)
    let encodedData = try JSONEncoder().encode(originalEnum)
    let decodedEnum = try JSONDecoder().decode(SomeEnum.self, from: encodedData)
    print("Decoded enum:", decodedEnum)
} catch {
    print("\(error)")
}

