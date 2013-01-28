//
//  SearchBarView.m
//  Stolpersteine
//
//  Created by Claus on 24.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "SearchBar.h"

#import "SearchTextField.h"
#import "SearchBarDelegate.h"

@interface SearchBar() <UITextFieldDelegate>

@property (nonatomic, strong) SearchTextField *searchTextField;

@end

@implementation SearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.backgroundColor = UIColor.clearColor;
    
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.searchTextField = [[SearchTextField alloc] initWithFrame:frame];
    self.searchTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.searchTextField.delegate = self;
    self.searchTextField.rightViewMode = UITextFieldViewModeNever;
    [self addSubview:self.searchTextField];
    
    [self.searchTextField addTarget:self action:@selector(editingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [self.searchTextField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (void)setPortraitModeEnabled:(BOOL)portraitModeEnabled
{
    self.searchTextField.portraitModeEnabled = portraitModeEnabled;
}

- (BOOL)isPortraitModeEnabled
{
    return self.searchTextField.isPortraitModeEnabled;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.rightViewMode = UITextFieldViewModeNever;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.rightViewMode = text.length > 0 ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
    
    return TRUE;
}

- (void)editingDidBegin:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
        [self.delegate searchBarTextDidBeginEditing:self];
    }
}

- (void)editingChanged:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [self.delegate searchBar:self textDidChange:textField.text];
    }
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    return [self.searchTextField resignFirstResponder];
}

@end
