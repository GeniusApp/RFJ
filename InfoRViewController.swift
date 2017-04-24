//
//  InfoRViewController.swift
//  rfj
//
//  Created by Gonçalo Girão on 18/04/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

import UIKit
let kOFFSET_FOR_KEYBOARD = 150.0

class InfoRViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var infoRTableView: UITableView!

    var textView: UITextView?
    var uploadedLabel: UITextView?
    var phoneTextField: UITextField?
    var emailTextField: UITextField?
    var titleTextField: UITextField?
    var descriptionTextField: UITextView?
    var image: UIImageView?
    var imageData: Data?
    var istextview: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        istextview = false
        image?.image = UIImage(named: "images/GalleryDefaultImage.png")
        // Do any additional setup after loading the view.
        infoRTableView.delegate = self
        infoRTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        infoRTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 140
        case 1:
            return 130
        case 3:
            return 50
        case 4:
            return 115
        case 5:
            return 50
        case 6:
            return 50
        case 2:
            return 50
        case 7:
            return 50
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        let label: UILabel? = nil
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "FirstCell", for: indexPath)
            textView = (cell?.contentView.viewWithTag(100) as? UITextView)
        }
        else if indexPath.row == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
            image = (cell?.contentView.viewWithTag(2) as? UIImageView)
        }
        else if indexPath.row == 3 {
            cell = tableView.dequeueReusableCell(withIdentifier: "InputCellTitle", for: indexPath)
            titleTextField = (cell?.contentView.viewWithTag(100) as? UITextField)
            titleTextField?.placeholder = "Title"
            //titleTextField?.keyboardType = UIKeyboardTypeAlphabet
            //titleTextField?.returnKeyType = UIReturnKeyDone
            titleTextField?.delegate = self as? UITextFieldDelegate
        }
        else if indexPath.row == 4 {
            cell = tableView.dequeueReusableCell(withIdentifier: "descri", for: indexPath)
            descriptionTextField = (cell?.contentView.viewWithTag(100) as? UITextView)
            //self.descriptionTextField.placeholder = @"Description";
            //descriptionTextField?.keyboardType = UIKeyboardTypeAlphabet
            //descriptionTextField?.returnKeyType = UIReturnKeyDone
            descriptionTextField?.delegate = self as? UITextViewDelegate
        }
        else if indexPath.row == 5 {
            cell = tableView.dequeueReusableCell(withIdentifier: "InputCell", for: indexPath)
            emailTextField = (cell?.contentView.viewWithTag(100) as? UITextField)
            emailTextField?.placeholder = "Adresse e-mail"
            emailTextField?.keyboardType = .emailAddress
           // emailTextField?.returnKeyType = UIReturnKeyDone
            emailTextField?.delegate = self as? UITextFieldDelegate
        }
        else if indexPath.row == 6 {
            cell = tableView.dequeueReusableCell(withIdentifier: "InputCell", for: indexPath)
            phoneTextField = (cell?.contentView.viewWithTag(100) as? UITextField)
            phoneTextField?.placeholder = "Téléphone"
            phoneTextField?.keyboardType = .numberPad
            //phoneTextField?.returnKeyType = UIReturnKeyDone
            phoneTextField?.delegate = self as? UITextFieldDelegate
        }
        else if indexPath.row == 7 {
            cell = tableView.dequeueReusableCell(withIdentifier: "envoyer", for: indexPath)
        }
        else if indexPath.row == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath)
            //uploadedLabel = (cell?.contentView.viewWithTag(200) as? UILabel)
            uploadedLabel = cell?.contentView.viewWithTag(200) as? UITextView
            textView?.text = ""
            phoneTextField?.delegate = self as? UITextFieldDelegate
        }
        
        if NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 {
            cell?.contentView.frame = (cell?.bounds)!
            cell?.contentView.autoresizingMask = [.flexibleLeftMargin, .flexibleWidth, .flexibleRightMargin, .flexibleTopMargin, .flexibleHeight, .flexibleBottomMargin]
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let imagePickController = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                //Check PhotoLibrary  available or not
                imagePickController.sourceType = .photoLibrary
                imagePickController.sourceType = .photoLibrary
            }
            else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                //Check front Camera available or not
                imagePickController.sourceType = .savedPhotosAlbum
            }
            
            imagePickController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePickController.allowsEditing = false
            present(imagePickController, animated: true, completion: nil)
        }
        titleTextField?.becomeFirstResponder()
    }
}
