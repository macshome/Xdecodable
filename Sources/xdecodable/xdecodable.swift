import Foundation

/// Represents an Xcode project file structure decoded from a `project.pbxproj` file.
///
/// This is the root object that contains all project metadata including targets, build phases,
/// file references, and build configurations.
public struct XcodeProject: Decodable {
    /// The archive version of the project file format
    public let archiveVersion: String

    /// The object version indicating the Xcode compatibility level
    public let objectVersion: String

    /// The unique identifier of the root `PBXProject` object
    public let rootObject: String

    /// Dictionary mapping unique object IDs to their corresponding project objects
    public let objects: [String: ProjectObject]
}

/// Represents any type of object that can appear in an Xcode project file.
///
/// Xcode project files contain heterogeneous collections of objects identified by their `isa` type.
/// This enum discriminates between different object types and provides type-safe access to their data.
public enum ProjectObject: Decodable {
    /// A group container for organizing files and other groups in the project navigator
    case group(PBXGroup)
    /// A reference to a file in the project
    case fileReference(PBXFileReference)
    /// A file included in a build phase
    case buildFile(PBXBuildFile)
    /// A native build target (e.g., app, framework, test bundle)
    case nativeTarget(PBXNativeTarget)
    /// An aggregate target that runs build phases but doesn't produce a binary output
    case aggregateTarget(PBXAggregateTarget)
    /// The root project object containing project-wide settings
    case project(PBXProject)
    /// A list of build configurations (Debug, Release, etc.)
    case configurationList(XCConfigurationList)
    /// A single build configuration with its settings
    case buildConfiguration(XCBuildConfiguration)
    /// A generic build phase (sources, frameworks, resources, headers)
    case buildPhase(PBXBuildPhase)
    /// A reference to a remote Swift package repository
    case remotePackageReference(XCRemoteSwiftPackageReference)
    /// A dependency on a Swift package product
    case packageProductDependency(XCSwiftPackageProductDependency)
    /// An unknown or unsupported object type with raw data preserved
    case unknown([String: AnyCodable])
    /// A proxy for items in other projects or targets
    case containerItemProxy(PBXContainerItemProxy)
    /// A dependency relationship between targets
    case targetDependency(PBXTargetDependency)
    /// A build phase that copies files to a specific location in the bundle
    case copyFilesBuildPhase(PBXCopyFilesBuildPhase)
    /// A build phase that runs a shell script during the build
    case shellScriptBuildPhase(PBXShellScriptBuildPhase)
    /// A group of localized file variants
    case variantGroup(PBXVariantGroup)
    /// A file system synchronized root group (Xcode 16+)
    case fileSystemSynchronizedRootGroup(PBXFileSystemSynchronizedRootGroup)
    /// A legacy external build system target
    case legacyTarget(PBXLegacyTarget)
    /// A custom build rule for processing specific file types
    case buildRule(PBXBuildRule)
    /// A proxy reference to a product from another project
    case referenceProxy(PBXReferenceProxy)

    enum CodingKeys: String, CodingKey {
        case isa
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isa = try container.decode(String.self, forKey: .isa)

        let singleValueContainer = try decoder.singleValueContainer()

