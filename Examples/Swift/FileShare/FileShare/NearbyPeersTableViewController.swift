//
//  NearbyPeersTableViewController.swift
//  FileShare
//
//  Created by Calvin on 6/16/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit
import Photos
import BFTransmitter
import MobileCoreServices

let kTransaction = "transaction"
let kContent = "content"
let kDeviceName = "device_name"
let kDeviceType = "device_type"
let kStatus = "status"
let kFilesUUIDs = "files_uuids"

private let files = "localfiles"

enum Transaction : Int {
    case handshake = 0
    case availableFiles
    case fileRequest
    case fileTransfer
    case status
}

class NearbyPeersTableViewController: UITableViewController, BFTransmitterDelegate, FilesTableViewControllerDelegate {
    
    var transmitter: BFTransmitter?
    var localFiles: [FileInfo] = []
    var connectedPeers: [Peer] = []
    weak var filesController: FilesTableViewController?
    // TODO: current crc
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadFiles()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil);
        
        // Transmitter initialization
        BFTransmitter.setLogLevel(.error)
        self.transmitter = BFTransmitter(apiKey: "456a3cc7-f351-4b48-8f8d-7274b5592fd6")
        self.transmitter?.delegate = self
        self.transmitter?.isBackgroundModeEnabled = true
        self.transmitter?.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadFiles() {
        let manager = FileManager.default
        
        if !manager.fileExists(atPath: DESTINATION_DIRECTORY.path) {
            
            do {
                try manager.createDirectory(at: DESTINATION_DIRECTORY, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("ERROR: Can't create directory to store files")
                return
            }
        }
        
        let filesURL = DESTINATION_DIRECTORY.appendingPathComponent(files)
        
        do {
            let filesData = try Data(contentsOf: filesURL)
            self.localFiles = NSKeyedUnarchiver.unarchiveObject(with: filesData) as! [FileInfo]
        } catch {
            self.localFiles = []
        }
        
    }
    
    func saveFiles() {
        let filesURL = DESTINATION_DIRECTORY.appendingPathComponent(files)
        let filesData = NSKeyedArchiver.archivedData(withRootObject: self.localFiles)
        
        do {
            try filesData.write(to: filesURL, options: [.atomic])
        } catch {
            print("ERROR: Can't save files array")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - BFTransmitterDelegate
    
    public func transmitter(_ transmitter: BFTransmitter, meshDidAddPacket packetID: String) {
        
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didReachDestinationForPacket packetID: String) {
        //Mesh packet reached destiny (no always invoked)
    }
    
    public func transmitter(_ transmitter: BFTransmitter, meshDidStartProcessForPacket packetID: String) {
        //A message entered in the mesh process (was added).
        // Just called when the option BFSendingOptionFullTransmission was used.
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didSendDirectPacket packetID: String) {
        //A direct message was sent
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didFailForPacket packetID: String, error: Error?) {
        //A direct message transmission failed.
    }
    
    public func transmitter(_ transmitter: BFTransmitter, meshDidDiscardPackets packetIDs: [String]) {
        //A mesh message was discared and won't still be transmitted.
        
    }
    
    public func transmitter(_ transmitter: BFTransmitter, meshDidRejectPacketBySize packetID: String) {
        print("The packet \(packetID) was rejected from mesh because it exceeded the limit size.");
    }
    
    public func transmitter(_ transmitter: BFTransmitter,
                            didReceive dictionary: [String : Any]?,
                            with data: Data?,
                            fromUser user: String,
                            packetID: String,
                            broadcast: Bool,
                            mesh: Bool) {
        
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didDetectConnectionWithUser user: String) {
        //A connection was detected (no necessarily secure)
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didDetectDisconnectionWithUser user: String) {
        // A disconnection was detected.
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didFailAtStartWithError error: Error)
    {
        print("An error occurred at start: \(error.localizedDescription)");
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didOccur event: BFEvent, description: String)
    {
        print("Event reported: \(description)");
    }
    
    public func transmitter(_ transmitter: BFTransmitter, shouldConnectSecurelyWithUser user: String) -> Bool {
        return false//if True, it will establish connection with encryption capacities.
        // Not necessary for this case.
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didDetectSecureConnectionWithUser user: String) {
        // A secure connection was detected,
    }
    
    func sendAvailableFiles(to user: String) {
        var availableFiles: [[String: Any]] = []
        
        for file in self.localFiles {
            availableFiles.append(file.fileDictionary())
        }
        
        let filesDictionary = [kContent: availableFiles]
        
        self .send(filesDictionary, nil, .availableFiles, user)
    }
    
    func send(_ dictionary: [String: Any]?, _ data: Data?, _ transaction: Transaction, _ user: String) {
        let message = [kTransaction: transaction as Any,
                       kContent: dictionary as Any]
        
        let options: BFSendingOption = [.broadcastReceiver, .meshTransmission]
        
        do {
            try self.transmitter?.send(message, with: data, toUser: user, options: options)
        } catch let err as NSError {
            print("Error: \(err)")
        }
        
    }
    
    // MARK: - FilesTableViewController delegates
    
    func createNewFile(cloudPath path: String) {
        let destinationPath = DESTINATION_DIRECTORY.appendingPathComponent((path as NSString).lastPathComponent).path
        let manager = FileManager.default
        
        if manager.fileExists(atPath: destinationPath) {
            print("File already exist")
            // Imported file is removed
            do {
                try manager.removeItem(atPath: path)
            } catch {
                print("Error deleting imported file")
            }
            
            return
        }
        
        do {
            try manager.moveItem(atPath: path, toPath: destinationPath)
            self.createFileInfo(destinationPath)
        } catch let err as NSError {
            print("Error: \(err)")
        }
    }
    
    func createNewFile(mediaInfo info: [String : Any]) {
        // Getting the name of the picked media file
        guard let asset = PHAsset.fetchAssets(withALAssetURLs: [info["UIImagePickerControllerReferenceURL"] as! URL], options: nil).firstObject else {
            print("Error: Can't get image")
            return
        }
        
        let assetResource = PHAssetResource.assetResources(for: asset).first
        let fileName = assetResource?.originalFilename
        let destinationPath = DESTINATION_DIRECTORY.appendingPathComponent(fileName!)
        
        if FileManager.default.fileExists(atPath: destinationPath.path) {
            print("File already exists")
            return;
        }
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        manager.requestImageData(for: asset, options: options) { (result, string, orientation, info) -> Void in
            if let imageData = result {
                self.save(imageData, destinationPath)
            } else {
                print("ERROR: Can't get image")
            }
        }
        
    }
    
    func save(_ data: Data, _ url: URL) {
        do {
            try data.write(to: url, options: [.atomic])
        } catch {
            print("ERROR: Can't save image")
            return
        }
        
        self.createFileInfo(url.path)
    }
    
    func createFileInfo(_ path: String) {
        guard let fileInfo = FileInfo(path: path) else {
            return
        }
        
        self.localFiles.append(fileInfo)
        self.notifyFilesListUpdate()
        self.saveFiles()
        
        self.filesController?.files = self.localFiles
        self.filesController?.updateAvailableFiles()
    }
    
    func notifyFilesListUpdate() {
        for peer in self.connectedPeers {
            self.sendAvailableFiles(to: peer.uuid)
        }
    }
    
    func requestFile(_ id: String, _ peer: Peer) {
        let requestDictionary = [kFilesUUIDs: [id]]
        
        self.send(requestDictionary, nil, .fileRequest, peer.uuid)
    }
    
    func deleteFile(fileInfo: FileInfo) -> Bool {
        guard let index = self.localFiles.index(of: fileInfo) else {
            print("File not found")
            return false
        }
        
        do {
            try FileManager.default.removeItem(atPath: fileInfo.path)
        } catch  {
            print("An error ocurred while deleting the file")
            return false
        }
        
        self.localFiles.remove(at: index)
        self.notifyFilesListUpdate()
        self.saveFiles()
        self.filesController?.files = self.localFiles
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationController = segue.destination as? FilesTableViewController
        
        if segue.identifier == "showLocalFiles" {
            destinationController!.files = self.localFiles
        } else if segue.identifier == "showRemoteFiles" {
            let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
            destinationController!.peer = self.connectedPeers[(indexPath?.row)!]
        }
        
        destinationController?.delegate = self
        self.filesController = destinationController
    }

}
