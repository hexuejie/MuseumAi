//
//  MUMapCell.m
//  MuseumAi
//
//  Created by Kingo on 2018/9/27.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUMapCell.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKAnnotation.h>

@interface MUMapCell()

@property (weak, nonatomic) IBOutlet UIView *mapBgView;

@property (weak, nonatomic) IBOutlet UIButton *naviButton;

/** 地图 */
@property (strong, nonatomic) BMKMapView *mapView;

@end

@implementation MUMapCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.separatorInset = UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0);
    self.mapView = [[BMKMapView alloc]init];
    [self.mapBgView addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.mas_equalTo(0);
    }];
//    self.mapBgView.layer.cornerRadius = 5.0f;
//    self.mapBgView.layer.masksToBounds = YES;
    [self.mapBgView sendSubviewToBack:self.mapView];
    
    self.mapView.scrollEnabled = NO;
    self.mapView.gesturesEnabled = NO;
    
}

- (void)bindCellWithModel:(MUExhibitionDetailModel *)exhibition delegate:(id<MUExhibitionCellDelegate>)delegate {
    
    self.delegate = delegate;
    
    BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc]init];
    annotation.coordinate = exhibition.locationCoordinate;
//    annotation.title = exhibition.exhibitionPosition;
    [self.mapView addAnnotation:annotation];
    [self.mapView setCenterCoordinate:exhibition.locationCoordinate];
    
}

- (IBAction)didNaviClicked:(id)sender {
    
    if (self.delegate != nil &&
        [self.delegate respondsToSelector:@selector(didNaviClicked:)]) {
        [self.delegate didNaviClicked:self];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
