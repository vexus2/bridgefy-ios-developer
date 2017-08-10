//
//  NearbyPeersTableViewController.m
//  Shared Files
//
//  Created by Calvin on 6/7/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

#import <BFTransmitter/BFTransmitter.h>
#import <Photos/Photos.h>
#import <zlib.h>

#import "NearbyPeersTableViewController.h"
#import "FilesTableViewController.h"

typedef NS_ENUM(NSUInteger, Transaction) {
    TransactionHandshake = 0,
    TransactionAvailableFiles,
    TransactionFileRequest,
    TransactionFileTransfer,
    TransactionStatus
};

#define kTransaction @"transaction"
#define kContent @"content"
#define kDeviceName @"device_name"
#define kDeviceType @"device_type"
#define kStatus @"status"
#define kFilesUUIDs @"files_uuids"

NSString *const files = @"localfiles";

@interface NearbyPeersTableViewController ()<BFTransmitterDelegate, FilesTableViewControllerDelegate>

@property (nonatomic, retain) BFTransmitter *transmitter;
@property (nonatomic, retain) NSMutableArray *localFiles;
@property (nonatomic, retain) NSMutableArray *connectedPeers;
@property (nonatomic, weak) FilesTableViewController *filesController;
@property (nonatomic) unsigned long currentCRC;

@end

@implementation NearbyPeersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadFiles];
    self.connectedPeers = [[NSMutableArray alloc] init];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    //Transmitter initialization
    [BFTransmitter setLogLevel:BFLogLevelError];
    self.transmitter = [[BFTransmitter alloc] initWithApiKey:@"YOUR API KEY"];
    self.transmitter.delegate = self;
    self.transmitter.backgroundModeEnabled = YES;
    [self.transmitter start];
    
    self.currentCRC = [self crc32:self.transmitter.currentUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFiles {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:DESTINATION_DIRECTORY]) {
        NSError *error;
        [manager createDirectoryAtPath:DESTINATION_DIRECTORY withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            NSLog(@"ERROR: Can't create directory to store files");
            return;
        }
    }
    
    NSString *filesPath = [DESTINATION_DIRECTORY stringByAppendingPathComponent:files];
    
    NSData *data = [NSData dataWithContentsOfFile:filesPath];
    
    if (data)
        self.localFiles = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    else
        self.localFiles = [[NSMutableArray alloc] init];
}

- (void)saveFiles {
    NSString *filesPath = [DESTINATION_DIRECTORY stringByAppendingPathComponent:files];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.localFiles];
    [data writeToFile:filesPath
           atomically:YES];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.connectedPeers.count == 0) {
        [self showEmptyMessage];
    } else {
        [self removeEmptyMessage];
    }
    
    return self.connectedPeers.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"peerCell" forIndexPath:indexPath];
    
    UIImageView *deviceTypeImageView = (UIImageView *)[cell.contentView viewWithTag:1000];
    UILabel *peerNameLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:1002];
    
    Peer *peer = [self.connectedPeers objectAtIndex:indexPath.row];
    
    switch (peer.deviceType) {
        case DeviceTypeUndefined:
            deviceTypeImageView.image = nil;
            [activityIndicator startAnimating];
            break;
            
        case DeviceTypeAndroid:
            deviceTypeImageView.image = [UIImage imageNamed:@"android"];
            [activityIndicator stopAnimating];
            break;
            
        case DeviceTypeIos:
            deviceTypeImageView.image = [UIImage imageNamed:@"ios"];
            [activityIndicator stopAnimating];
            break;
    }
    
    peerNameLabel.text = peer.formattedName;
    
    return cell;
}

