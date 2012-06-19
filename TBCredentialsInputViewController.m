//
//  TBCredentialsInputViewController.m
//  AuthExample
//
//  Created by Martin Kautz on 15.06.12.
//  Copyright (c) 2012 JAKOTA Cruise Systems GmbH. All rights reserved.
//

#import "TBCredentialsInputViewController.h"


@interface TBCredentialsInputViewController ()

@property (strong, nonatomic) IBOutlet UITextField              *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField              *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton                 *okButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView  *spinner;
@property (strong, nonatomic) IBOutlet UILabel                  *statusLabel;
@property (strong, nonatomic) AuthTestEngine                    *authTestEngine;

- (IBAction)buttonPressed:(id)sender;

@end

@implementation TBCredentialsInputViewController

@synthesize usernameTextField   = _usernameTextField;
@synthesize passwordTextField   = _passwordTextField;
@synthesize okButton            = _okButton;
@synthesize spinner             = _spinner;
@synthesize statusLabel         = _statusLabel;
@synthesize delegate            = _delegate;
@synthesize authTestEngine      = _authTestEngine;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(processAuthResponse:) 
                                                 name:kGotAuthResponseNotification 
                                               object:nil];
    
    self.authTestEngine = [[AuthTestEngine alloc]initWithHostName:kApiServer];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    
    self.usernameTextField.text = [userDefaults objectForKey:@"username"];
    self.passwordTextField.text = [userDefaults objectForKey:@"password"];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);

}

- (IBAction)buttonPressed:(id)sender 
{
    
    [self.spinner startAnimating];
    [self.statusLabel setText:@"Checking credentials..."];
    // check credentials
    
    NSString *sUsername = self.usernameTextField.text;
    NSString *sPassword = self.passwordTextField.text;
    
    [self.authTestEngine getApiKeyForUsername:sUsername
                                  andPassword:sPassword];
    
}

- (void)processAuthResponse:(NSNotification *)aNotification 
{
    
    [self.spinner stopAnimating];
        
    BOOL isValid = ![aNotification.userInfo objectForKey:@"message"];
    
    if (isValid) {
        
        // 1. persist userDefaults
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.usernameTextField.text forKey:@"username"];
        [userDefaults setObject:self.passwordTextField.text forKey:@"password"];
        [userDefaults synchronize];
        
        // 2. extract apiKey from notification
        NSString *sApiKey = [aNotification.userInfo objectForKey:@"apiKey"];

        // 3. fire notification, 
        // note: sufficent just to send empty notification 
        // to trigger observer to re-read credentials!
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.usernameTextField.text, @"username", 
                                  self.passwordTextField.text, @"password",
                                  sApiKey, @"apiKey",
                                  nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TBCredentialsDidChangeNotification" 
                                                            object:nil 
                                                          userInfo:userInfo];
        
        // 4. dismiss the vc
        [self.delegate didClose];
    }
    else {
        
        // we do not persist credentials
        // we do not send a notification
        // we do not get this VC dismissed
        
        // we just tell the user what's going on...
        // TODO: add the ability to sign up or reset password...
        self.statusLabel.text = [aNotification.userInfo objectForKey:@"message"];
    }
    
    
    
}

@end
