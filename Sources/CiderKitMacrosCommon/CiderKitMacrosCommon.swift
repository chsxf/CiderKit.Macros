public enum AccessLevelErrors: Error {
    case unknownAccessLevel(name: String)
}

public enum AccessLevel: String {
    case `fileprivate` = "fileprivate"
    case `internal` = "internal"
    case `package` = "package"
    case `private` = "private"
    case `public` = "public"

    public init(from name: String) throws {
        guard let value = Self.init(rawValue: name) else {
            throw AccessLevelErrors.unknownAccessLevel(name: name)
        }
        self = value
    }
}
