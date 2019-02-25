//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    UITextFieldDelegate {
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    // Declare instance variables here
    var msgArray: [Message] = [Message]();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.dataSource = self;
        messageTableView.delegate = self;
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self;
        
        
        //TODO: Set the tapGesture here:
        let tapGestureOnTable = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped));
        messageTableView.addGestureRecognizer(tapGestureOnTable);

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell");
        
        configureTableView();
        
        retrieveMessages();
        
        messageTableView.separatorStyle = .none;
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("section: \(indexPath.section)");
        print("row: \(indexPath.row)");
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell;
        let msg = msgArray[indexPath.row];
        cell.messageBody.text = msg.body
        cell.senderUsername.text = msg.sender;
        cell.avatarImageView.image = UIImage(named: "egg");
        
        if (msg.sender == Auth.auth().currentUser?.email as String!) {
            cell.avatarImageView.backgroundColor = UIColor.flatMint();
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue();
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray();
        }
        
        return cell;
        
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgArray.count;
    }
    
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true);
    }
    
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension;
        messageTableView.estimatedRowHeight = 120.0;
    }
    
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.heightConstraint.constant = 308;
            self.view.layoutIfNeeded();
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.heightConstraint.constant = 50;
            self.view.layoutIfNeeded();
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase

    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        //TODO: Send the message to Firebase and save it in our database
        
        messageTextfield.endEditing(true);
        messageTextfield.isEnabled = false;
        
        sendButton.isEnabled = false;
        
        let msgDb = Database.database().reference().child("messages");
        
        let msgMap = ["sender": Auth.auth().currentUser?.email, "body": messageTextfield.text!]
        
        msgDb.childByAutoId().setValue(msgMap) {
            (error, reference) in
            if (error != nil) {
                print("Failed to send msg: \(error!)");
            } else {
                print("Successfully to send msg: \(reference)");
                
                self.messageTextfield.text = "";
            }
            
            self.messageTextfield.isEnabled = true;
            self.sendButton.isEnabled = true;
        };
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        let msgDb = Database.database().reference().child("messages");
        
        msgDb.observe(.childAdded) { (snapshot) in
            let value = snapshot.value  as! [String : String];
            let msg = Message();
            msg.body = value["body"]!;
            msg.sender = value["sender"]!;
        
            self.msgArray.append(msg);
            
            self.configureTableView();
            self.messageTableView.reloadData();
        }
    }
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        SVProgressHUD.show()
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut();
            
            SVProgressHUD.dismiss();
            
            navigationController?.popToRootViewController(animated: true);
        } catch {
            print("Error, there was a problem signing out.");
        }
        
    }
    


}
