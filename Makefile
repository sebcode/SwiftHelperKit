.PHONY: ci

ci:
	rm -rf build && xcodebuild -sdk "macosx10.11" -scheme "SwiftHelperKit OSX" -configuration Coverage -derivedDataPath build test || exit 1;
	rm -rf build && xcodebuild -sdk "iphonesimulator9.2" -destination "OS=9.2,name=iPhone 6S" -scheme "SwiftHelperKit iOS" -configuration Coverage -derivedDataPath ONLY_ACTIVE_ARCH=NO test || exit 1;

