//
//  TBAppDelegate.h
//  AuthExample
//
//  Created by Martin Kautz on 15.06.12.
//  Copyright (c) 2012 JAKOTA Cruise Systems GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthTestEngine.h"

// shorthand to access the delegate
#define TheApp ((TBAppDelegate *)[UIApplication sharedApplication].delegate)

@interface TBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow          *window;
@property (strong, nonatomic) NSString          *apiKey;
@property (strong, nonatomic) AuthTestEngine    *authTestEngine;

- (void)updateApiKey:(NSString *)anApiKey;

@end
