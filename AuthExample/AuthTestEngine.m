//
//  AuthTestEngine.m
//  AuthExample
//
//  Created by Martin Kautz on 19.06.12.
//  Copyright (c) 2012 JAKOTA Cruise Systems GmbH. All rights reserved.
//

#import "AuthTestEngine.h"

@implementation AuthTestEngine

- (void)getApiKeyForUsername:(NSString *)sUsername andPassword:(NSString *)sPassword {
    
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
    
    [op onCompletion:^(MKNetworkOperation *operation) {
        
        NSError *parseError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                             options:kNilOptions
                                                               error:&parseError];
        
        if (!parseError) {
            
            NSString *apiKey = [[json objectForKey:@"return"]objectForKey:@"key"];
            
            if (apiKey) {
                
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:apiKey 
                                                                     forKey:@"apiKey"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kGotAuthResponseNotification
                                                                    object:nil 
                                                                  userInfo:userInfo];
            } else {
                
                NSDictionary *oError = [[json objectForKey:@"return"]objectForKey:@"error"];
                
                if (oError) {
                    DLog(@"Error %@ - %@", [oError objectForKey:@"code"], [oError objectForKey:@"message"]);
                    
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[oError objectForKey:@"message"]
                                                                         forKey:@"message"];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kGotAuthResponseNotification
                                                                        object:nil 
                                                                      userInfo:userInfo];
                }
                
            }
            
        }
        
    } onError:^(NSError *error) {
        
        DLog(@"%@", [error localizedDescription]);         
        
    }];
    
    [self enqueueOperation:op];
    
}


@end
