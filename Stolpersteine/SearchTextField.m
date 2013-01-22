//
//  SearchTextField.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 22.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "SearchTextField.h"

@implementation SearchTextField

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
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"magnifier.png"]];
    self.leftView = iconImageView;
    self.leftViewMode = UITextFieldViewModeAlways;

    UIImage *backgroundImage = [[UIImage imageNamed:@"search-text-field.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 13.5f, 15.0f, 13.5f)];
    self.background = backgroundImage;
    self.borderStyle = UITextBorderStyleNone;
    
    CGRect frame = self.frame;
    frame.size.height = 30;
    self.frame = frame;
}

@end
