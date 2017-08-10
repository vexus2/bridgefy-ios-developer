//
//  Notification.h
//  BroadcastAlert
//
//  Created by Daniel Heredia on 7/27/16.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

@property (nonatomic) NSInteger number;
@property (nonatomic, retain) NSString *senderId;
@property (nonatomic, retain) NSString *senderName;
@property (nonatomic, retain) NSDate* date;

@end
