//
//  MatchFindingViewController.m
//  Legend
//
//  Created by David Zhang on 2013-05-01.
//
//

#import "MatchFindingViewController.h"

@interface MatchFindingViewController ()

@end

@implementation MatchFindingViewController

@synthesize labelStatus = _labelStatus;
@synthesize startGameButton = _startGameButton;

- (IBAction)startGame:(id)sender {
    self.startGameButton.hidden = YES;
    sent = YES;
    [smartFox send:[PublicMessageRequest requestWithMessage:@"GO" params:nil targetRoom:nil]];
    if ( received ) [appDelegate switchToScene:[BattleLayer scene]];
    else [self.labelStatus setText:@"Waiting for Opponent to start!"];
}

- (void) findMatchFor:(int)time
{
    attemptCount++;
    NSLog(@">[MYLOG]    Starting MM Algorithm >>>>>%d<<<<<", attemptCount);
    self.labelStatus.text = [NSString stringWithFormat:@"Searching... %d",attemptCount];
    // Matchmaking algorithm,
    // First we setup the rules of finding:
    MatchExpression *exp = [MatchExpression expressionWithVarName:@"ELO" condition:[NumberMatch numberMatchGreaterThanOrEqualTo] value:[NSNumber numberWithInt:1]];
    exp = [exp and:@"ELO" condition:[NumberMatch numberMatchLessThanOrEqualTo] value:[NSNumber numberWithInt:3000]];
    //exp = [exp and:UserProperties_NAME condition:[StringMatch stringMatchNotEquals] value:"simulator"];

    [smartFox send:[FindUsersRequest requestWithExpr:exp target:smartFox.lastJoinedRoom limit:1]];
    /*
     int ELOdiff = abs([[PlayerSingleton sharedPlayerSingleton] ELO] - user.elo);
     int RETdiff = abs([[PlayerSingleton sharedPlayerSingleton] ELO] - ret.elo);
     CCLOG(@"The time diff %f and ELOdiff is %d",user.time,ELOdiff);
     if (ELOdiff > MAXELORANGE)
     {
     CCLOG(@"too big diff");
     continue;
     }
     
     float acceptThreshold = 1 - (1.0f / MAXELORANGE);
     float timeFactor = (pow(user.time / MAXWAITTIME, RANGEINCRATE) * acceptThreshold);
     float eloFactor = (1 - acceptThreshold) * (MAXELORANGE - ELOdiff);
     float preference = timeFactor + eloFactor;
     CCLOG(@"The preference is %f, from %f + %f",preference, timeFactor, eloFactor);
     
     if ( preference >= acceptThreshold )
     {
     CCLOG(@"Found it!");
     if ( ret == nil || RETdiff > ELOdiff )
     {
     CCLOG(@"However we're using ret because ret elo = %d", ret.elo);
     ret = user;
     }
     // now we check if user is online
     [[WarpClient getInstance] getLiveUserInfo:ret.original];
     [self.label setString:@"Trying to connect to player."];
     break;
     }
     else if ( ret == nil || RETdiff > ELOdiff)
     {
     CCLOG(@"replaced the stored %d with elo of %d", ret.elo, user.elo);
     ret = user;
     }
     
     index++;
     if ( index == event.joinedUsers.count ) index = 0;
     }
    */
}

- (void) onUserVariablesUpdate:(SFSEvent *)evt
{
    SFSUser *user = [evt.params objectForKey:@"user"];
    if ( !matchFound && ![user isItMe] )
    {
        self.labelStatus.text = @"Attempting something new!";
        NSLog(@">[MYLOG]    User count changed. find again!");
        [self findMatchFor:-1];
    }
}

- (void) onUserFindResult:(SFSEvent *)evt
{
    NSArray *userList = [evt.params objectForKey:@"users"];
    if ( [userList count] == 0 )
    {
        self.labelStatus.text = @"No current online users";
        NSLog(@">[MYLOG]    Did not find users");
    }
    else //if ( [userList count] > 1 )
    {
        SFSUser *user = [userList objectAtIndex:arc4random() % [userList count]];
        if ( userList.count == 1 && [user.name isEqual:smartFox.mySelf.name] )
        {
            NSLog(@"its me u dummy");
        }
        else 
        {
            self.labelStatus.text = @"Attempting to connect to user";
            NSLog(@">[MYLOG]    Found users! Inviting random user");
            // Make a SFSObject to send
            SFSObject *mySetup = [SFSObject newInstance];
            [mySetup putUtfString:@"SETUP" value:[[UserSingleton get] getPieces]];
            
            NSArray *users = [NSArray arrayWithObject:user];
            [smartFox send:[InviteUsersRequest requestWithInvitedUsers:users secondsForAnswer:15 params:mySetup]];
        }
    }
}

