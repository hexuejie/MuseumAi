//
//  KGOPlaceHolderTextView.m
//  KingoPalm
//
//  Created by Kingo on 2018/5/16.
//  Copyright © 2018年 Kingo. All rights reserved.
//

#import "KGOPlaceHolderTextView.h"

@interface KGOPlaceHolderTextView()

@property (nonatomic , strong) UILabel *placeholderLabel;

@end

@implementation KGOPlaceHolderTextView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if(self) {
        
        self.backgroundColor = [UIColor clearColor];
        UILabel *placeholderLabel = [[UILabel alloc]init];//添加一个占位label
        placeholderLabel.backgroundColor = [UIColor clearColor];
        placeholderLabel.numberOfLines = 0; //设置可以输入多行文字时可以自动换行
        [self addSubview:placeholderLabel];
        self.placeholderLabel= placeholderLabel; //赋值保存
        self.placeHolderColor = [UIColor lightGrayColor]; //设置占位文字默认颜色
        self.font= [UIFont systemFontOfSize:15]; //设置默认的字体
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self]; //通知:监听文字的改变
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if(self) {
        
        self.backgroundColor = [UIColor clearColor];
        UILabel *placeholderLabel = [[UILabel alloc]init];//添加一个占位label
        placeholderLabel.backgroundColor = [UIColor clearColor];
        placeholderLabel.numberOfLines = 0; //设置可以输入多行文字时可以自动换行
        [self addSubview:placeholderLabel];
        self.placeholderLabel= placeholderLabel; //赋值保存
        self.placeHolderColor = [UIColor lightGrayColor]; //设置占位文字默认颜色
        self.font= [UIFont systemFontOfSize:15]; //设置默认的字体
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self]; //通知:监听文字的改变
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat placeHolderWidth = self.frame.size.width - 5.0*2;
    //根据文字计算高度
    CGSize maxSize =CGSizeMake(placeHolderWidth,MAXFLOAT);
    CGFloat placeHolderHeight = [self.placeHolder boundingRectWithSize:maxSize
                                                               options:NSStringDrawingUsesFontLeading |
                                 NSStringDrawingUsesLineFragmentOrigin
                                                            attributes:@{NSFontAttributeName : self.placeholderLabel.font} context:nil].size.height;
    self.placeholderLabel.frame = CGRectMake(5, 8, placeHolderWidth, placeHolderHeight);
    
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    
    _placeHolder= [placeHolder copy];
    //设置文字
    self.placeholderLabel.text= placeHolder;
    //重新计算子控件frame
    [self setNeedsLayout];
    
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor {
    
    _placeHolderColor = placeHolderColor;
    //设置颜色
    self.placeholderLabel.textColor= placeHolderColor;
}

//重写这个set方法保持font一致
- (void)setFont:(UIFont*)font {
    
    [super setFont:font];
    self.placeholderLabel.font= font;
    //重新计算子控件frame
    [self setNeedsLayout];
    
}

- (void)setText:(NSString*)text{
    
    [super setText:text];
    [self textDidChange];
}

- (void)setAttributedText:(NSAttributedString*)attributedText {
    
    [super setAttributedText:attributedText];
    [self textDidChange];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:UITextViewTextDidChangeNotification];
}


#pragma mark -监听文字改变

- (void)textDidChange {
    
    self.placeholderLabel.hidden = self.hasText;
        
}

@end
