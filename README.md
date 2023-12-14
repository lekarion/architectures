# Architectures
Samples of implementation some **MV*** patterns in Swift. The implementation is divided to two main blocks:
1. **Plain**, where all features, maybe except experimental ones, are implemented without using the `Combine` framework
2. **Combine**, which contains various thinngs based on the `Combine` API

### Tools & environment
- Xcode 15.0 or later
- xcodegen tool v.2.38.0 or later

### Note
The `xcodeproj` package is not commited to the repo, so you need to generate it manually using the `xcodegen` tool. After that, you should use the workspace package to work with the project.
