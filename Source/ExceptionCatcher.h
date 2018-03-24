//
//  ExceptionCatcher.m
//  SwiftHelperKit
//
//  Created by Sebastian Volland on 24.03.18.
//  Copyright © 2018 Sebastian Volland. All rights reserved.
//

#import <Foundation/Foundation.h>

// https://stackoverflow.com/a/35003095/503326
NS_INLINE NSException * _Nullable tryBlock(void(^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}
