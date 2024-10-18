# `@JsonMockable`

The `@JsonMockable` macro is used to generate mockable data from a JSON file, making it easier to decode JSON into Swift models for testing purposes. This macro simplifies the process of decoding JSON data by providing automatic conformance to mockable behavior based on a JSON file, using customizable decoding strategies and bundles.

## Parameters
  * `keyDecodingStrategy`: JSONDecoder.KeyDecodingStrategy: Specifies the strategy to use when decoding keys in the JSON file. The available options are:
    
    * `.useDefaultKeys`: Use the keys in the JSON as-is.
        
    * `.convertFromSnakeCase`: Convert keys from snake\_case to camelCase when decoding.
        
* `bundle`: Bundle: Specifies the Bundle from which the JSON file will be loaded. This could be the app's main bundle or a test bundle, depending on where the mock data resides.
    
* `jsonFile`: String? _(optional)_: An optional string representing the name of the JSON file that contains mock data. If nil, the macro will look for a JSON file that matches the name of the type to which the macro is applied.
  
## Usage Example
Assume you have a `User` struct that conforms to Decodable and you want to generate mockable data from a JSON file with the same name:

``` swift
@JsonMockable(
    keyDecodingStrategy: .convertFromSnakeCase,
    bundle: .main
)
struct User: Decodable {
    ...
}
```

In case the JSON file has different name from your class / struct: 

``` swift
@JsonMockable(
    keyDecodingStrategy: .convertFromSnakeCase,
    bundle: .main,
    jsonFile: "FILE_NAME"
)
struct User: Decodable {
    ...
}
```
## Methods
`@JsonMockable` expose a method to your entity that you can use to create other

``` swift
private static func getMock(bundle: Bundle, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy, fileName: String?) throws -> Self

```

### Usage
``` swift
@JsonMockable(
    keyDecodingStrategy: .convertFromSnakeCase,
    bundle: .main
)
struct User: Decodable {
    var example: String
    
    static var mockA: Self {
        get throws {
            try getMock(bundle: .main, keyDecodingStrategy: .convertFromSnakeCase, fileName: "fileA")
        }
    }
    
    static var mockB: Self {
        get throws {
            try getMock(bundle: .main, keyDecodingStrategy: .convertFromSnakeCase, fileName: "fileB")
        }
    }
}

```