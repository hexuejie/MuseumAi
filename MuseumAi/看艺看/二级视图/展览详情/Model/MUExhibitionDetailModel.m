//
//  MUExhibitionDetailModel.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/27.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUExhibitionDetailModel.h"

@implementation MUExhibitionDetailModel

+ (instancetype)exhibitionWithDic:(NSDictionary *)dic {
    
    MUExhibitionDetailModel *exhibition = [MUExhibitionDetailModel new];
    
    exhibition.userCount = dic[@"userCount"];
    NSString *scoreStr = dic[@"score"];
    exhibition.score = [NSString stringWithFormat:@"%.2f",[scoreStr doubleValue]*2];
    exhibition.isScore = [dic[@"isScore"] boolValue];
    exhibition.isLove = [dic[@"loveState"] boolValue];
    
    NSDictionary *detailDic = [dic[@"list"]firstObject];
    NSString *urlStr = detailDic[@"buyUrl"];
    if (urlStr.length == 0) {
        exhibition.buyUrl = nil;
    } else {
        exhibition.buyUrl = [NSURL URLWithString:urlStr];
    }
    exhibition.imageUrl = detailDic[@"exhibitionPicUrl"];
    exhibition.exhibitionId = detailDic[@"id"];
    exhibition.sellState = [detailDic[@"sellTicketState"] integerValue];
    exhibition.exhibitionName = detailDic[@"exhibitionName"];
    exhibition.exhibitionTime = detailDic[@"exhibitionStartDate"];
    exhibition.exhibitionPosition = detailDic[@"sittingPosition"];
    exhibition.exhibitionIntroduce = [NSString stringWithFormat:@"　　%@",detailDic[@"exhibitionIntroduce"]];
    
    CGFloat lat = [detailDic[@"sittingPositionY"] doubleValue];
    CGFloat lng = [detailDic[@"sittingPositionX"] doubleValue];
    exhibition.locationCoordinate = CLLocationCoordinate2DMake(lat, lng);
    
    [exhibition loadLayoutData];
    
    return exhibition;
    
}

#define Line3Height 115.0f

- (void)loadLayoutData {
    
    CGFloat totalHeight = [self cellHeightWithMsg:self.exhibitionIntroduce];
    if (totalHeight < Line3Height) {
        _foldEnable = NO;
        _fold = NO;
        _introduceHeight = totalHeight+10.0f  +20;//+16;
    }else {
        _foldEnable = YES;
        _fold = NO;
        _introduceHeight = Line3Height+10.0f+20.0f +19;
    }
    
}

- (void)setFold:(BOOL)fold {
    if (!_foldEnable) {
        return;
    }
    _fold = fold;
    if (_fold) {
        _introduceHeight = [self cellHeightWithMsg:self.exhibitionIntroduce] +30.0f +19;
//        [MULayoutHandler caculateHeightWithContent:self.exhibitionIntroduce font:15.0f width:SCREEN_WIDTH-30.0f];
    }else {
        _introduceHeight = Line3Height+30.0f +18;
    }
}

- (CGFloat)cellHeightWithMsg:(NSString *)msg
{
    UILabel *label = [[UILabel alloc] init];
    label.text = msg;
    label.font = [UIFont systemFontOfSize:15];
    label.numberOfLines = 0;
    CGSize size = [label sizeThatFits:CGSizeMake(SCREEN_WIDTH-30, CGFLOAT_MAX)];
    return size.height +20;
}


@end
