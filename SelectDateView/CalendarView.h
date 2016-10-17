//
//  CalendarView.h
//  Coach
//
//  Created by apple on 16/7/15.
//  Copyright © 2016年 sskz. All rights reserved.
//

#import <JTCalendar.h>
#import <UIKit/UIKit.h>

@class CalendarView;

@protocol CalendarViewDelegate <NSObject,JTCalendarDelegate>

@optional

- (void)CalendarView:(UIView *)bgView didTouchDayView:(JTCalendarDayView *)dayView;

- (void)CalendarView:(UIView *)bgView didRemoveFromSuperView:(JTCalendarManager *)calendar;

@end

@interface CalendarView : UIView

@property (nonatomic,assign)id delegate;

- (id)initWithFrame:(CGRect)frame withSetDate:(NSDate *)setDate;

- (void)setSelectedDate:(NSDate *)newSelectedDate;  //设置新的选中日期

@end
