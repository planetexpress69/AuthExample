//
//  TBMainViewController.m
//  AuthExample
//
//  Created by Martin Kautz on 15.06.12.
//  Copyright (c) 2012 JAKOTA Cruise Systems GmbH. All rights reserved.
//

#import "TBMainViewController.h"
#import "TBCredentialsInputViewController.h"
#import "TBAppDelegate.h"
#import "AuthTestEngine.h"


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
    
    // register self as observer of the apiKey
    [TheApp addObserver:self forKeyPath:@"apiKey" options:NSKeyValueObservingOptionNew context:nil];
    
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
#pragma mark - KVO payload
/**********************************************************************************************************/
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context
{
    DLog(@"Boing!!! %@", change);
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
        
        // do we have an apiKey yet? ask the app delegate...
        // since we do only store the credentials but not the apiKey we need to get a new one
        if (!TheApp.apiKey) {
            
            [TheApp.authTestEngine getApiKeyForUsername:[defaults objectForKey:@"username"]
                                            andPassword:[defaults objectForKey:@"password"]
                                           onCompletion:^(MKNetworkOperation *completedOperation) {
                                               
                                               NSError *parseError;
                                               NSDictionary *json = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData
                                                                                                    options:kNilOptions
                                                                                                      error:&parseError];
                                               if (!parseError) {
                                                   NSString *apiKey = [[json objectForKey:@"return"]objectForKey:@"key"];
                                                   if (apiKey) {
                                                       [TheApp updateApiKey:apiKey];
                                                   } else {
                                                       NSDictionary *oError = [[json objectForKey:@"return"]objectForKey:@"error"];
                                                       if (oError) {
                                                           DLog(@"Error %@ - %@", [oError objectForKey:@"code"], [oError objectForKey:@"message"]);
                                                           self.credentialsInfoLabel.text = [oError objectForKey:@"message"];
                                                       }
                                                   }
                                               } else {
                                                   //TODO: get visual here...
                                                   DLog(@"error: %@", parseError);
                                               }
                                           } onError:^(NSError *error) {
                                               //TODO: get visual here...
                                               DLog(@"error: %@", error);
                                           }];
        } else {
            DLog(@"already have an apiKey: %@", TheApp.apiKey);
        }
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
#pragma mark - TBCredentialsInputViewControllerDelegate methods
/**********************************************************************************************************/
- (void)didClose {
    [self dismissModalViewControllerAnimated:YES];
}

@end
