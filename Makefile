.PHONY: ci docs

ci:
	brew update
	brew install carthage
	carthage bootstrap --verbose
	rm -rf build && xcodebuild -sdk "macosx10.12" -scheme "SwiftHelperKit OSX" -configuration Coverage -derivedDataPath build test || exit 1;
	rm -rf build && xcodebuild -sdk "iphonesimulator10.0" -destination "OS=10.0,name=iPhone 7 Plus" -scheme "SwiftHelperKit iOS" -configuration Coverage -derivedDataPath ONLY_ACTIVE_ARCH=NO test || exit 1;

docs:
	jazzy \
		--clean \
		--swift-version=3.0 \
		--author "Sebastian Volland" \
		--github_url "https://github.com/sebcode/SwiftHelperKit" \
		--root-url "https://sebcode.github.io/SwiftHelperKit" \
		--output ~/devtmp/sebcode.github.com/SwiftHelperKit/

