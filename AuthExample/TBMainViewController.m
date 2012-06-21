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
#import "YRDropdownView.h"


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
    
    // woooo! apiKey got changed... so tell it to the user.
    [YRDropdownView showDropdownInView:self.view 
                                 title:@"AutResult" 
                                detail:[NSString stringWithFormat:@"key: %@", [change objectForKey:@"new"]]
                                 image:nil
                       backgroundImage:nil 
                              animated:YES 
                             hideAfter:40.0];
}


/**********************************************************************************************************/
#pragma mark - Dummy to trigger an initial call. blueprint for networking calls.
/**********************************************************************************************************/
- (void)makeNetworkCall 
{
    
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
                                               
                                               // TODO: switch to other JSON parsing, this one relies on iOS 5.0 
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
                                                           
                                                           [YRDropdownView showDropdownInView:self.view
                                                                                        title:@"Error" 
                                                                                       detail:[oError objectForKey:@"message"]
                                                                                        image:nil 
                                                                                     animated:YES
                                                                                    hideAfter:3.0];
                                                       
                                                       } else {
                                                           
                                                           [YRDropdownView showDropdownInView:self.view
                                                                                        title:@"Error" 
                                                                                       detail:@"Wrong API call. Try again later." 
                                                                                        image:nil 
                                                                                     animated:YES
                                                                                    hideAfter:3.0];
                                                           
                                                       }
                                                   }
                                               } else {
                                                   
                                                   [YRDropdownView showDropdownInView:self.view
                                                                                title:@"Error" 
                                                                               detail:@"Garbled answer. Try again later." 
                                                                                image:nil 
                                                                             animated:YES
                                                                            hideAfter:3.0];
                                               }
                                           } onError:^(NSError *error) {
                                               
                                               [YRDropdownView showDropdownInView:self.view
                                                                            title:@"Error" 
                                                                           detail:[error localizedDescription] 
                                                                            image:nil 
                                                                  backgroundImage:nil 
                                                                         animated:YES 
                                                                        hideAfter:2.0];
                                               
                                           }];
        } else {
            DLog(@"already have an apiKey: %@", TheApp.apiKey);
        }
    }
}

/**********************************************************************************************************/
#pragma mark - User triggered actions. 
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
#pragma mark - TBCredentialsInputViewControllerDelegate methods.
/**********************************************************************************************************/
- (void)didClose {
    [self dismissModalViewControllerAnimated:YES];
}

@end