        switch isa {
        case "PBXGroup":
            self = .group(try singleValueContainer.decode(PBXGroup.self))
        case "PBXFileReference":
            self = .fileReference(try singleValueContainer.decode(PBXFileReference.self))
        case "PBXBuildFile":
            self = .buildFile(try singleValueContainer.decode(PBXBuildFile.self))
        case "PBXNativeTarget":
            self = .nativeTarget(try singleValueContainer.decode(PBXNativeTarget.self))
        case "PBXAggregateTarget":
            self = .aggregateTarget(try singleValueContainer.decode(PBXAggregateTarget.self))
        case "PBXProject":
            self = .project(try singleValueContainer.decode(PBXProject.self))
        case "XCConfigurationList":
            self = .configurationList(try singleValueContainer.decode(XCConfigurationList.self))
        case "XCBuildConfiguration":
            self = .buildConfiguration(try singleValueContainer.decode(XCBuildConfiguration.self))
        case "PBXSourcesBuildPhase", "PBXFrameworksBuildPhase", "PBXResourcesBuildPhase", "PBXHeadersBuildPhase":
            self = .buildPhase(try singleValueContainer.decode(PBXBuildPhase.self))
        case "XCRemoteSwiftPackageReference":
            self = .remotePackageReference(try singleValueContainer.decode(XCRemoteSwiftPackageReference.self))
        case "XCSwiftPackageProductDependency":
            self = .packageProductDependency(try singleValueContainer.decode(XCSwiftPackageProductDependency.self))
        case "PBXContainerItemProxy":
            self = .containerItemProxy(try singleValueContainer.decode(PBXContainerItemProxy.self))
        case "PBXTargetDependency":
            self = .targetDependency(try singleValueContainer.decode(PBXTargetDependency.self))
        case "PBXCopyFilesBuildPhase":
            self = .copyFilesBuildPhase(try singleValueContainer.decode(PBXCopyFilesBuildPhase.self))
        case "PBXShellScriptBuildPhase":
            self = .shellScriptBuildPhase(try singleValueContainer.decode(PBXShellScriptBuildPhase.self))
        case "PBXVariantGroup":
            self = .variantGroup(try singleValueContainer.decode(PBXVariantGroup.self))
        case "PBXFileSystemSynchronizedRootGroup":
            self = .fileSystemSynchronizedRootGroup(
                try singleValueContainer.decode(PBXFileSystemSynchronizedRootGroup.self)
            )
        case "PBXLegacyTarget":
            self = .legacyTarget(try singleValueContainer.decode(PBXLegacyTarget.self))
        case "PBXBuildRule":
            self = .buildRule(try singleValueContainer.decode(PBXBuildRule.self))
        case "PBXReferenceProxy":
            self = .referenceProxy(try singleValueContainer.decode(PBXReferenceProxy.self))
        default:
            self = .unknown(try singleValueContainer.decode([String: AnyCodable].self))
        }
    }
}

/// Represents a proxy for accessing items from other projects or containers.
///
/// Used when a target depends on a product from another project or when referencing
/// items across project boundaries.
public struct PBXContainerItemProxy: Decodable {
    /// Object type identifier (always "PBXContainerItemProxy")
    public let isa: String
    /// ID of the container (project) being referenced
    public let containerPortal: String
    /// Type of proxy (1 = target reference, 2 = file reference)
    public let proxyType: String
    /// Global ID of the remote object in the referenced container
    public let remoteGlobalIDString: String
    /// Human-readable name of the remote item
    public let remoteInfo: String
}

/// Represents a dependency on another target.
///
/// Defines the relationship when one target must be built before another target can be built.
public struct PBXTargetDependency: Decodable {
    /// Object type identifier (always "PBXTargetDependency")
    public let isa: String
    /// ID of the target this depends on (for same-project dependencies)
    public let target: String?
    /// ID of the proxy for cross-project dependencies
    public let targetProxy: String?
    /// ID of the Swift package product dependency
    public let productRef: String?
}

/// Represents a build phase that copies files to a specific destination in the bundle.
///
/// Used to copy resources, frameworks, or other files to designated locations during the build process.
public struct PBXCopyFilesBuildPhase: Decodable {
    /// Object type identifier (always "PBXCopyFilesBuildPhase")
    public let isa: String
    /// Bitmask for when this phase runs (optional in some Xcode versions)
    public let buildActionMask: String?
    /// Destination path for copied files (relative to destination subfolder)
    public let dstPath: String?
    /// Destination subfolder specification (numeric code indicating location)
    public let dstSubfolderSpec: String
    /// Array of file IDs to copy
    public let files: [String]
    /// Whether to run only for deployment postprocessing (optional in some Xcode versions)
    public let runOnlyForDeploymentPostprocessing: String?
    /// Display name of this build phase (optional)
    public let name: String?
}

/// Represents a build phase that executes a shell script during the build.
///
/// Commonly used for running code generation tools, linters, or custom build steps.
/// The script can have input and output file dependencies for proper incremental builds.
public struct PBXShellScriptBuildPhase: Decodable {
    /// Object type identifier (always "PBXShellScriptBuildPhase")
    public let isa: String
    /// Bitmask for when this phase runs (optional in some Xcode versions)
    public let buildActionMask: String?
    /// Array of file IDs processed by this phase (optional for script-only phases)
    public let files: [String]?
    /// Paths to `.xcfilelist` files listing input files
    public let inputFileListPaths: [String]?
    /// Individual input file paths
    public let inputPaths: [String]?
    /// Display name of this build phase (optional)
    public let name: String?
    /// Paths to `.xcfilelist` files listing output files
    public let outputFileListPaths: [String]?
    /// Individual output file paths
    public let outputPaths: [String]?
    /// Whether to run only for deployment postprocessing (optional in some Xcode versions)
    public let runOnlyForDeploymentPostprocessing: String?
    /// Path to the shell interpreter (e.g., `/bin/sh`)
    public let shellPath: String
    /// The script to execute (can be a single string or array of strings)
    public let shellScript: AnyCodable
    /// Whether to show environment variables in the build log (`0` or `1`)
    public let showEnvVarsInLog: String?
}