- (void) onInvitationReply:(SFSEvent *)evt
{
    // invitation replied
    if ( [[evt.params objectForKey:@"reply"] integerValue] == InvitationReply_ACCEPT )
    {
        // Lock state! no more accepting
        self.labelStatus.text = @"Found Opponent! Setting up match";
        NSLog(@">>>>>>>>>> I'm the inviter <<<<<<<<<<");
        matchFound = YES;
        [UserSingleton get].amIPlayerOne = YES;
        
        // Load opponents shit
        SFSObject *setup = [evt.params objectForKey:@"data"];
        NSString *oppSetup = [setup getUtfString:@"SETUP"];
        NSString *roomName = [setup getUtfString:@"ROOM"];
        NSLog(@">[MYLOG]        room name is %@ and their setup is %@",roomName,oppSetup);
        [[UserSingleton get] loadOppSetup:oppSetup];
        
        // Join room
        [smartFox send:[JoinRoomRequest requestWithId:[NSString stringWithString:roomName] pass:nil roomIdToLeave:nil asSpect:NO]];//@"dev game"]];
    }
    else
    {
        NSLog(@"faggot rejected, try again");
        [self findMatchFor:-1];
    }
}

- (void) onInvitation:(SFSEvent *)evt
{
    // Get invitation
    SFSInvitation *invite = [evt.params objectForKey:@"invitation"];

    if ( !matchFound )
    {
        // Lock state! no more searching
        self.labelStatus.text = @"Found Opponent! Setting up match";
        NSLog(@">>>>>>>>>> I'm the invitee <<<<<<<<<<");
        matchFound = YES;
        [UserSingleton get].amIPlayerOne = NO;
         
        // Create room
        NSString *gameName = @"dev_game";
        RoomSettings *settings = [RoomSettings settingsWithName:gameName];
        settings.password = nil;
        settings.groupId = @"games";
        settings.isGame = YES;
        settings.maxUsers = 2;
        settings.maxSpectators = 0;
        
        [[UserSingleton get] loadOppSetup:[invite.params getUtfString:@"SETUP"]];
        
        // Make a SFSObject to return
        SFSObject *myResponse = [SFSObject newInstance];
        [myResponse putUtfString:@"SETUP"
                           value:[[UserSingleton get] getPieces]];
        [myResponse putUtfString:@"ROOM"
                           value:gameName];
        
        [smartFox send:[CreateRoomRequest requestWithRoomSettings:settings autoJoin:YES roomToLeave:smartFox.lastJoinedRoom]];
        
        [smartFox send:[InvitationReplyRequest requestWithInvitation:invite invitationReply:InvitationReply_ACCEPT params:myResponse]];
    }
    else
    {
        [smartFox send:[InvitationReplyRequest requestWithInvitation:invite invitationReply:InvitationReply_REFUSE params:nil]];
    }
}

- (void) onRoomJoin:(SFSEvent *)evt
{
    SFSRoom *room = [evt.params objectForKey:@"room"];
    NSLog(@"The Room %@ was successfully joined!", room.name);
    self.labelStatus.text = @"Game Ready!";
    self.startGameButton.hidden = NO;
}

- (void) onPublicMessage:(SFSEvent *)evt
{
    SFSUser *sender = [evt.params objectForKey:@"sender"];
    if ([[evt.params objectForKey:@"message"] isEqual:@"GO"] &&
        ![sender.name isEqual:smartFox.mySelf.name])
    {
        received = YES;
        if ( sent ) [appDelegate switchToScene:[BattleLayer scene]];
        else self.labelStatus.text = @"Your opponent doesnt have all day! Hurry up!";
    }
}

- (void) onInvitationReplyError:(SFSEvent *)evt
{
    NSLog(@"This should not run");
    self.labelStatus.text = @"An error occurred";
}

- (void) onRoomJoinError:(SFSEvent *)evt
{
    self.labelStatus.text = [NSString stringWithFormat:@"ERROR: %@", [evt.params objectForKey:@"errorMessage"]];
}
/* Other stuff */

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    smartFox = appDelegate.smartFox;
    matchFound = NO;
    attemptCount = 0;
    sent = NO;
    received = NO;
    // Send our values
    [self findMatchFor:-1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)viewDidUnload {
    [self setLabelStatus:nil];
    [self setStartGameButton:nil];
    [super viewDidUnload];
}
@end
