//
//  FilesTableViewController.h
//  Shared Files
//
//  Created by Calvin on 6/7/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "Peer.h"

extern NSString *const localUser;

@protocol FilesTableViewControllerDelegate <NSObject>

- (void)createNewFileFromMediaInfo:(NSDictionary *)info;
- (void)createNewFileFromCloudPath:(NSString *)path;
- (void)requestFile:(NSString *)fileId fromPeer:(Peer *)peer;
- (BOOL)deleteFileInfo:(FileInfo *)fileInfo;

@end

@interface FilesTableViewController : UITableViewController

@property (nonatomic, retain) Peer *peer;
@property (nonatomic, retain) NSMutableArray *files;
@property (nonatomic, weak) id<FilesTableViewControllerDelegate> delegate;

- (void)updateAvailableFiles;

@end