- (void)showEmptyMessage {
    UILabel *emptyMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    emptyMessageLabel.text = @"No nearby peers";
    emptyMessageLabel.textColor = [UIColor blackColor];
    emptyMessageLabel.numberOfLines = 0;
    emptyMessageLabel.textAlignment = NSTextAlignmentCenter;
    emptyMessageLabel.font = [UIFont systemFontOfSize:17];
    [emptyMessageLabel sizeToFit];
    
    self.tableView.backgroundView = emptyMessageLabel;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)removeEmptyMessage {
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

#pragma mark - BFTransmitterDelegate

- (void)transmitter:(BFTransmitter *)transmitter meshDidAddPacket:(NSString *)packetID {
    //Packet added to mesh
}

- (void)transmitter:(BFTransmitter *)transmitter didReachDestinationForPacket:( NSString *)packetID {
    //Mesh packet reached destiny (no always invoked)
}

- (void)transmitter:(BFTransmitter *)transmitter meshDidStartProcessForPacket:( NSString *)packetID {
    //A message entered in the mesh process.
}
- (void)transmitter:(BFTransmitter *)transmitter didSendDirectPacket:(NSString *)packetID{
    //A direct message was sent
}

- (void)transmitter:(BFTransmitter *)transmitter didFailForPacket:(NSString *)packetID error:(NSError * _Nullable)error {
    //A direct message transmission failed.
}
- (void)transmitter:(BFTransmitter *)transmitter meshDidDiscardPackets:(NSArray<NSString *> *)packetIDs {
    //A mesh message was discared and won't still be transmitted.
}

- (void)transmitter:(BFTransmitter *)transmitter meshDidRejectPacketBySize:(NSString *)packetID {
    NSLog(@"The packet %@ was rejected from mesh because it exceeded the limit size.", packetID);
}

- (void)transmitter:(BFTransmitter *)transmitter
didReceiveDictionary:(NSDictionary<NSString *, id> * _Nullable) dictionary
           withData:(NSData * _Nullable)data
           fromUser:(NSString *)user
           packetID:(NSString *)packetID
          broadcast:(BOOL)broadcast
               mesh:(BOOL)mesh {
    // A dictionary was received by BFTransmitter.
    
    Peer *peer = [self peerForUser:user];
    
    if (!peer) {
        return;
    }
    
    Transaction transaction = (Transaction)[[dictionary valueForKey:kTransaction] intValue];
    NSDictionary *content = dictionary[kContent];
    
    switch (transaction) {
        case TransactionHandshake:
            [self processHandshakePacket:content
                                fromPeer:peer];
            break;
        case TransactionAvailableFiles:
            [self processAvailableFilesPacket:content
                                     fromPeer:peer];
            break;
        case TransactionFileRequest:
            [self processFileRequestPacket:content
                                  fromPeer:peer];
            break;
        case TransactionFileTransfer:
            [self processFileTransferPacket:content
                                   withData:data
                                   fromPeer:peer];
            break;
        case TransactionStatus:
            
            break;
    }
}

- (void)transmitter:(BFTransmitter *)transmitter didDetectConnectionWithUser:(NSString *)user {
    //A connection was detected (no necessarily secure)
}

- (void)transmitter:(BFTransmitter *)transmitter didDetectDisconnectionWithUser:(NSString *)user {
    // A disconnection was detected.
    Peer *peer = [self peerForUser:user];
    
    if (!peer) {
        return;
    }
    
    if ([self.filesController.peer isEqual:peer]) {
        [self.navigationController popViewControllerAnimated:YES];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Connection lost"
                                                                       message:peer.formattedName
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
        
        [alert addAction:action];
        
        [self presentViewController:alert
                           animated:YES
                         completion:nil];
    }
    
    if (peer) {
        [self.connectedPeers removeObject:peer];
        [self.tableView reloadData];
    }
    
}

- (void)transmitter:(BFTransmitter *)transmitter didFailAtStartWithError:(NSError *)error {
    NSLog(@"An error occurred at start: %@", error.localizedDescription);
}

- (void)transmitter:(BFTransmitter *)transmitter didOccurEvent:(BFEvent)event description:(NSString *)description {
    NSLog(@"Event reported: %@", description);
}

- (BOOL)transmitter:(BFTransmitter *)transmitter shouldConnectSecurelyWithUser:(NSString *)user {
    return YES; //if YES establish connection with encryption capacities.
}

- (void)transmitter:(BFTransmitter *)transmitter didDetectSecureConnectionWithUser:(nonnull NSString *)user {
    // A secure connection was detected,
    // A secure connection has encryption capabilities.
    
    // Creating the new peer
    Peer *peer = [[Peer alloc] initWithUUID:user];
    [self.connectedPeers addObject:peer];
    [self.tableView reloadData];
    
    // Handshake process validation
    if ([self shouldStartHandshakeWithUser:user]) {
        [self sendHandshakeMessageToUser:user];
    }
}

- (BOOL)shouldStartHandshakeWithUser:(NSString *)user {
    return [self currentCRC] < [self crc32:user];
}

- (unsigned long)crc32:(NSString *)string {
    
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    uLong crc = crc32(0L, Z_NULL, 0);
    return crc32(crc, [data bytes], (unsigned int)[data length]);
}

- (void)processHandshakePacket:(NSDictionary *)dict fromPeer:(Peer *)peer {
    
    // Sending back the handshake message or sending the available files list
    if (![self shouldStartHandshakeWithUser:peer.uuid]){
        [self sendHandshakeMessageToUser:peer.uuid];
    } else {
        [self sendAvailableFilesToUser:(NSString *)peer.uuid];
    }
    
    peer.name = dict[kDeviceName];
    peer.deviceType = (DeviceType)[[dict valueForKey:kDeviceType] intValue];
    
    [self.tableView reloadData];
}

- (void)processAvailableFilesPacket:(NSDictionary *)dict fromPeer:(Peer *)peer {
    // Check to send back the available files list
    if (!peer.files) {
        [self sendAvailableFilesToUser:peer.uuid];
    }
    
    [peer createFiles:dict[kContent]];
    
    if ([self.filesController.peer.uuid isEqualToString:peer.uuid])
        [self.filesController updateAvailableFiles];
}

- (void)processFileRequestPacket:(NSDictionary *)dict fromPeer:(Peer *)peer {
    
    NSString *requestedFileId = [(NSArray *)[dict objectForKey:kFilesUUIDs] firstObject];
    
    FileInfo *requestedFileInfo = [self fileWithUUID:requestedFileId];
    
    if (!requestedFileInfo) {
        return;
    }
    
    NSData *fileData = [NSData dataWithContentsOfFile:requestedFileInfo.path];
    
    NSDictionary *dictionary = @{
                                 kUuid: requestedFileInfo.uuid,
                                 kPart: @(1),
                                 kFragments: @(requestedFileInfo.fragments)
                                 };
    
    [self sendDictionary:dictionary
                 andData:fileData
         withTransaction:TransactionFileTransfer
                  toUser:peer.uuid];
}

- (void)processFileTransferPacket:(NSDictionary *)dict withData:(NSData *)data fromPeer:(Peer *)peer {
    
    FileInfo *originalFileInfo = [peer fileWithUUID:dict[kUuid]];
    
    if (!originalFileInfo) {
        return;
    }
    
    if ([data writeToFile:originalFileInfo.path atomically:YES]) {
        originalFileInfo.local = YES;
        
        FileInfo *newFile = [[FileInfo alloc] initWithDictionary:originalFileInfo.fileDictionary];
        newFile.local = YES;
        [self.localFiles addObject:newFile];
        
        if ([self.filesController.peer isEqual:peer]) {
            [self.filesController updateAvailableFiles];
        }
        
        [self notifyFilesListUpdate];
        [self saveFiles];
    }
    
}

- (Peer *)peerForUser:(NSString *)user {
    for (Peer *p in self.connectedPeers) {
        if ([p.uuid isEqualToString:user])
            return p;
    }
    
    return nil;
}

- (FileInfo *)fileWithUUID:(NSString *)fileId {
    for (FileInfo *file in self.localFiles) {
        if ([file.uuid isEqualToString:fileId]) {
            return file;
        }
    }
    
    return nil;
}

- (void)sendHandshakeMessageToUser:(NSString *)user {
    
    NSDictionary *handshakeDictionary = @{
                                          kDeviceName: [[UIDevice currentDevice] name],
                                          kDeviceType: @(DeviceTypeIos),
                                          kStatus: @(0)
                                          };
    
    [self sendDictionary:handshakeDictionary
                 andData:nil
         withTransaction:TransactionHandshake
                  toUser:user];
}

- (void)sendAvailableFilesToUser:(NSString *)user {
    
    NSMutableArray *availableFiles = [[NSMutableArray alloc] init];
    
    for (FileInfo *info in self.localFiles) {
        [availableFiles addObject:[info fileDictionary]];
    }
    
    NSDictionary *filesDictionary = @{
                                      kContent: availableFiles
                                      };
    
    [self sendDictionary:filesDictionary
                 andData:nil
         withTransaction:TransactionAvailableFiles
                  toUser:user];
}

- (void)sendDictionary:(NSDictionary *)dict andData:(NSData *)data withTransaction:(Transaction)transaction toUser:(NSString *)user {
    NSDictionary *messageDictionary = @{
                                        kTransaction: @(transaction),
                                        kContent: dict
                                        };
    
    BFSendingOption options = BFSendingOptionDirectTransmission | BFSendingOptionEncrypted;
    
    [self.transmitter sendDictionary:messageDictionary
                            withData:data
                              toUser:user
                             options:options
                               error:nil];
}

#pragma mark - FilesTableViewController delegates

- (void)createNewFileFromCloudPath:(NSString *)path {
    
    NSString *destinationPath = [DESTINATION_DIRECTORY stringByAppendingPathComponent:path.lastPathComponent];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:destinationPath]) {
        NSLog(@"File already exists");
        // Imported file is removed
        [manager removeItemAtPath:path error:nil];
        return;
    }
    
    NSError *error;
    [manager moveItemAtPath:path
                     toPath:destinationPath
                      error:&error];
    
    if (!error) {
        [self createFileInfoFromPath:destinationPath];
    } else {
        NSLog(@"Error moving imported file");
    }
    
}