/// Represents a group containing localized variants of a file.
///
/// Used for localizable resources where different versions exist for different languages or regions.
/// For example, a `Localizable.strings` file with English, Spanish, and French variants.
public struct PBXVariantGroup: Decodable {
    /// Object type identifier (always "PBXVariantGroup")
    public let isa: String
    /// Array of child file reference IDs representing different localizations
    public let children: [String]
    /// Display name of the variant group (typically the base resource name)
    public let name: String
    /// Source tree location type (e.g., `<group>`, `SOURCE_ROOT`)
    public let sourceTree: String
}

/// Represents a file system synchronized root group (Xcode 16+).
///
/// Introduced in Xcode 16, this type of group automatically synchronizes with a directory
/// on disk, automatically including new files without manual project updates.
public struct PBXFileSystemSynchronizedRootGroup: Decodable {
    /// Object type identifier (always "PBXFileSystemSynchronizedRootGroup")
    public let isa: String
    /// File system path to synchronize
    public let path: String?
    /// Source tree location type (e.g., `<group>`, `SOURCE_ROOT`)
    public let sourceTree: String?
    /// Array of exception rule IDs for files/folders to exclude
    public let exceptions: [String]?
    /// Explicit file type mappings for overriding auto-detection
    public let explicitFileTypes: [String: AnyCodable]?
    /// Explicitly specified folder paths within the synchronized directory
    public let explicitFolders: [String]?
}

/// Represents a group container for organizing project files in the project navigator.
///
/// Groups can contain files, other groups, or a mix of both, forming a hierarchical structure.
/// The group's appearance in Xcode doesn't necessarily match the file system structure.
public struct PBXGroup: Decodable {
    /// Object type identifier (always "PBXGroup")
    public let isa: String
    /// Array of child object IDs (files or subgroups)
    public let children: [String]?
    /// Display name of the group in the project navigator
    public let name: String?
    /// File system path of the group (relative to source tree)
    public let path: String?
    /// Source tree location type (e.g., `<group>`, `SOURCE_ROOT`, `BUILT_PRODUCTS_DIR`)
    public let sourceTree: String?
}

/// Represents a reference to a file in the project.
///
/// File references point to actual files on disk and specify their type and location.
/// They can represent source files, resources, frameworks, or any other file type.
public struct PBXFileReference: Decodable {
    /// Object type identifier (always "PBXFileReference")
    public let isa: String
    /// Last known file type identifier (e.g., `sourcecode.swift`, `text.plist.xml`)
    public let lastKnownFileType: String?
    /// File system path to the file
    public let path: String?
    /// Source tree location type (e.g., `<group>`, `SOURCE_ROOT`, `BUILT_PRODUCTS_DIR`)
    public let sourceTree: String?
    /// Explicitly set file type identifier (overrides automatic detection)
    public let explicitFileType: String?
    /// Whether to include in the index for search (`0` or `1`)
    public let includeInIndex: String?
}

/// Represents a file included in a build phase.
///
/// Links a file reference or package product to a specific build phase (e.g., compile, link, copy).
public struct PBXBuildFile: Decodable {
    /// Object type identifier (always "PBXBuildFile")
    public let isa: String
    /// ID of the file reference being built
    public let fileRef: String?
    /// ID of the package product reference (for Swift package dependencies)
    public let productRef: String?
}

/// Represents a native build target that produces a binary output.
///
/// Native targets can produce applications, frameworks, libraries, test bundles, or other binary products.
/// Each target has its own build configurations, phases, and dependencies.
public struct PBXNativeTarget: Decodable {
    /// Object type identifier (always "PBXNativeTarget")
    public let isa: String
    /// Display name of the target shown in Xcode
    public let name: String
    /// ID of the configuration list containing Debug, Release, etc.
    public let buildConfigurationList: String
    /// Array of build phase IDs (compile sources, link frameworks, copy resources, etc.)
    public let buildPhases: [String]
    /// Array of target dependency IDs this target depends on
    public let dependencies: [String]?
    /// Array of Swift package product dependency IDs
    public let packageProductDependencies: [String]?
    /// Product name (may differ from target name)
    public let productName: String?
    /// ID of the file reference for the built product
    public let productReference: String?
    /// Product type identifier (e.g., `com.apple.product-type.application`)
    public let productType: String?
}

