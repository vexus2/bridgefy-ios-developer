//
//  FileInfo.h
//  FileShare
//
//  Created by Calvin on 6/8/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef FilesInfo
#define FilesInfo
#define DESTINATION_DIRECTORY [[NSSearchPathForDirectoriesInDomains\
(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]\
stringByAppendingPathComponent:@"savedFiles"]
#endif

#define kUuid @"uuid"
#define kContentType @"content_type"
#define kName @"name"
#define kSize @"size"
#define kPart @"part"
#define kFragments @"fragments"

@interface FileInfo : NSObject

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *type;
@property (nonatomic) NSUInteger size;
@property (nonatomic) int fragments;
@property (nonatomic) BOOL local;
@property (nonatomic) BOOL downloading;
@property (nonatomic, retain) NSString *path;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (id)initWithPath:(NSString *)path;

- (NSDictionary *)fileDictionary;
- (NSData *)dataForFragment:(int)fragment;
- (NSString *)formattedFileSize;

@end

