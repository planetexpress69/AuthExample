//
//  TBCredentialsInputViewController.m
//  AuthExample
//
//  Created by Martin Kautz on 15.06.12.
//  Copyright (c) 2012 JAKOTA Cruise Systems GmbH. All rights reserved.
//

#import "TBCredentialsInputViewController.h"

@interface TBCredentialsInputViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *okButton;

- (IBAction)buttonPressed:(id)sender;

@end

@implementation TBCredentialsInputViewController

@synthesize usernameTextField = _usernameTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize okButton = _okButton;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.usernameTextField.text = [userDefaults objectForKey:@"username"];
    self.passwordTextField.text = [userDefaults objectForKey:@"password"];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)buttonPressed:(id)sender {
        
    // 1. persist credentials
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.usernameTextField.text forKey:@"username"];
    [userDefaults setObject:self.passwordTextField.text forKey:@"password"];
    [userDefaults synchronize];
    
    // 2. fire notification, 
    // note: sufficent just to send empty notification 
    // to trigger observer to re-read credentials!
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.usernameTextField.text, @"username", 
                              self.passwordTextField.text, @"password", 
                              nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TBCredentialsDidChange" 
                                                        object:nil 
                                                      userInfo:userInfo];
    
    // 3. dismiss the vc
    [self.delegate didClose];
    
}

@end
