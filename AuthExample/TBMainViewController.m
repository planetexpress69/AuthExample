//
//  TBMainViewController.m
//  AuthExample
//
//  Created by Martin Kautz on 15.06.12.
//  Copyright (c) 2012 JAKOTA Cruise Systems GmbH. All rights reserved.
//

#import "TBMainViewController.h"
#import "TBCredentialsInputViewController.h"


@interface TBMainViewController ()

@property (strong, nonatomic) IBOutlet UILabel *credentialsInfoLabel;

- (void)makeNetworkCall;
- (IBAction)openCredentialsInputViewController:(id)sender;

@end

@implementation TBMainViewController

@synthesize credentialsInfoLabel = _credentialsInfoLabel;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(credentialsDidChange:) 
                                                 name:kCredentialsDidChangeNotification
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.credentialsInfoLabel = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(makeNetworkCall) 
               withObject:nil
               afterDelay:0.1];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/**********************************************************************************************************/
#pragma mark - dummy to trigger an initial call
/**********************************************************************************************************/
- (void)makeNetworkCall {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:@"username"] || ![defaults objectForKey:@"password"]) {
        
        // no credentials given yet, so trigger the input
        TBCredentialsInputViewController *credentialsInputViewController = [[TBCredentialsInputViewController alloc]initWithNibName:@"TBCredentialsInputViewController" 
                                                                                                                             bundle:nil]; 
        credentialsInputViewController.delegate = self;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentModalViewController:credentialsInputViewController
                                animated:YES];
        
        
    } else {
        
        // we do have credentials, so show them
        self.credentialsInfoLabel.text = [NSString stringWithFormat:@"%@/%@", [defaults objectForKey:@"username"], [defaults objectForKey:@"password"]];

    }
    
}

/**********************************************************************************************************/
#pragma mark - user triggered actions 
/**********************************************************************************************************/
- (IBAction)openCredentialsInputViewController:(id)sender {
    TBCredentialsInputViewController *civc = [[TBCredentialsInputViewController alloc]
                                              initWithNibName:@"TBCredentialsInputViewController" 
                                              bundle:nil];
    civc.delegate = self;
    [self presentModalViewController:civc 
                            animated:YES];
}

/**********************************************************************************************************/
#pragma mark - notification handler
/**********************************************************************************************************/
- (void)credentialsDidChange:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    
    self.credentialsInfoLabel.text = [NSString stringWithFormat:@"%@/%@", 
                                      [userInfo objectForKey:@"username"], 
                                      [userInfo objectForKey:@"password"]];
}

/**********************************************************************************************************/
#pragma mark - TBCredentialsInputViewControllerDelegate methods
/**********************************************************************************************************/
- (void)didClose {
    [self dismissModalViewControllerAnimated:YES];
}

@end
