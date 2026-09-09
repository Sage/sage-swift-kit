# Documentation

## Table of Contents
  - [General Macros](#general-macros)
  - [Codable Macros](#codable-macros)
  - [JsonMockable](/Documentation/JsonMockable/README.md)

## General Macros

#### Wip Macro
Mark work in progress code and convert it into an XCode warning.

    wip(feature: String, todo: String)

Example:

    #wip(feature: "New login workflow", todo: "API connection")

 
#### Debug print
Print while debugging safely. It will just add #if DEBUG.

    debug_print(_ description: String)


#### Default init
Provide init func to a struct.
Example:

    @DefaultInit
    struct Vehicle {
        let wheels: Int
        let maxSpeed: Int
        let name: String
    }

will be expanded to

    struct Vehicle {
        let wheels: Int
        let maxSpeed: Int
        let name: String
        
        func init(wheels: Int, maxSpeed: Int, name: String) {
            self.wheels = wheels
            self.maxSpeed = maxSpeed
            self.name = name
        }
    }

## Codable Macros
A set of macros for workinf easily with Codable, reducing the code needed.
As a requirement, any of the macros will need to add the macro @CustomCodable on the object.
You also need to add conformance to Codable in an extension of the object without any implementation.

#### Custom Codable Key - CustomCodableKey(String)
Allows you to create a custom key for decoding. 

Example:

    @CustomCodable
    struct Vehicle {
        let wheels: Int
        @CustomCodableKey("speedAllowed")
        let maxSpeed: Int
        let name: String
    }
    
    extension Vehicle: Codable {}

#### Custom Default Value - CustomDefault(Any)
Allows you to add a default value in case there is no value founded while decoding

Example:

    @CustomCodable
    struct Vehicle {
        let wheels: Int
        @CustomDefault(150)
        let maxSpeed: Int
        let name: String
    }
    
    extension Vehicle: Codable {}

#### Custom Date - CustomDate(dateFormat: String, defaultValue: Date? = nil)
Allows you to decode Strings into Dates with default values

Example:

    @CustomCodable
    struct Vehicle {
        let wheels: Int
        @CustomDate(dateFormat: "YYYYY-mm-dd", defaultValue: Date())
        let designed: Date
        let maxSpeed: Int
        let name: String
    }
    
    extension Vehicle: Codable {}

#### Custom Date - CustomDate(dateFormat: String, defaultValue: Date? = nil)
Allows you to decode Strings into Dates with default values

Example:

    @CustomCodable
    struct Vehicle {
        let wheels: Int
        @CustomDate(dateFormat: "YYYYY-mm-dd", defaultValue: Date())
        let designed: Date
        let maxSpeed: Int
        let name: String
    }
    
    extension Vehicle: Codable {}

#### Custom Hashable - CustomHashable(parameters: [String])
Allows you to add Hashable conformance providing the properties you want to use.

Example:

    @CustomCodable
    CustomHashable(parameters: ["wheels", "name"])
    struct Vehicle {
        let wheels: Int
        let designed: Date
        let maxSpeed: Int
        let name: String
    }
    
    extension Vehicle: Codable {}

will expand to:

    extension Vehicle: Hashable {
        public func hash(into hasher: inout Hasher) {
            hasher.combine(wheels)
            hasher.combine(name)
        }
    }

#### Custom Equatable - CustomEquatable(parameters: [String])
Allows you to add Equatable conformance providing the properties you want to use.

Example:

    @CustomCodable
    CustomEquatable(parameters: ["wheels", "maxSpeed"])
    struct Vehicle {
        let wheels: Int
        let designed: Date
        let maxSpeed: Int
        let name: String
    }
    
    extension Vehicle: Codable {}

will expand to:

    extension Vehicle: Equatable {
        public static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
            lhs.wheels == rhs.wheel && lhs.maxSpeed == rhs.maxSpeed
        }
    }

#### Custom URL - CustomDate(dateFormat: String, defaultValue: Date? = nil)
Allows you to decode Strings into optional URL

Example:

    @CustomCodable
    struct Vehicle {
        let wheels: Int
        let designed: Date
        let maxSpeed: Int
        let name: String
        @CustomURL
        let website: URL?
    }
    
    extension Vehicle: Codable {}

Of course you can combine all of them:

	    @CustomCodable
	    @DefaultInit
	    @CustomHashable(["wheels", "name"])
	    @CustomEquatable(["wheels", "designed"])
        struct Vehicle {
			@CustomCodableKey("number_of_wheels")
            let wheels: Int
            
            @CustomDate(dateFormat: "YYYYY-mm-dd", defaultValue: Date())
            let designed: Date
            
            @CustomDefault(150)
            let maxSpeed: Int
            
            let name: String
            
            @CustomURL
            let website: URL?
        }
        
        extension Vehicle: Codable {}

## AutoMockable Macro

#### Auto Mockable - @AutoMockable(accessLevel: String, classInheritance: Bool)

Generates a mock implementation of a protocol, perfect for unit testing. The macro creates a final class that conforms to a regular protocol, or an actor when the protocol inherits from `Actor`.

**Requirements**: The `#if TESTING` condition is used to enable/disable the macro. You need to add the `-DTESTING` compiler flag to your test targets.

**Parameters**:

- `accessLevel`: The access level for the generated mock type (default: "internal")
- `classInheritance`: Whether the mock should inherit from the protocol's superclasses (default: false)

##### Example Usage

```swift
@AutoMockable(accessLevel: "public", classInheritance: false)
protocol UserService {
    var userName: String { get }
    func fetchUser(id: Int) -> User
    func saveUser(_ user: User) -> Bool
}
```

This generates a `UserServiceMock` class that:

- Conforms to `UserService` protocol
- Tracks all method calls for assertion in tests
- Provides mock data for testing

##### Actor protocols

When a protocol inherits from `Actor`, its mock is generated as an actor instead of a final class:

```swift
@AutoMockable(accessLevel: "public")
public protocol BackgroundWorker: Actor {
    func process(_ value: String) -> String
}

let worker = BackgroundWorkerMock()
let mocks = await worker.mock
mocks.process_Value.returnValue = "processed"

let result = await worker.process("input")
```

The generated declaration is `public actor BackgroundWorkerMock`. Access to its mock container and protocol methods follows normal actor isolation rules.

##### Generic functions

Generic method parameters and return values are supported, including trailing `where` clauses:

```swift
@AutoMockable()
protocol ValueTransforming {
    func transform<T>(_ value: T) -> T where T: Sendable
}

let transformer = ValueTransformingMock()
transformer.mock.transform_Value.returnValue = "output"

let result: String = transformer.transform("input")
let receivedValue = transformer.mock.transform_Value.lastCall?.value as? String
```

Because `T` exists only for the duration of each method call, generic parameters are recorded as `Any` and generic return values are configured as `Any?`. Cast captured arguments to their expected concrete type when asserting them. The configured return value must match the concrete return type inferred at the call site.
