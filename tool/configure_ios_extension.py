"""Idempotently wire the native Share Extension into the generated Xcode project.

No Apple account, signing secrets, or machine-specific paths are stored here.
The resulting project still requires a signing team and device verification.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
project = ROOT / "ios/Runner.xcodeproj/project.pbxproj"
text = project.read_text(encoding="utf-8")

def uid(n):
    return f"F0{n:022X}"

def add_section(name, body):
    global text
    marker = f"/* End {name} section */"
    assert text.count(marker) == 1, marker
    text = text.replace(marker, body + "\n" + marker)

if f"{uid(1)} /* ShareExtension */" not in text:
    add_section("PBXBuildFile", f'''
        {uid(10)} = {{isa = PBXBuildFile; fileRef = {uid(20)}; }};
        {uid(11)} = {{isa = PBXBuildFile; fileRef = {uid(21)}; }};
        {uid(12)} = {{isa = PBXBuildFile; fileRef = {uid(21)}; }};
        {uid(13)} = {{isa = PBXBuildFile; fileRef = {uid(22)}; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};
        {uid(14)} = {{isa = PBXBuildFile; fileRef = {uid(26)}; }};
''')
    add_section("PBXFileReference", f'''
        {uid(20)} = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ShareViewController.swift; sourceTree = "<group>"; }};
        {uid(21)} = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SharedMessageStore.swift; sourceTree = "<group>"; }};
        {uid(22)} = {{isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = ShareExtension.appex; sourceTree = BUILT_PRODUCTS_DIR; }};
        {uid(23)} = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};
        {uid(24)} = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = ShareExtension.entitlements; sourceTree = "<group>"; }};
        {uid(25)} = {{isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = tr; path = tr.lproj/Localizable.strings; sourceTree = "<group>"; }};
''')
    add_section("PBXGroup", f'''
        {uid(30)} = {{isa = PBXGroup; children = ({uid(20)}, {uid(23)}, {uid(24)}, {uid(26)}, ); path = ShareExtension; sourceTree = "<group>"; }};
        {uid(31)} = {{isa = PBXGroup; children = ({uid(21)}, ); path = Shared; sourceTree = "<group>"; }};
''')
    add_section("PBXSourcesBuildPhase", f'''
        {uid(40)} = {{isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({uid(10)}, {uid(11)}, ); runOnlyForDeploymentPostprocessing = 0; }};
''')
    add_section("PBXVariantGroup", f'''
        {uid(26)} = {{isa = PBXVariantGroup; children = ({uid(25)}, ); name = Localizable.strings; sourceTree = "<group>"; }};
''')
    add_section("PBXResourcesBuildPhase", f'''
        {uid(41)} = {{isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = ({uid(14)}, ); runOnlyForDeploymentPostprocessing = 0; }};
''')
    add_section("PBXFrameworksBuildPhase", f'''
        {uid(42)} = {{isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};
''')
    add_section("PBXCopyFilesBuildPhase", f'''
        {uid(43)} = {{isa = PBXCopyFilesBuildPhase; buildActionMask = 2147483647; dstPath = ""; dstSubfolderSpec = 13; files = ({uid(13)}, ); name = "Embed App Extensions"; runOnlyForDeploymentPostprocessing = 0; }};
''')
    add_section("PBXContainerItemProxy", f'''
        {uid(44)} = {{isa = PBXContainerItemProxy; containerPortal = 97C146E61CF9000F007C117D; proxyType = 1; remoteGlobalIDString = {uid(1)}; remoteInfo = ShareExtension; }};
''')
    add_section("PBXTargetDependency", f'''
        {uid(45)} = {{isa = PBXTargetDependency; target = {uid(1)}; targetProxy = {uid(44)}; }};
''')
    add_section("PBXNativeTarget", f'''
        {uid(1)} /* ShareExtension */ = {{
            isa = PBXNativeTarget;
            buildConfigurationList = {uid(50)};
            buildPhases = ({uid(40)}, {uid(42)}, {uid(41)}, );
            buildRules = (); dependencies = ();
            name = ShareExtension; productName = ShareExtension;
            productReference = {uid(22)};
            productType = "com.apple.product-type.app-extension";
        }};
''')
    for n, name in enumerate(["Debug", "Release", "Profile"], start=51):
        optimization = '"-Onone"' if name == "Debug" else '"-O"'
        add_section("XCBuildConfiguration", f'''
        {uid(n)} /* {name} */ = {{
            isa = XCBuildConfiguration;
            buildSettings = {{
                APPLICATION_EXTENSION_API_ONLY = YES;
                CLANG_ENABLE_MODULES = YES;
                CODE_SIGN_ENTITLEMENTS = ShareExtension/ShareExtension.entitlements;
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 1;
                GENERATE_INFOPLIST_FILE = NO;
                INFOPLIST_FILE = ShareExtension/Info.plist;
                IPHONEOS_DEPLOYMENT_TARGET = 13.0;
                LD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks", "@executable_path/../../Frameworks", );
                MARKETING_VERSION = 0.1.0;
                PRODUCT_BUNDLE_IDENTIFIER = com.example.tuzak.ShareExtension;
                PRODUCT_NAME = "$(TARGET_NAME)";
                SDKROOT = iphoneos;
                SKIP_INSTALL = YES;
                SWIFT_VERSION = 5.0;
                SWIFT_OPTIMIZATION_LEVEL = {optimization};
                TARGETED_DEVICE_FAMILY = "1,2";
            }};
            name = {name};
        }};
''')
    add_section("XCConfigurationList", f'''
        {uid(50)} = {{isa = XCConfigurationList; buildConfigurations = ({uid(51)}, {uid(52)}, {uid(53)}, ); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};
''')
    # Modify just the identified objects, without touching tests or build scripts.
    def insert_after_object_start(object_id, needle, insertion):
        global text
        start = text.index(object_id + " ")
        # Find the object definition, not a preceding reference.
        import re
        found = re.search(re.escape(object_id) + r"(?: /\*[^\n]*?\*/)? = \{", text)
        assert found, object_id
        position = text.index(needle, found.start()) + len(needle)
        text = text[:position] + insertion + text[position:]

    insert_after_object_start("97C146E51CF9000F007C117D", "children = (", f"\n                {uid(30)}, {uid(31)},")
    insert_after_object_start("97C146EF1CF9000F007C117D", "children = (", f"\n                {uid(22)},")
    insert_after_object_start("97C146EA1CF9000F007C117D", "files = (", f"\n                {uid(12)},")
    insert_after_object_start("97C146ED1CF9000F007C117D", "dependencies = (", f"\n                {uid(45)},")
    # Embed before Thin Binary to avoid extension dependency cycles.
    needle = '\t\t\t\t3B06AD1E1E4923F5004D2608 /* Thin Binary */,'
    assert needle in text
    text = text.replace(needle, f'                {uid(43)} /* Embed App Extensions */,\n' + needle)
    insert_after_object_start("97C146E61CF9000F007C117D", "targets = (", f"\n                {uid(1)} /* ShareExtension */,")
    text = text.replace("INFOPLIST_FILE = Runner/Info.plist;", "INFOPLIST_FILE = Runner/Info.plist;\n                CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;")
    text = text.replace("developmentRegion = en;", "developmentRegion = tr;")
    text = text.replace("knownRegions = (", "knownRegions = (\n                tr,")
    project.write_text(text, encoding="utf-8", newline="\n")
    print("ShareExtension target and App Group entitlements wired.")
else:
    print("ShareExtension is already configured.")
