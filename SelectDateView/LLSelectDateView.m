//
//  LLSelectDateView.m
//  Coach
//
//  Created by apple on 16/7/13.
//  Copyright © 2016年 sskz. All rights reserved.
//

#define kCalendarMenuHeight 50

#import "UIView+Animations.h"
#import "LLSelectDateView.h"

@implementation LLSelectDateView
{
    CGFloat showBtnWidth;
    NSArray *btnTitleArr;
    NSArray *titleAttrArr;
    NSArray *btnColorArr;
    
    NSMutableDictionary *_eventsByDate;
    
    NSDate *_todayDate;
    NSDate *_dateSelected;
    
    JTCalendarMenuView *_calendarMenuView;
    JTHorizontalCalendarView *_calendarContentView;
}

- (id)initWithFrame:(CGRect)frame showBtnWidth:(CGFloat)width sideBtnTitle:(NSArray *)titleArr
            btnTitleAttr:(NSArray *)titleAttr btnBgColor:(NSArray *)colorArr
{
    if (self = [super initWithFrame:frame]) {
        showBtnWidth = width;
        btnTitleArr = titleArr;
        titleAttrArr = titleAttr;
        btnColorArr = colorArr;
        [self setUI];
    }
    return self;
}

- (void)setUI
{
    [self setButton];
}

- (void)setButton
{
    for (int i = 0; i < 3; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i==0) {
                make.left.offset(0);
                make.width.offset((kScreenWidth-showBtnWidth)/2);
            }
            else if(i==2)
            {
                make.right.offset(0);
                make.width.offset((kScreenWidth-showBtnWidth)/2);
            }
            else
            {
                make.center.equalTo(self);
                make.width.offset(showBtnWidth);
            }
            make.top.offset(0);
            make.height.equalTo(self.mas_height);
        }];
        
        [btn setAttributedTitle:[[NSAttributedString alloc] initWithString:btnTitleArr[i] attributes:titleAttrArr[i]] forState:UIControlStateNormal];
        
        [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        [btn setBackgroundColor:btnColorArr[i]];
        
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        btn.tag = 10+i;
    }
}

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        [self addSubview:_lineView];
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.offset(0);
            make.height.offset(kLineWidth);
        }];
    }
    return _lineView;
}

- (void)setCalendarView
{
    UIButton *centerBtn = [self viewWithTag:11];
    _calendarView = [[CalendarView alloc] initWithFrame:CGRectMake(0, self.frame.size.height+self.frame.origin.y, kScreenWidth, 400) withSetDate:[self.dateFormatter dateFromString:centerBtn.titleLabel.text]];
    _calendarView.delegate = self;
    [self.superview addSubview:_calendarView];
    
    [self.calendarView ScaleFromSmallToBig];  //calendarView动画出现
}

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    return dateFormatter;
}

- (void)clickBtn:(UIButton *)btn
{
    if (btn.tag==11) {
        //center button
        if (!_calendarView) {
            [self setCalendarView];
        }
    }
    else
    {
        //left button
        UIButton *centerBtn = [self viewWithTag:11];
        NSDate *nowShow = [self.dateFormatter dateFromString:centerBtn.titleLabel.text];
        NSDate *newDate = [nowShow dateByAddingTimeInterval:btn.tag==10? -3600*24 : 3600*24];
   
        [centerBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:[self.dateFormatter stringFromDate:newDate] attributes:titleAttrArr[1]] forState:UIControlStateNormal];
        
        [_calendarView setSelectedDate:newDate];
    }
}

#pragma mark - CalendarViewDelegate 

- (void)CalendarView:(UIView *)bgView didTouchDayView:(JTCalendarDayView *)dayView
{
    UIButton *centerBtn = [self viewWithTag:11];
    [centerBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:[self.dateFormatter stringFromDate:dayView.date] attributes:titleAttrArr[1]] forState:UIControlStateNormal];
}

- (void)CalendarView:(UIView *)bgView didRemoveFromSuperView:(JTCalendarManager *)calendar
{
    _calendarView = nil;
}

@end