/// Represents an aggregate target that doesn't produce a binary output.
///
/// Aggregate targets are used to group build phases and dependencies without creating a product.
/// They're commonly used for running scripts, preprocessing, or coordinating other targets.
public struct PBXAggregateTarget: Decodable {
    /// Object type identifier (always "PBXAggregateTarget")
    public let isa: String
    /// Display name of the target shown in Xcode
    public let name: String
    /// ID of the configuration list containing Debug, Release, etc.
    public let buildConfigurationList: String
    /// Array of build phase IDs (typically shell script phases)
    public let buildPhases: [String]
    /// Array of target dependency IDs this target depends on
    public let dependencies: [String]?
    /// Product name (though no actual product is created)
    public let productName: String?
}

/// Represents the root project object containing project-wide settings.
///
/// This is the main container for the entire Xcode project, holding references to all targets,
/// build configurations, file groups, and package dependencies.
public struct PBXProject: Decodable {
    /// Object type identifier (always "PBXProject")
    public let isa: String
    /// ID of the project's configuration list
    public let buildConfigurationList: String
    /// Xcode compatibility version (optional in older projects)
    public let compatibilityVersion: String?
    /// Development region/language (e.g., "en", "English")
    public let developmentRegion: String
    /// ID of the main group containing project files
    public let mainGroup: String
    /// ID of the group containing build products (optional in some projects)
    public let productRefGroup: String?
    /// Array of target IDs in this project
    public let targets: [String]
    /// Array of Swift package reference IDs (optional)
    public let packageReferences: [String]?
    /// Project directory path
    public let projectDirPath: String?
    /// Project root path
    public let projectRoot: String?
}

/// Represents a list of build configurations for a project or target.
///
/// Configuration lists contain different build configurations (e.g., Debug, Release)
/// and specify which one is the default.
public struct XCConfigurationList: Decodable {
    /// Object type identifier (always "XCConfigurationList")
    public let isa: String
    /// Array of build configuration IDs
    public let buildConfigurations: [String]
    /// Whether the default configuration is visible in the UI (optional in some Xcode versions)
    public let defaultConfigurationIsVisible: String?
    /// Name of the default configuration (e.g., "Release")
    public let defaultConfigurationName: String
}

/// Represents a single build configuration with its settings.
///
/// Build configurations define compiler flags, preprocessor macros, and other build settings
/// that vary between different build scenarios (e.g., Debug vs. Release).
public struct XCBuildConfiguration: Decodable {
    /// Object type identifier (always "XCBuildConfiguration")
    public let isa: String
    /// Configuration name (e.g., "Debug", "Release", "Staging")
    public let name: String
    /// Dictionary of build settings (e.g., SWIFT_VERSION, PRODUCT_NAME)
    public let buildSettings: [String: AnyCodable]
}

/// Represents a generic build phase (sources, frameworks, resources, headers).
///
/// Build phases define steps in the build process such as compiling source files,
/// linking frameworks, copying resources, or processing headers.
public struct PBXBuildPhase: Decodable {
    /// Object type identifier (e.g., "PBXSourcesBuildPhase", "PBXFrameworksBuildPhase")
    public let isa: String
    /// Bitmask for when this phase runs (optional in some Xcode versions)
    public let buildActionMask: String?
    /// Array of build file IDs to process in this phase
    public let files: [String]
    /// Whether to run only for deployment postprocessing (optional in some Xcode versions)
    public let runOnlyForDeploymentPostprocessing: String?
}

/// Represents a reference to a remote Swift package repository.
///
/// Defines a Swift package dependency by specifying the repository URL and version requirements.
public struct XCRemoteSwiftPackageReference: Decodable {
    /// Object type identifier (always "XCRemoteSwiftPackageReference")
    public let isa: String
    /// URL of the package repository (e.g., GitHub URL)
    public let repositoryURL: String
    /// Version requirement specification
    public let requirement: PackageRequirement
}

