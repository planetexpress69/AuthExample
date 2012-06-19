//
//  TBCredentialsInputViewController.h
//  AuthExample
//
//  Created by Martin Kautz on 15.06.12.
//  Copyright (c) 2012 JAKOTA Cruise Systems GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TBCredentialsInputViewControllerDelegate
- (void)didClose;
@end

@interface TBCredentialsInputViewController : UIViewController

@property (nonatomic, assign) id<TBCredentialsInputViewControllerDelegate> delegate;

@end
