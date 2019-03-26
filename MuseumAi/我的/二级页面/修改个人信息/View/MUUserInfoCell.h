//
//  MUUserInfoCell.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/26.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MUUserInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *infoTitleLb;

@property (weak, nonatomic) IBOutlet UILabel *infoContentLb;


@property (weak, nonatomic) IBOutlet UIButton *manButton;
@property (weak, nonatomic) IBOutlet UIButton *womanButton;
@property (weak, nonatomic) IBOutlet UIView *sexChooseView;



@end
