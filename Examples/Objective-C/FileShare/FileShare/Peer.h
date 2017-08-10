//
//  Peer.h
//  FileShare
//
//  Created by Calvin on 6/9/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileInfo.h"

@interface Peer : NSObject

typedef NS_ENUM(NSUInteger, DeviceType) {
    DeviceTypeUndefined = 0,
    DeviceTypeAndroid,
    DeviceTypeIos
};

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *files;
@property (nonatomic) DeviceType deviceType;

- (id)initWithUUID:(NSString *)uuid;
- (NSString *)formattedName;
- (void)createFiles:(NSArray *)files;
- (FileInfo *)fileWithUUID:(NSString *)fileID;

@end