/// Represents the type of version requirement for a Swift package.
public enum PackageRequirementKind: String, Decodable, CaseIterable {
    /// Require versions up to the next minor version (e.g., 1.2.x)
    case upToNextMinorVersion
    /// Require versions up to the next major version (e.g., 1.x.x)
    case upToNextMajorVersion
    /// Require a specific branch
    case branch
    /// Require an exact version
    case exactVersion
    /// Require a version within a specific range
    case versionRange
    /// Require a specific commit revision
    case revision
}

/// Represents version requirements for a Swift package.
///
/// Specifies how package versions are resolved (e.g., semantic versioning ranges, branches, or specific revisions).
public struct PackageRequirement: Decodable {
    /// Requirement kind (type of version constraint)
    public let kind: PackageRequirementKind
    /// Minimum version for range-based requirements (e.g., "1.0.0")
    public let minimumVersion: String?
    /// Maximum version for range-based requirements (e.g., "2.0.0")
    public let maximumVersion: String?
    /// Branch name for branch-based requirements (e.g., "main", "develop")
    public let branch: String?
    /// Commit revision for revision-based requirements (full commit SHA)
    public let revision: String?
}

/// Represents a dependency on a Swift package product.
///
/// Links a target to a specific product (library or executable) from a Swift package.
public struct XCSwiftPackageProductDependency: Decodable {
    /// Object type identifier (always "XCSwiftPackageProductDependency")
    public let isa: String
    /// ID of the package reference this product comes from
    public let package: String?
    /// Name of the package product (e.g., library name)
    public let productName: String
}

/// Represents a legacy target using an external build system.
///
/// Legacy targets delegate building to an external tool (e.g., Make, CMake) instead of
/// using Xcode's native build system. Useful for integrating existing build processes.
public struct PBXLegacyTarget: Decodable {
    /// Object type identifier (always "PBXLegacyTarget")
    public let isa: String
    /// Arguments passed to the build tool
    public let buildArgumentsString: String?
    /// ID of the configuration list for this target
    public let buildConfigurationList: String?
    /// Array of build phase IDs
    public let buildPhases: [String]?
    /// Path to the build tool executable
    public let buildToolPath: String?
    /// Working directory for the build tool
    public let buildWorkingDirectory: String?
    /// Array of target dependency IDs
    public let dependencies: [String]?
    /// Display name of the target
    public let name: String?
    /// Whether to pass build settings as environment variables (`0` or `1`)
    public let passBuildSettingsInEnvironment: String?
    /// Product name
    public let productName: String?
}

/// Represents a custom build rule for processing specific file types.
///
/// Build rules define how files of a particular type should be compiled or processed,
/// allowing custom transformations beyond Xcode's standard build system.
public struct PBXBuildRule: Decodable {
    /// Object type identifier (always "PBXBuildRule")
    public let isa: String
    /// Compiler specification identifier for this rule
    public let compilerSpec: String?
    /// File type pattern this rule processes (e.g., UTI or file extension)
    public let fileType: String?
    /// Input file path patterns
    public let inputFiles: [String]?
    /// Whether the rule is user-editable (`0` or `1`)
    public let isEditable: String?
    /// Output file path patterns
    public let outputFiles: [String]?
    /// Compiler flags to apply to output files
    public let outputFilesCompilerFlags: [String]?
    /// Rule pattern for generating output file names
    public let outputFilesRule: String?
    /// Custom script for processing files
    public let script: String?
    /// Script input file path patterns
    public let scriptInputFiles: [String]?
    /// Script output file path patterns
    public let scriptOutputFiles: [String]?
}

/// Represents a proxy reference to a product from another project.
///
/// Used when a project references build products from external projects without directly
/// embedding the external project files.
public struct PBXReferenceProxy: Decodable {
    /// Object type identifier (always "PBXReferenceProxy")
    public let isa: String
    /// File type of the referenced product
    public let fileType: String?
    /// Path to the referenced product
    public let path: String?
    /// ID of the remote reference
    public let remoteRef: String?
    /// Source tree location type
    public let sourceTree: String?
}

/// A type-erased wrapper for values that can be of any type.
///
/// Used for decoding heterogeneous data structures in project files where the exact type
/// isn't known at compile time. Supports primitives, arrays, and dictionaries.
public struct AnyCodable: Decodable {
    /// The underlying value of any type
    public let value: Any

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode value")
        }
    }
}
