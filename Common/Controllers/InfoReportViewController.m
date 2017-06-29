//
//  InfoReportViewController.m
//  rfj
//
//  Created by Nuno Silva on 06/11/14.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//
#define kOFFSET_FOR_KEYBOARD 150.0
#import "InfoReportViewController.h"

#import "NSObject+Singleton.h"
#import "DataManager.h"
#import "MainViewController.h"
#import "Analytics.h"
#import "NSObject+Singleton.h"
#import "RadioManager.h"

@interface InfoReportViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UITextView *uploadedLabel;
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
    [[Analytics singleton] trackScreenName:@"Reporter une info"];
    
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
    
    NSCharacterSet *numericOnly = [NSCharacterSet decimalDigitCharacterSet];
    
    //  Validation
    if (self.descriptionTextField.text.length == 0 || [self.descriptionTextField.text isEqualToString:@"Description"]) {
        [self displayError:@"Vous devez remplir la description."];
        return;
    } else if (self.phoneTextField.text.length == 0) {
        [self displayError:@"Vous devez remplir le champ téléphone."];
        return;
    } else if (self.emailTextField.text.length == 0) {
        [self displayError:@"Vous devez remplir le champ email."];
        return;
    } else if (![self isValidEmail:self.emailTextField.text]) {
        [self displayError:@"Votre email n'est pas correct."];
        return;
    }
    
    NSData *data = UIImageJPEGRepresentation(self.image.image, 1.0);
    NSMutableData *imageMut=[data mutableCopy];
    
    [[DataManager singleton] sendInfoReportWithTitle:self.titleTextField.text email:self.emailTextField.text description:self.descriptionTextField.text phone:self.phoneTextField.text image:imageMut successBlock:^{
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



- (void)imagePickerController:(UIImagePickerController *)picker  didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
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
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return 150;
            break;
        case 1:
            return 180;
            break;
        case 3:
            return 50;
            break;
        case 4:
            return 50;
            break;
        case 5:
            return 50;
            break;
        case 6:
            return 50;
            break;
        case 2:
            return 50;
            break;
        case 7:
            return 50;
            break;
        case 8:
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"InputCellTitle" forIndexPath:indexPath];
        self.titleTextField = (UITextField *)[cell.contentView viewWithTag:100];
        self.titleTextField.placeholder = @"Titre";
        self.titleTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.titleTextField.returnKeyType = UIReturnKeyDone;
        self.titleTextField.delegate = self;
        
    } else if (indexPath.row == 5) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"descri" forIndexPath:indexPath];
        self.descriptionTextField = (UITextView *)[cell.contentView viewWithTag:100];
        //self.descriptionTextField.placeholder = @"Description";
        self.descriptionTextField.keyboardType = UIKeyboardTypeAlphabet;
        self.descriptionTextField.returnKeyType = UIReturnKeyDone;
        self.descriptionTextField.delegate = self;
        
    } else if (indexPath.row == 6) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"InputCell" forIndexPath:indexPath];
        self.emailTextField = (UITextField *)[cell.contentView viewWithTag:100];
        self.emailTextField.placeholder = @"Adresse e-mail";
        self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTextField.returnKeyType = UIReturnKeyDone;
        self.emailTextField.delegate = self;
        
    } else if (indexPath.row == 7) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"InputCell" forIndexPath:indexPath];
        self.phoneTextField = (UITextField *)[cell.contentView viewWithTag:100];
        self.phoneTextField.placeholder = @"Téléphone";
        self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        self.phoneTextField.returnKeyType = UIReturnKeyDone;
        self.phoneTextField.delegate = self;
        
    } else if (indexPath.row == 8) {
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
        }
        else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) //Check front Camera available or not
            imagePickController.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        
        imagePickController.delegate=self;
        imagePickController.allowsEditing=NO;
        
        [self presentModalViewController:imagePickController animated:YES];
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


- (void)keyboardDidShow:(NSNotification *)notification
{
    // Assign new frame to your view
    [self.view setFrame:CGRectMake(0,-110,320,460)]; //here taken -110 for example i.e. your view will be scrolled to -110. change its value according to your requirement.
    
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
    NSLog(@"KEYBORAD SHOW: %@", sender);
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


@end
