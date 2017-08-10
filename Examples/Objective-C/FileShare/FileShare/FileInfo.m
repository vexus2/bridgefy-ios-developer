//
//  FileInfo.m
//  FileShare
//
//  Created by Calvin on 6/8/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

#import "FileInfo.h"

#define kUrl @"url"
#define FRAGMENT_SIZE 2000000.0 // Declared as float to avoid integer division

@implementation FileInfo

- (id)initWithDictionary:(NSDictionary *)dictionary {
    
    if (self = [super init]) {
        self.uuid = dictionary[kUuid];
        self.type = dictionary[kContentType];
        self.name = dictionary[kName];
        self.size = [dictionary[kSize] integerValue];
        self.fragments = [dictionary[kFragments] intValue];
        
        // TODO: Determinar si el archivo ya se encuentra localmente
        self.local = NO;
    }
    
    return self;
}

- (id)initWithPath:(NSString *)path {
    
    if (self = [super init]) {
        self.uuid = [[NSUUID UUID] UUIDString];     // An unique id is created for the file
        self.name = path.lastPathComponent;
        self.local = YES;
        
        if (!self.calculateValues)
            return nil;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super init]) {
        self.uuid = [decoder decodeObjectForKey:kUuid];
        self.name = [decoder decodeObjectForKey:kName];
        self.local = YES;
        
        if (!self.calculateValues)
            return nil;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.uuid forKey:kUuid];
    [encoder encodeObject:self.name forKey:kName];
}

- (BOOL)calculateValues {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.path]) {
        self.type = self.path.pathExtension;
        self.size = [NSData dataWithContentsOfFile:self.path].length;
        self.fragments = [self calculateFileFragments];
        
        return YES;
    }
    
    return NO;
}

- (NSDictionary *)fileDictionary {
    return @{
             kUuid: self.uuid,
             kContentType: self.type,
             kName: self.name,
             kSize: @(self.size),
             kFragments: @(self.fragments)
             };
}

- (int)calculateFileFragments {
    return ceil(self.size / FRAGMENT_SIZE);
}

- (NSData *)dataForFragment:(int)fragment {
    
    // TODO: Obtener el fragmento solicitado
    
    return nil;
}

- (NSString *)formattedFileSize {
    return [NSByteCountFormatter stringFromByteCount:self.size
                                          countStyle:NSByteCountFormatterCountStyleBinary];
}

- (NSString *)path {
    if (!_path) {
        _path = [DESTINATION_DIRECTORY stringByAppendingPathComponent:self.name];
    }
    
    return _path;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"UUID: %@\nName: %@\nType: %@\nSize: %lu\nFragments: %i", self.uuid, self.name, self.type, (unsigned long)self.size, self.fragments];
}

@end
