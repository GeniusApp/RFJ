//
//  InfoReportViewController.m
//  rfj
//
//  Created by Nuno Silva on 06/11/14.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//
#define kOFFSET_FOR_KEYBOARD 210.0
#import "InfoReportViewController.h"

#import "NSObject+Singleton.h"
#import "DataManager.h"
#import "MainViewController.h"
#import "Analytics.h"
#import "NSObject+Singleton.h"
#import "RadioManager.h"
#import "MBProgressHUD.h"
#import "Validation.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface InfoReportViewController () <UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong,nonatomic) NSArray *theData;
@property (strong,nonatomic) NSString *selectedTitle;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UITextView *uploadedLabel;
@property (nonatomic, strong) UITextField *prenomTextField;
@property (nonatomic, strong) UITextField *nomTextField;
@property (nonatomic, strong) UITextField *adresseTextField;
@property (nonatomic, strong) UITextField *NPATextField;
@property (nonatomic, strong) UITextField *localiteTextField;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UITextView *descriptionTextField;
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) NSData *imageData;
@property  BOOL Istextview;
@end

@implementation InfoReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenName = @"InfoReport";
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.dataSource = self;
    picker.delegate = self;
    self.titleTextField.inputView = picker;
    self.theData = @[@"Madame",@"Monsieur"];
    
    self.Istextview=0;
    self.image.image=[UIImage imageNamed:@"images/GalleryDefaultImage.png"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)homeButtonTapped:(UIButton *)sender {
    
    NSArray *array = [self.navigationController viewControllers];
    [self.navigationController popToViewController:[array objectAtIndex:0] animated:YES];
}

