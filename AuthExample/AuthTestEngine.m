//
//  AuthTestEngine.m
//  AuthExample
//
//  Created by Martin Kautz on 19.06.12.
//  Copyright (c) 2012 JAKOTA Cruise Systems GmbH. All rights reserved.
//

#import "AuthTestEngine.h"
#import "TBAppDelegate.h"

@implementation AuthTestEngine

-(void) getApiKeyForUsername:(NSString *)sUsername 
                 andPassword:(NSString *)sPassword 
                onCompletion:(MKNKResponseBlock) completionBlock 
                     onError:(MKNKErrorBlock) errorBlock {
    
    NSString *encodedUsername = [sUsername urlEncodedString];
    NSString *encodedPassword = [sPassword urlEncodedString];
    
    NSString *sPath = [NSString stringWithFormat:kApiLoginPath, 
                       encodedUsername, 
                       encodedPassword];
    
    NSMutableDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"json", @"apiOut", 
                                   nil];
    
    MKNetworkOperation *op = [self operationWithPath:sPath 
                                              params:params 
                                          httpMethod:@"GET" 
                                                 ssl:YES];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        
        completionBlock(completedOperation);        
        
    } onError:^(NSError* error) {

        errorBlock(error);
    
    }];
    
    [self enqueueOperation:op];
}

@end
