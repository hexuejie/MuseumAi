//
//  MUExhibitionCellDelegate.h
//  MuseumAi
//
//  Created by Kingo on 2018/9/27.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUExhibitionDetailModel.h"

@protocol MUExhibitionCellDelegate <NSObject>

@optional

- (void)didImageTappedInCell:(UITableViewCell *)cell;
- (void)didScoreTappedInCell:(UITableViewCell *)cell;

- (void)didOperationClickedInCell:(UITableViewCell *)cell;

- (void)didProduction:(NSInteger)productionIndex tappedInCell:(UITableViewCell *)cell;

- (void)didNaviClicked:(UITableViewCell *)cell;

@end
