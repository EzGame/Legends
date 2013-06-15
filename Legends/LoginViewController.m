//
//  LoginViewController.m
//  Legend
//
//  Created by David Zhang on 2013-04-17.
//
//

#import "LoginViewController.h"
#import "MainMenuViewController.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UIView *loginView;
@end

@implementation LoginViewController

@synthesize username = _username,
            password = _password,
            confirm = _confirm;

@synthesize login = _login,
            accnt = _accnt,
            create = _create;

@synthesize labelStatus = _labelStatus;

- (IBAction)newTouched:(id)sender
{
    self.login.hidden = YES;
    self.accnt.hidden = YES;
    self.create.hidden = NO;
    self.confirm.hidden = NO;
    //self.create.titleLabel.text = @"Create";
}

- (IBAction)loginTouched:(id)sender
{
    [self.loginView endEditing:YES];
    [self.labelStatus setText:@"Logging in"];
    [appDelegate login:self.username.text pass:self.password.text];
}

- (IBAction)createTouched:(id)sender
{
    [self.loginView endEditing:YES];
    if ( 0 )//isPassOK )
    {
        [self.labelStatus setText:@"Creating new account"];
        [smartFox send:[LoginRequest requestWithUserName:self.username.text password:@"" zoneName:nil params:nil]];
    }
    else
    {
        [appDelegate showAlert:
         [NSDictionary dictionaryWithObjectsAndKeys:
          @"!", @"title",
          @"Passwords do not match", @"msg",
          @"Ok", @"cancel", nil]];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Resign first responder
    [textField resignFirstResponder];
    
    if ([textField isEqual:self.username]) {
        [self.password becomeFirstResponder];
        
    } else if ([textField isEqual:self.password] && !self.confirm.isHidden) {
        [self.confirm becomeFirstResponder];
        
    } else if ([textField isEqual:self.confirm]) {
        if ([self.password.text isEqualToString:self.confirm.text])
            isPassOK = YES;
        
    }
    return YES;
}

- (void)onRoomJoin:(SFSEvent *)evt
{
    [appDelegate switchToView:@"MainMenuViewController" uiViewController:[MainMenuViewController alloc]];
}

- (void)onRoomJoinError:(SFSEvent *)evt
{
    [self.labelStatus setText:@"Error joining the lobby"];
}

/* Other stuff */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES
                                             animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    smartFox = appDelegate.smartFox;
    
    [self.username setDelegate:self];
    [self.password setDelegate:self];
    [self.confirm setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)viewDidUnload
{
    [self setUsername:nil];
    [self setPassword:nil];
    [self setConfirm:nil];
    [self setLogin:nil];
    [self setAccnt:nil];
    [self setCreate:nil];
    [self setLoginView:nil];
    [self setLabelStatus:nil];
    [super viewDidUnload];
}
@end
