//
//  SendNotificationViewController.m
//  BroadcastAlert
//
//  Created by Daniel Heredia on 7/27/16.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

#import "SendNotificationViewController.h"
#import "ReceivedNotificationsViewController.h"
#import <BFTransmitter/BFTransmitter.h>
#import <QuartzCore/QuartzCore.h>

#ifndef SEND_NOTIF
#define SEND_NOTIF
#define kSentKey @"sent_n"
#define kReceivedKey @"recev_n"
#endif


@interface SendNotificationViewController ()<BFTransmitterDelegate>
{
    NSInteger sentNumber;
    NSInteger receivedNumber;
}
@property (nonatomic, retain) BFTransmitter * transmitter;
@property (nonatomic, weak) ReceivedNotificationsViewController * receivedNotifsController;


@end

@implementation SendNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Transmitter initialization
    self.transmitter = [[BFTransmitter alloc] initWithApiKey:@"68898033-3dce-4c80-843e-e10982b942ac"];
    self.transmitter.delegate = self;
    [self.transmitter start];
    
    //UI controls load
    sentNumber = [self getSentNotificationsNumber];
    receivedNumber = [self getReceivedNotificationsNumber];
    self.nameLabel.text = [NSString stringWithFormat:@"Device name: %@", [[UIDevice currentDevice] name]];
    self.uuidLabel.text = [NSString stringWithFormat:@"User ID: %@", [self truncatedUUID]];
    [self refreshCounters];
    self.sentStatusLabel.text = @"";
    
    self.sendButton.layer.cornerRadius = 14.0;
    self.sendButton.layer.borderWidth = 2.0;
    self.sendButton.layer.borderColor = [UIColor redColor].CGColor;
    self.controlsContainer.layer.cornerRadius = 14.0;
}

-(void)refreshCounters
{
    self.sentNotificationsLabel.text =
    [NSString stringWithFormat:@"Sent alerts: %ld", (long)sentNumber];
    self.receivedNotificationsLabel.text =
    [NSString stringWithFormat:@"Received alerts: %ld", (long)receivedNumber];
}

-(NSString *)truncatedUUID
{
    return [self.transmitter.currentUser substringToIndex:5];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"received"])
    {
        self.receivedNotifsController = segue.destinationViewController;
    }
}


#pragma mark - Actions

-(IBAction)sendNotification:(id)sender
{
    //Sending the message.
    NSError * error;
    BFSendingOption options = (BFSendingOptionBroadcastReceiver |
                               BFSendingOptionNotEncrypted |
                               BFSendingOptionMeshTransmission);
    NSDictionary * dictionary = @{@"number": @(sentNumber + 1),
                                  @"date_sent": @(floor([[NSDate date] timeIntervalSince1970] * 1000)),
                                  @"device_name": [[UIDevice currentDevice] name]
                                  };
    [self.transmitter sendDictionary:dictionary
                              toUser:nil
                             options:options
                               error:&error];
    if (error)
    {
        NSLog(@"Error %@", error.localizedDescription);
    }
}


#pragma mark - BFTransmitterDelegate

- (void)transmitter:(BFTransmitter *)transmitter meshDidAddPacket:(NSString *)packetID
{
    // Packet added to mesh
    // Just called when the option BFSendingOptionMeshTransmission was used
    sentNumber++;
    self.sentStatusLabel.text = [NSString stringWithFormat:
                                 @"Alert number %ld is being broadcasted!",
                                 (long)sentNumber];
    [self updateSentNotifications:sentNumber];
    [self refreshCounters];
}

- (void)transmitter:(BFTransmitter *)transmitter didReachDestinationForPacket:( NSString *)packetID
{
    //Mesh packet reached destiny (no always invoked)
}

- (void)transmitter:(BFTransmitter *)transmitter meshDidStartProcessForPacket:( NSString *)packetID;
{
    //A message entered in the mesh process (was added).
    // Just called when the option BFSendingOptionFullTransmission was used.
}

- (void)transmitter:(BFTransmitter *)transmitter didSendDirectPacket:(NSString *)packetID
{
    //A direct message was sent
}

- (void)transmitter:(BFTransmitter *)transmitter didFailForPacket:(NSString *)packetID error:(NSError * _Nullable)error
{
    //A direct message transmission failed.
}

- (void)transmitter:(BFTransmitter *)transmitter meshDidDiscardPackets:(NSArray<NSString *> *)packetIDs
{
    //A mesh message was discared and won't still be transmitted.
}

- (void)transmitter:(BFTransmitter *)transmitter meshDidRejectPacketBySize:(NSString *)packetID
{
    NSLog(@"The packet %@ was rejected from mesh because it exceeded the limit size.", packetID);
}

- (void)transmitter:(BFTransmitter *)transmitter
didReceiveDictionary:(NSDictionary<NSString *, id> * _Nullable) dictionary
           withData:(NSData * _Nullable)data
           fromUser:(NSString *)user
           packetID:(NSString *)packetID
          broadcast:(BOOL)broadcast
               mesh:(BOOL)mesh
{
    receivedNumber++;
    [self updateReceivedNotifications:receivedNumber];
    [self refreshCounters];
    // A dictionary was received by BFTransmitter.
    if (self.receivedNotifsController)
    {
        // If the the notifications screen is shown
        // update it.
        [self.receivedNotifsController addNotificationDictionary:dictionary
                                                        fromUUID:user];
    } else
    {
        //Otherwise, just update the data in file.
        [ReceivedNotificationsViewController addNotificationToFile:dictionary
                                                          fromUUID:user];
    }
    
}

- (void)transmitter:(BFTransmitter *)transmitter didDetectConnectionWithUser:(NSString *)user
{
    //A connection was detected (no necessarily secure)
}

- (void)transmitter:(BFTransmitter *)transmitter didDetectDisconnectionWithUser:(NSString *)user
{
    // A disconnection was detected.
}

- (void)transmitter:(BFTransmitter *)transmitter didFailAtStartWithError:(NSError *)error
{
    NSLog(@"An error occurred at start: %@", error.localizedDescription);
}

- (void)transmitter:(BFTransmitter *)transmitter didOccurEvent:(BFEvent)event description:(NSString *)description
{
    NSLog(@"Event reported: %@", description);
}

- (BOOL)transmitter:(BFTransmitter *)transmitter shouldConnectSecurelyWithUser:(NSString *)user
{
    return NO; //if YES, it will establish connection with encryption capacities.
    // Not necessary for this case.
}

- (void)transmitter:(BFTransmitter *)transmitter didDetectSecureConnectionWithUser:(NSString *)user
{
    // A secure connection was detected
}

#pragma mark - Persistence of indicators
-(void)updateSentNotifications:(NSInteger)numNotifications
{
    [[NSUserDefaults standardUserDefaults] setObject:@(numNotifications) forKey:kSentKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSInteger)getSentNotificationsNumber
{
    NSNumber * value = [[NSUserDefaults standardUserDefaults] valueForKey:kSentKey];
    if (value == nil)
        return 0;
    return [value integerValue];
}
-(void)updateReceivedNotifications:(NSInteger)numNotifications
{
    [[NSUserDefaults standardUserDefaults] setObject:@(numNotifications) forKey:kReceivedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSInteger)getReceivedNotificationsNumber
{
    NSNumber * value = [[NSUserDefaults standardUserDefaults] valueForKey:kReceivedKey];
    if (value == nil)
        return 0;
    return [value integerValue];
}
@end
