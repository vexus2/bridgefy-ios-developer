//
//  Peer.m
//  FileShare
//
//  Created by Calvin on 6/9/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

#import "Peer.h"

@implementation Peer

- (id)initWithUUID:(NSString *)uuid {
    if (self = [super init]) {
        self.uuid = uuid;
        self.deviceType = DeviceTypeUndefined;
    }
    
    return self;
}

- (NSString *)formattedName {
    NSString *idFragment = [self.uuid substringToIndex:5];
    
    if (self.name)
        return [NSString stringWithFormat:@"%@ (%@)", self.name, idFragment];
    
    return idFragment;
}

- (void)createFiles:(NSArray *)files {
    self.files = [[NSMutableArray alloc] init];
    
    for (NSDictionary *fileDictionary in files) {
        FileInfo *fileInfo = [[FileInfo alloc] initWithDictionary:fileDictionary];
        
        [self.files addObject:fileInfo];
    }
}

- (FileInfo *)fileWithUUID:(NSString *)fileId {
    for (FileInfo *file in self.files) {
        if ([file.uuid isEqualToString:fileId]) {
            return file;
        }
    }
    
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ID: %@\nName: %@\nType: %lu\nFiles: %@", self.uuid, self.name, (unsigned long)self.deviceType, self.files];
}

@end
