if which swiftlint >/dev/null && [ $(swiftlint version) == "0.24.0" ]; then
    swiftlint lint --config ../.swiftlint.yml
else
    echo "warning: SwiftLint not installed or incorrect version installed, download from https://github.com/realm/SwiftLint"
fi