- (void)createNewFileFromMediaInfo:(NSDictionary *)info {
    // Getting the name of the picked media file
    PHAsset *asset = [[PHAsset fetchAssetsWithALAssetURLs:@[info[UIImagePickerControllerReferenceURL]]
                                                  options:nil] firstObject];
    PHAssetResource *assetResource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
    NSString *fileName = assetResource.originalFilename;
    NSString *destinationPath = [DESTINATION_DIRECTORY stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        NSLog(@"File already exists");
        return;
    }
    
    // Getting media file data
    NSURL *assetURL = info[UIImagePickerControllerReferenceURL];
    NSString *extension = [assetURL pathExtension];
    CFStringRef imageUTI = (UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(__bridge CFStringRef)extension , NULL));
    
    NSData *imageData;
    
    if (UTTypeConformsTo(imageUTI, kUTTypeJPEG))
    {
        imageData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], 1);
    }
    else if (UTTypeConformsTo(imageUTI, kUTTypePNG))
    {
        imageData = UIImagePNGRepresentation(info[UIImagePickerControllerOriginalImage]);
    }
    else
    {
        NSLog(@"Unhandled Image UTI: %@", imageUTI);
    }
    
    CFRelease(imageUTI);
    
    if ([imageData writeToFile:destinationPath atomically:YES]) {
        [self createFileInfoFromPath:destinationPath];
    } else {
        NSLog(@"Error saving selected image");
    }
}

