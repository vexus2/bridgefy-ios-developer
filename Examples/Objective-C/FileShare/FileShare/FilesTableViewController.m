//
//  FilesTableViewController.m
//  Shared Files
//
//  Created by Calvin on 6/7/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

#import "FilesTableViewController.h"

NSString *const localUser = @"local user";

@interface FilesTableViewController () <UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation FilesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.peer) {
        self.title = [self.peer formattedName];
        
    } else {
        self.title = @"Shared files";
        
        // When looking for local files an "add file" button is required
        UIBarButtonItem *addFileButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                       target:self
                                                                                       action:@selector(showAddLocalFileOptions)];
        self.navigationItem.rightBarButtonItem = addFileButton;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.peer) {
        if (self.peer.files.count == 0) {
            [self showEmptyMessage];
        } else {
            [self removeEmptyMessage];
        }
        return self.peer.files.count;
    } else {
        if (self.files.count == 0) {
            [self showEmptyMessage];
        } else {
            [self removeEmptyMessage];
        }
        return self.files.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell"
                                                            forIndexPath:indexPath];
    
    UILabel *fileNameLabel = [(UILabel *)cell.contentView viewWithTag:1000];
    UILabel *fileSizeLabel = [(UILabel *)cell.contentView viewWithTag:1001];
    UIButton *downloadButton = [(UIButton *)cell.contentView viewWithTag:1002];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:1003];
    
    FileInfo *fileInfo;
    
    if (self.peer) {
        fileInfo = [self.peer.files objectAtIndex:indexPath.row];
    } else {
        fileInfo = [self.files objectAtIndex:indexPath.row];
    }
    
    fileNameLabel.text = fileInfo.name;
    fileSizeLabel.text = [fileInfo formattedFileSize];
    
    downloadButton.hidden = fileInfo.local;
    [activityIndicator stopAnimating];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.peer == nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.delegate) {
            if ([self.delegate deleteFileInfo:(FileInfo *)[self.files objectAtIndex:indexPath.row]]) {
                [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
        }
    }
}

- (void)showEmptyMessage {
    UILabel *emptyMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    emptyMessageLabel.text = @"No shared files";
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

- (void)showAddLocalFileOptions {
    UIAlertController *optionsController = [UIAlertController alertControllerWithTitle:@"Add new file to share"
                                                                               message:@"Select the source"
                                                                        preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *iCloudAction = [UIAlertAction actionWithTitle:@"iCloud"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self addFileFromCloud];
                                                         }];
    
    UIAlertAction *imagesAction = [UIAlertAction actionWithTitle:@"Images"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self addFileFromImages];
                                                         }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    // To avoid
    [optionsController addAction:iCloudAction];
    [optionsController addAction:imagesAction];
    [optionsController addAction:cancelAction];
    
    [self presentViewController:optionsController
                       animated:YES
                     completion:nil];
}

- (void)addFileFromCloud {
    NSArray *documentTypes = @[@"public.content"];
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes
                                                                                                            inMode:UIDocumentPickerModeImport];
    documentPicker.modalPresentationStyle = UIModalPresentationPopover;
    documentPicker.delegate = self;
    
    [self presentViewController:documentPicker
                       animated:YES
                     completion:nil];
    
}

- (void)addFileFromImages {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
}

#pragma mark - Image picker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
    
    if (self.delegate) {
        [self.delegate createNewFileFromMediaInfo:info];
    }
}

#pragma mark - Document Picker delegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    if (self.delegate) {
        [self.delegate createNewFileFromCloudPath:url.path];
    }
}

- (void)updateAvailableFiles {
    [self.tableView reloadData];
}

- (IBAction)downloadButtonPressed:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *ip = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    UIButton *downloadButton = (UIButton *)sender;
    downloadButton.hidden = YES;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:ip];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:1003];
    [activityIndicator startAnimating];
    activityIndicator.hidden = NO;
    
    FileInfo *file = [self.peer.files objectAtIndex:ip.row];
    
    if (self.delegate) {
        [self.delegate requestFile:file.uuid fromPeer:self.peer];
    }
}

@end