- (IBAction)playRadio:(id)sender {
    if([[RadioManager singleton] isPlaying]) {
        [[RadioManager singleton] stop];
    }
    else {
        [[RadioManager singleton] play];
    }
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissKeyboard
{
    [self.titleTextField resignFirstResponder];
    [self.descriptionTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
}
- (void)displayError:(NSString *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Formulaire incomplet"
                                                        message:error
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (BOOL)isValidEmail:(NSString *)checkString {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (IBAction)sendTapped:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Envoi en cours...";
    NSCharacterSet *numericOnly = [NSCharacterSet decimalDigitCharacterSet];
    
    //  Validation
    if (self.descriptionTextField.text.length == 0 || [self.descriptionTextField.text isEqualToString:@"Description"]) {
        [self displayError:@"Vous devez remplir la description."];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    } else if (self.phoneTextField.text.length == 0) {
        [self displayError:@"Vous devez remplir le champ téléphone."];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    } else if (self.emailTextField.text.length == 0) {
        [self displayError:@"Vous devez remplir le champ email."];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    } else if (![self isValidEmail:self.emailTextField.text]) {
        [self displayError:@"Votre email n'est pas correct."];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    
    NSData *data = UIImageJPEGRepresentation(self.image.image, 1.0);
    NSMutableData *imageMut=[data mutableCopy];

    [[DataManager singleton] sendInfoReportWithTitle:self.selectedTitle name:self.nomTextField.text firstName:self.prenomTextField.text address:self.adresseTextField.text zipCode:self.NPATextField.text city:self.localiteTextField.text email:self.emailTextField.text description:self.descriptionTextField.text phone:self.phoneTextField.text image:imageMut successBlock:^{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lecteur reporter"
                                                            message:@"Votre message a bien été envoyé"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
    } andFailureBlock:^(NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Erreur de connexion"
                                                            message:@"Merci de réessayer plus tard"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)UploadPhoto:(id)sender {
    NSLog(@"PHOTO: %@", sender);
    UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
    
    if ([UIImagePickerController  isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {//Check PhotoLibrary  available or not
        imagePickController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) //Check front Camera available or not
        imagePickController.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    
    imagePickController.delegate=self;
    imagePickController.allowsEditing=NO;
    
    [self presentModalViewController:imagePickController animated:YES];
}

- (IBAction)UploadVideo:(id)sender {
    NSLog(@"VIDEO: %@", sender);
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,      nil];
    
    [self presentModalViewController:imagePicker animated:YES];
}


- (void)imagePickerController:(UIImagePickerController *)picker  didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        NSString *moviePath = [videoUrl path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
        }
    }
    UIImage *originalImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    self.image.image=originalImage;
    //Do whatever with your image
    _imageData = UIImageJPEGRepresentation (
                                            originalImage,
                                            0.8
                                            );
    self.uploadedLabel.text=@"Photo téléchargée";
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 14;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return 250;
            break;
        case 1:
            return 180;
            break;
        case 2:
            return 50;
            break;
        case 3:
            return 50;
            break;
        case 4:
            return 100;
            break;
        case 5:
            return 50;
            break;
        case 6:
            return 50;
            break;
        case 7:
            return 50;
            break;
        case 8:
            return 50;
            break;
        case 9:
            return 50;
            break;
        case 10:
            return 50;
            break;
        case 11:
            return 50;
            break;
        case 12:
            return 50;
            break;
        case 13:
            return 50;
            break;
        case 14:
            return 50;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    UILabel *label = nil;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FirstCell" forIndexPath:indexPath];
        self.textView = (UITextView *)[cell.contentView viewWithTag:100];
        
    } else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        self.image = (UIImageView *)[cell.contentView viewWithTag:2];
        
    } else if (indexPath.row == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"PickerCellTitle" forIndexPath:indexPath];
        UIPickerView *cellPickerView = (UIPickerView *)[cell.contentView viewWithTag:200];
        self.titleTextField.inputView = cellPickerView;
        
        if(VALID(cellPickerView, UIPickerView)) {
            cellPickerView.delegate = self;
            cellPickerView.dataSource = self;
        }
        

//        self.titleTextField = (UITextField *)[cell.contentView viewWithTag:100];
//        self.titleTextField.placeholder = @"Titre";
//        self.titleTextField.keyboardType = UIKeyboardTypeAlphabet;
//        self.titleTextField.returnKeyType = UIReturnKeyDone;
//        self.titleTextField.delegate = self;
    } else if (indexPath.row == 5) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"PrenomCellTitle" forIndexPath:indexPath];
        self.prenomTextField = (UITextField *)[cell.contentView viewWithTag:100];
        self.prenomTextField.placeholder = @"Prénom";
        self.prenomTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.prenomTextField.returnKeyType = UIReturnKeyDone;
        self.prenomTextField.delegate = self;
        
    } else if (indexPath.row == 6) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NomCellTitle" forIndexPath:indexPath];
        self.nomTextField = (UITextField *)[cell.contentView viewWithTag:100];
        self.nomTextField.placeholder = @"Nom";
        self.nomTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.nomTextField.returnKeyType = UIReturnKeyDone;
        self.nomTextField.delegate = self;
        
    } else if (indexPath.row == 7) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCellTitle" forIndexPath:indexPath];
        self.adresseTextField = (UITextField *)[cell.contentView viewWithTag:100];
        self.adresseTextField.placeholder = @"Adresse";
        self.adresseTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.adresseTextField.returnKeyType = UIReturnKeyDone;
        self.adresseTextField.delegate = self;
        
    } else if (indexPath.row == 8) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NPACellTitle" forIndexPath:indexPath];
        self.NPATextField = (UITextField *)[cell.contentView viewWithTag:100];
        self.NPATextField.placeholder = @"NPA";
        self.NPATextField.keyboardType = UIKeyboardTypeAlphabet;
        self.NPATextField.returnKeyType = UIReturnKeyDone;
        self.NPATextField.delegate = self;
        
    } else if (indexPath.row == 9) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LocaliteCellTitle" forIndexPath:indexPath];
        self.localiteTextField = (UITextField *)[cell.contentView viewWithTag:100];
        self.localiteTextField.placeholder = @"Localité";
        self.localiteTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.localiteTextField.returnKeyType = UIReturnKeyDone;
        self.localiteTextField.delegate = self;
        
    } else if (indexPath.row == 10) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"InputCell" forIndexPath:indexPath];
        self.phoneTextField = (UITextField *)[cell.contentView viewWithTag:100];
        self.phoneTextField.placeholder = @"Téléphone";
        self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        self.phoneTextField.returnKeyType = UIReturnKeyDone;
        self.phoneTextField.delegate = self;
        
    } else if (indexPath.row == 11) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"InputCell" forIndexPath:indexPath];
        self.emailTextField = (UITextField *)[cell.contentView viewWithTag:100];
        self.emailTextField.placeholder = @"Couriel";
        self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTextField.returnKeyType = UIReturnKeyDone;
        self.emailTextField.delegate = self;
        
    } else if (indexPath.row == 12) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"descri" forIndexPath:indexPath];
        self.descriptionTextField = (UITextView *)[cell.contentView viewWithTag:100];
        //self.descriptionTextField.placeholder = @"Description";
        self.descriptionTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.descriptionTextField.returnKeyType = UIReturnKeyDone;
        self.descriptionTextField.delegate = self;
        
    } else if (indexPath.row == 13) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"envoyer" forIndexPath:indexPath];
        
    }
    else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell" forIndexPath:indexPath];
        self.uploadedLabel=(UILabel *)[cell.contentView viewWithTag:200];
        self.textView.text=@"";
        self.phoneTextField.delegate = self;
    }
    else if (indexPath.row == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"VideoCell" forIndexPath:indexPath];
        self.uploadedLabel=(UILabel *)[cell.contentView viewWithTag:200];
        self.textView.text=@"";
        self.phoneTextField.delegate = self;
    }
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row==1) {
        UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
        
        if ([UIImagePickerController  isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {//Check PhotoLibrary  available or not
            imagePickController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) //Check front Camera available or not
            imagePickController.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        
        imagePickController.delegate=self;
        imagePickController.allowsEditing=NO;
        
        [self presentModalViewController:imagePickController animated:YES];
    } else if (indexPath.row==2) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,      nil];
        
        [self presentModalViewController:imagePicker animated:YES];
    }
    
    [self.titleTextField becomeFirstResponder];
    
}

