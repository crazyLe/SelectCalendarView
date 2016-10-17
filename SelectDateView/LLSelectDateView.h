//
//  LLSelectDateView.h
//  Coach
//
//  Created by apple on 16/7/13.
//  Copyright © 2016年 sskz. All rights reserved.
//

#import "CalendarView.h"
#import <UIKit/UIKit.h>

@class LLSelectDateView;

@protocol LLSelectDateViewDelegate <NSObject,JTCalendarDelegate,CalendarViewDelegate>

- (void)selectDateView:(LLSelectDateView *)selectDateView clickBtn:(UIButton *)btn;

@end

@interface LLSelectDateView : UIView

@property (nonatomic,strong) UIView *lineView;

@property (nonatomic,strong)CalendarView *calendarView;

@property (nonatomic,strong)NSDateFormatter *dateFormatter;

- (id)initWithFrame:(CGRect)frame showBtnWidth:(CGFloat)width sideBtnTitle:(NSArray *)titleArr
       btnTitleAttr:(NSArray *)titleAttr btnBgColor:(NSArray *)colorArr;

@end
