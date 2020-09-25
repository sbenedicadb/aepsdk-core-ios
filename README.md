# AEPCore

## BETA

AEPCore is currently in beta. Use of this code is by invitation only and not otherwise supported by Adobe. Please contact your Adobe Customer Success Manager to learn more.

## About this project

The Mobile Core represents the core Adobe Experience Platform SDK that is required for every app implementation. The core contains a common set of functionality and frameworks, such as  Experience Cloud Identity services, data event hub, Rules Engine, reusable networking, disk access routines, and so on, which are required by all Adobe and third-party extensions.

## Requirements
- Xcode 11.x
- Swift 5.x

## Installation
These are currently the supported installation options:

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)
```ruby
# Podfile
use_frameworks!

# for app development, include all the following pods
target 'YOUR_TARGET_NAME' do
    pod 'AEPServices', :git => 'git@github.com:adobe/aepsdk-core-ios.git', :branch => 'main'
    pod 'AEPCore', :git => 'git@github.com:adobe/aepsdk-core-ios.git', :branch => 'main'
    pod 'AEPLifecycle', :git => 'git@github.com:adobe/aepsdk-core-ios.git', :branch => 'main'
    pod 'AEPIdentity', :git => 'git@github.com:adobe/aepsdk-core-ios.git', :branch => 'main'
    pod 'AEPRulesEngine', :git => 'git@github.com:adobe/aepsdk-rulesengine-ios.git', :branch => 'dev'
end

# for extension development, include AEPCore and its dependencies
target 'YOUR_TARGET_NAME' do
    pod 'AEPCore', :git => 'git@github.com:adobe/aepsdk-core-ios.git', :branch => 'main'
    pod 'AEPServices', :git => 'git@github.com:adobe/aepsdk-core-ios.git', :branch => 'main'
    pod 'AEPRulesEngine', :git => 'git@github.com:adobe/aepsdk-rulesengine-ios.git', :branch => 'dev'
end
```

Replace `YOUR_TARGET_NAME` and then, in the `Podfile` directory, type:

```bash
$ pod install
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

To add the AEPCore Package to your application, from the Xcode menu select:

`File > Swift Packages > Add Package Dependency...`

Enter the URL for the AEPCore package repository: `https://github.com/adobe/aepsdk-core-ios.git`.

When prompted, make sure you change the branch to `main`. (Once the repo is public, we will reference specific tags/versions instead of a branch)

There are three options for selecting your dependencies as identified by the *suffix* of the library name:

- "Dynamic" - the library will be linked dynamically
- "Static" - the library will be linked statically
- *(none)* - (default) SPM will determine whether the library will be linked dynamically or statically

Alternatively, if your project has a `Package.swift` file, you can add AEPCore directly to your dependencies:

```
dependencies: [
    .package(url: "https://github.com/adobe/aepsdk-core-ios.git", .branch("main"))
]
```

### Project Reference

Include `AEPCore.xcodeproj` in the targeted Xcode project and link all necessary libraries to your app target.

### Binaries

Run `make archive` from the root directory to generate `.xcframeworks` for each module under the `build` folder. Drag and drop all `.xcframeworks` to your app target in Xcode.

## Documentation

Additional documentation for usage and SDK architecture can be found under the [Documentation](Documentation/README.md) directory.

## Related Projects

[AEP SDK Sample App for iOS](https://github.com/adobe/aepsdk-sample-app-ios) contains iOS sample apps for the AEP SDK. Examples are provided for both Objective-c and Swift implementation.

[AEP SDK Sample Extension for iOS](https://github.com/adobe/aepsdk-sample-extension-ios) contains a sample implementation of an iOS extension for the AEP SDK. Example implementations are provided for both Objective-c and Swift.

[AEP SDK Compatibility for iOS](https://github.com/adobe/aepsdk-compatibility-ios) contains the code required to upgrade from the existing ACP SDK to the latest AEP SDK without introducing breaking changes so you can enjoy the benefits of the newest AEP SDK without needing to reimplement the SDK.

## Contributing

Contributions are welcomed! Read the [Contributing Guide](./.github/CONTRIBUTING.md) for more information.

## Licensing

This project is licensed under the Apache V2 License. See [LICENSE](LICENSE) for more information.
