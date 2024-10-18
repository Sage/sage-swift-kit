
# Sage Swift Kit
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A set of tools for working on iOS development. 
Two different type of tools are provided: general macros and codable macros.

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

#### Custom URL
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

## Contributing
We welcome contributions from the community! Please see our [Contributing Guidelines](CONTRIBUTING.md) for more information on how to get started.

## Versioning
We use [Semantic Versioning](https://semver.org) for this project. Semantic Versioning (SemVer) is a versioning scheme that provides clear guidelines on how version numbers are assigned and incremented. This helps in communicating the nature of changes in each release and ensures compatibility and stability.

## Licence
Sage Swift Kit is licensed under the [Apache-2.0 licence](LICENSE).

Copyright (c) 2024 Sage Group Plc. All rights reserved.