#pragma mark - UITextView delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    return YES;
}



- (void)textViewDidBeginEditing:(UITextView *)textView {

    if ([textView.text isEqualToString:@"Description"]) {
        textView.text = @"";
    }
    if  (self.view.frame.origin.y >= 0)
    {
        self.Istextview=YES;
        [self setViewMovedUp:YES];
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self setViewMovedUp:NO];
    _Istextview=0;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView becomeFirstResponder];
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)sender {
    CGSize kbSize = [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat height = UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]) ? kbSize.height : kbSize.width;
    height = height + 20;
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = [[self tableView] contentInset];
        edgeInsets.bottom = height;
        [[self tableView] setContentInset:edgeInsets];
        edgeInsets = [[self tableView] scrollIndicatorInsets];
        edgeInsets.bottom = height;
        [[self tableView] setScrollIndicatorInsets:edgeInsets];
    }];
}

- (void)keyboardWillHide:(NSNotification *)sender {
    if (_Istextview) {
        [self setViewMovedUp:NO];
        _Istextview=0;
    }
    
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = [[self tableView] contentInset];
        edgeInsets.bottom = 0;
        [[self tableView] setContentInset:edgeInsets];
        edgeInsets = [[self tableView] scrollIndicatorInsets];
        edgeInsets.bottom = 0;
        [[self tableView] setScrollIndicatorInsets:edgeInsets];
    }];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    //if (textField == self.emailTextField) {
    [textField resignFirstResponder];
    //}
    return YES;
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}
- (void)bringUpPickerViewWithRow:(NSIndexPath*)indexPath
{
    UITableViewCell *currentCellSelected = [self.tableView cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.pickerView.hidden = NO;
         self.pickerView.center = (CGPoint){currentCellSelected.frame.size.width/2, self.tableView.frame.origin.y + currentCellSelected.frame.size.height*4};
     }
                     completion:nil];
}

- (void)hidePickerView
{
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.pickerView.center = (CGPoint){160, 800};
     }
                     completion:^(BOOL finished)
     {
         self.pickerView.hidden = YES;
     }];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.theData.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.theData[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.titleTextField.text = self.theData[row];
    self.selectedTitle = [self.theData objectAtIndex:row];
    [self.titleTextField resignFirstResponder];
}
@end
