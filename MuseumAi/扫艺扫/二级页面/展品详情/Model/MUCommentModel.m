//
//  MUCommentModel.m
//  MuseumAi
//
//  Created by 魏宙辉 on 2018/9/24.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUCommentModel.h"
#import "NotesPhotoContainerView.h"

@implementation MUCommentModel

+ (instancetype)commentWithDic:(NSDictionary *)dic {
    
    MUCommentModel *comment = [MUCommentModel new];
    
    comment.content = dic[@"content"];
    comment.commentId = dic[@"subsidiaryId"];
    comment.authorName = dic[@"authorNameA"];
    comment.authorId = dic[@"authorIdA"];
    comment.createDate = dic[@"createDate"];
    comment.count = [dic[@"count"] integerValue];
    comment.images = dic[@"pictureList"];
    
    return comment;
}

- (CGFloat)contentHeight {
    if (self.content.length == 0) {
        return 0;
    }
    CGFloat height = [MULayoutHandler caculateHeightWithContent:self.content font:14.0f width:SCREEN_WIDTH-30.0f];
    if (height < 21.0f) {
        height = 21.0f;
    }
    return height;
}

- (CGFloat)photoHeight {
    CGFloat photoHeight = 0;
    if (self.images.count > 0) {
        NotesPhotoContainerView *photoCV = [NotesPhotoContainerView new];
        photoCV.photoContainerWidth = SCREEN_WIDTH-30.0f;
        photoCV.picPathStringsArray = self.images;
        photoHeight = [photoCV photoContainerHeight];
    }else {
        photoHeight = 0;
    }
    return photoHeight;
}

- (CGFloat)commentTotalHeight {
    CGFloat height = 62.0f;
    CGFloat contentHeight = [self contentHeight];
    if (contentHeight != 0) {
        height += 5.0f;
        height += contentHeight;
    }
    CGFloat imageHeight = [self photoHeight];
    if (imageHeight != 0) {
        height += 5.0f;
        height += imageHeight;
    }
    
    return height;
}

@end