- (void)createFileInfoFromPath:(NSString *)path {
    // FileInfo is created and added to localFiles
    FileInfo *fileInfo = [[FileInfo alloc] initWithPath:path];
    
    if (fileInfo) {
        [self.localFiles addObject:fileInfo];
        [self notifyFilesListUpdate];
        [self saveFiles];
        
        if (self.filesController) {
            [self.filesController updateAvailableFiles];
        }
    }
}

- (void)notifyFilesListUpdate {
    for (Peer *peer in self.connectedPeers) {
        [self sendAvailableFilesToUser:peer.uuid];
    }
}

- (void)requestFile:(NSString *)fileId fromPeer:(Peer *)peer {
    NSDictionary *requestDictionary = @{
                                        kFilesUUIDs: @[fileId]
                                        };
    
    [self sendDictionary:requestDictionary
                 andData:nil
         withTransaction:TransactionFileRequest
                  toUser:peer.uuid];
}

- (BOOL)deleteFileInfo:(FileInfo *)fileInfo {
    
    if ([self.localFiles containsObject:fileInfo]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:fileInfo.path error:&error];
        
        if (!error) {
            [self.localFiles removeObject:fileInfo];
            [self notifyFilesListUpdate];
            [self saveFiles];
            return YES;
        } else {
            NSLog(@"An error ocurred while deleting the file");
            return NO;
        }
    }
    
    NSLog(@"File not found");
    return NO;
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    FilesTableViewController *filesController = (FilesTableViewController *)segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"showLocalFiles"]) {
        filesController.files = self.localFiles;
    } else if ([segue.identifier isEqualToString:@"showRemoteFiles"]) {
        NSIndexPath *ip = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        filesController.peer = [self.connectedPeers objectAtIndex:ip.row];
    }
    
    filesController.delegate = self;
    self.filesController = filesController;
}

@end
