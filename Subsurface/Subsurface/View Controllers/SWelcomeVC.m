//
//  SWelcomeVC.m
//  Subsurface
//
//  Created by Andrey Zhdanov on 19/05/14.
//  Copyright (c) 2014 Subsurface. All rights reserved.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//

#import "SWelcomeVC.h"
#import "SDivesListTVC.h"

@interface SWelcomeVC ()

@property (weak, nonatomic) IBOutlet UITextField *existingIdTextField;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SWelcomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [userDefaults objectForKey:kUserIdKey];
    self.existingIdTextField.text = userID;
    self.logInButton.enabled = userID.length > 0;
    self.existingIdTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:userID.length  > 0 ? 11.0f : 16.0f];
    self.existingIdTextField.enablesReturnKeyAutomatically = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accountJustCreated:)
                                                 name:kCreatedAccountNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegates

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger enteredTextLength = textField.text.length - range.length + string.length;
    self.logInButton.enabled = enteredTextLength > 0;
    self.existingIdTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:enteredTextLength > 0 ? 11.0f : 16.0f];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self performSegueWithIdentifier:@"LoadDivesList" sender:nil];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.logInButton.enabled = NO;
    self.existingIdTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
    return YES;
}

#pragma mark - NSNotification methods

- (void)accountJustCreated:(NSNotification *)notification {
    self.existingIdTextField.text = notification.object;
    self.logInButton.enabled = YES;
}



#pragma mark - Preparing Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"LoadDivesList"]) {
        NSString *userID = self.existingIdTextField.text;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userID forKey:kUserIdKey];
        [userDefaults synchronize];
        
        SDivesListTVC *vc = [segue destinationViewController];
        vc.userID = userID;
    }
}

#pragma mark - IBActions

- (IBAction)LogInButtonAction:(id)sender {    
    [self.view endEditing:YES];
}

- (IBAction)SendIdButtonAction:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Where to send your ID?", "")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", "")
                                              otherButtonTitles:NSLocalizedString(@"Send", ""), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.placeholder = @"send@myemail.com";
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UITextField *alertTextField = [alertView textFieldAtIndex:0];
        
        [SWEB retrieveAccount:alertTextField.text];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    return [emailTest evaluateWithObject:textField.text];
}

#pragma mark - Status bar appear

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
