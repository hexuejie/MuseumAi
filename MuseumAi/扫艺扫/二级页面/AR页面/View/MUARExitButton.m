//
//  MUARExitButton.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2019/3/1.
//  Copyright © 2019年 Weizh. All rights reserved.
//

#import "MUARExitButton.h"

@interface MUARExitButton()

@property (weak, nonatomic) IBOutlet UILabel *exitLabel;

@end

@implementation MUARExitButton

+ (instancetype)buttonWithTarget:(id)target selector:(SEL)selector {
    MUARExitButton *button = [[[NSBundle mainBundle] loadNibNamed:@"MUARExitButton" owner:self options:nil] firstObject];
    button.backgroundColor = [UIColor clearColor];
    button.exitLabel.layer.masksToBounds = YES;
    button.exitLabel.layer.cornerRadius = 5.0f;
    [button addTapTarget:target action:selector];
    return button;
}

@end
