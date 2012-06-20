//
//  TBCredentialsInputViewController.m
//  AuthExample
//
//  Created by Martin Kautz on 15.06.12.
//  Copyright (c) 2012 JAKOTA Cruise Systems GmbH. All rights reserved.
//

#import "TBCredentialsInputViewController.h"
#import "AuthTestEngine.h"
#import "TBAppDelegate.h"


@interface TBCredentialsInputViewController ()

@property (strong, nonatomic) IBOutlet UITextField              *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField              *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton                 *okButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView  *spinner;
@property (strong, nonatomic) IBOutlet UILabel                  *statusLabel;

- (IBAction)buttonPressed:(id)sender;

@end

@implementation TBCredentialsInputViewController

@synthesize usernameTextField   = _usernameTextField;
@synthesize passwordTextField   = _passwordTextField;
@synthesize okButton            = _okButton;
@synthesize spinner             = _spinner;
@synthesize statusLabel         = _statusLabel;
@synthesize delegate            = _delegate;

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

- (IBAction)buttonPressed:(id)sender 
{
    
    [self.spinner startAnimating];
    [self.statusLabel setText:@"Checking credentials..."];
    // check credentials
    
    NSString *sUsername = self.usernameTextField.text;
    NSString *sPassword = self.passwordTextField.text;
    
    
    [TheApp.authTestEngine getApiKeyForUsername:sUsername
                                    andPassword:sPassword
                                   onCompletion:^(MKNetworkOperation *completedOperation) {
                                       [self.spinner stopAnimating];
                                       
                                       NSError *parseError;
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData
                                                                                            options:kNilOptions
                                                                                              error:&parseError];
                                       
                                       if (!parseError) {
                                           
                                           NSString *apiKey = [[json objectForKey:@"return"]objectForKey:@"key"];
                                           
                                           if (apiKey) {
                                               
                                               // 1. update key
                                               [TheApp updateApiKey:apiKey];
                                               
                                               // 2. persist userDefaults
                                               NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                               [userDefaults setObject:self.usernameTextField.text forKey:@"username"];
                                               [userDefaults setObject:self.passwordTextField.text forKey:@"password"];
                                               [userDefaults synchronize];
                                               
                                               // 3. get the viewcontroller dismissed
                                               [self.delegate didClose];
                                               
                                           } else {
                                               
                                               NSDictionary *oError = [[json objectForKey:@"return"]objectForKey:@"error"];
                                               if (oError) {
                                                   DLog(@"Error %@ - %@", [oError objectForKey:@"code"], [oError objectForKey:@"message"]);
                                                   self.statusLabel.text = [oError objectForKey:@"message"];
                                               }
                                               
                                           }
                                           
                                       }
                                       
                                   } onError:^(NSError *error) {
                                       [self.spinner stopAnimating];
                                       
                                       self.statusLabel.text = [error localizedDescription];
                                       
                                       [self.delegate didClose];
                                   }];
    
}

@end
