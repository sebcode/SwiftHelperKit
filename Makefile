.PHONY: ci docs

ci:
	rm -rf build && xcodebuild -sdk "macosx10.11" -scheme "SwiftHelperKit OSX" -configuration Coverage -derivedDataPath build test || exit 1;
	rm -rf build && xcodebuild -sdk "iphonesimulator9.2" -destination "OS=9.2,name=iPhone 6S" -scheme "SwiftHelperKit iOS" -configuration Coverage -derivedDataPath ONLY_ACTIVE_ARCH=NO test || exit 1;

docs:
	jazzy \
		--clean \
		--swift-version=2.2 \
		--author "Sebastian Volland" \
		--github_url "https://github.com/sebcode/SwiftHelperKit" \
		--root-url "https://sebcode.github.io/SwiftHelperKit" \
		--output ~/devtmp/sebcode.github.com/SwiftHelperKit/

