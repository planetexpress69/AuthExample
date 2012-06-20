//
//  AuthTestEngine.h
//  AuthExample
//
//  Created by Martin Kautz on 19.06.12.
//  Copyright (c) 2012 JAKOTA Cruise Systems GmbH. All rights reserved.
//

#import "MKNetworkEngine.h"

@interface AuthTestEngine : MKNetworkEngine

//- (void)getApiKeyForUsername:(NSString *)sUsername andPassword:(NSString *)sPassword;

//typedef void (^NetworkApiKeyResponseBlock)(MKNetworkOperation *completedOperation);

-(void) getApiKeyForUsername:(NSString *)sUsername andPassword:(NSString *)sPassword
    onCompletion:(MKNKResponseBlock) completionBlock
         onError:(MKNKErrorBlock) errorBlock;

@end
