if which swiftlint >/dev/null && [ $(swiftlint version) == "0.20.1" ]; then
    swiftlint lint --config ../.swiftlint.yml
else
    echo "warning: SwiftLint not installed or incorrect version installed, download from https://github.com/realm/SwiftLint"
fi
