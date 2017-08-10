//
//  FilesTableViewController.swift
//  FileShare
//
//  Created by Calvin on 6/16/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol FilesTableViewControllerDelegate: class {
    func createNewFile(mediaInfo info: [String: Any])
    func createNewFile(cloudPath path: String)
    func requestFile(_ id: String, _ peer: Peer)
    func deleteFile(fileInfo: FileInfo) -> Bool
    
}

class FilesTableViewController: UITableViewController, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var peer: Peer?
    var files: [FileInfo] = []
    weak var delegate: FilesTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard self.peer != nil else {
            self.title = "Shared files"
            let addFileButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(FilesTableViewController.showAddLocalFileOptions))
            self.navigationItem.setRightBarButton(addFileButton, animated: false)
            return
        }
        
        self.title = self.peer!.formattedName()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.peer != nil else {
            if self.files.count == 0 {
                self.showEmptyMessage()
            } else {
                self.removeEmptyMessage()
            }
            
            return self.files.count
        }
        
        if self.peer!.files.count == 0 {
            self.showEmptyMessage()
        } else {
            self.removeEmptyMessage()
        }
        
        return self.peer!.files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath)

        let fileNameLabel = cell.contentView.viewWithTag(1000) as! UILabel
        let fileSizeLabel = cell.contentView.viewWithTag(1001) as! UILabel
        let downloadButton = cell.contentView.viewWithTag(1002) as! UIButton
        let activityIndicator = cell.contentView.viewWithTag(1003) as! UIActivityIndicatorView

        let fileInfo: FileInfo
        
        if self.peer != nil {
            fileInfo = self.peer!.files[indexPath.row]
        } else {
            fileInfo = self.files[indexPath.row]
        }
        
        fileNameLabel.text = fileInfo.name
        fileSizeLabel.text = fileInfo.formattedFileSize()
        
        downloadButton.isHidden = fileInfo.local
        activityIndicator.stopAnimating()
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.peer == nil
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if self.delegate != nil {
                if (self.delegate?.deleteFile(fileInfo: self.files[indexPath.row]))! {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
    func showEmptyMessage() {
        let emptyMessageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        emptyMessageLabel.text = "No shared files"
        emptyMessageLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        emptyMessageLabel.numberOfLines = 0
        emptyMessageLabel.textAlignment = .center
        emptyMessageLabel.font = UIFont.systemFont(ofSize: 17)
        emptyMessageLabel.sizeToFit()
        
        self.tableView.backgroundView = emptyMessageLabel
        self.tableView.separatorStyle = .none
    }
    
    func removeEmptyMessage() {
        self.tableView.backgroundView = nil
        self.tableView.separatorStyle = .singleLine
    }
    
    func showAddLocalFileOptions() {
        let optionsController = UIAlertController(title: "Add new file to share", message: "Select the source", preferredStyle: .actionSheet);
        
        let iCloudAction = UIAlertAction(title: "iCloud", style: .default) { (action) in
            self.addFileFromCloud()
        }
        
        let imagesAction = UIAlertAction(title: "Images", style: .default) { (action) in
            self.addFileFromImages()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // To avoid
        optionsController.addAction(iCloudAction)
        optionsController.addAction(imagesAction)
        optionsController.addAction(cancelAction)
        
        self.present(optionsController, animated: true)
        
    }
    
    func addFileFromCloud() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.content"], in: .import)
        documentPicker.modalPresentationStyle = .popover
        documentPicker.delegate = self;
        
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func addFileFromImages() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    // MARK: - Document Picker Delegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.delegate?.createNewFile(cloudPath: url.path)
    }
    
    // MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        self.delegate?.createNewFile(mediaInfo: info)
    }
    
    func updateAvailableFiles() {
        self.tableView.reloadData()
    }
    
    @IBAction func dowloadButtonPressed(_ sender: Any) {
        let buttonPosition = (sender as! UIButton).convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        let downloadButton = sender as! UIButton
        downloadButton.isHidden = true
        
        let cell = self.tableView.cellForRow(at: indexPath!)
        let activityIndicator = cell?.contentView.viewWithTag(1003) as! UIActivityIndicatorView
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        let fileInfo = self.peer?.files[(indexPath?.row)!]
        
        self.delegate?.requestFile((fileInfo?.uuid)!, self.peer!)
    }
    

}
