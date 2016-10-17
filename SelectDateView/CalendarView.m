//
//  CalendarView.m
//  Coach
//
//  Created by apple on 16/7/15.
//  Copyright © 2016年 sskz. All rights reserved.
//

#define kCalendarMenuHeight 50

#import "CalendarView.h"

@implementation CalendarView
{
    NSMutableDictionary *_eventsByDate;
    
    NSDate *_todayDate;
    NSDate *_setDate;
    NSDate *_dateSelected;
    
    JTCalendarMenuView *_calendarMenuView;
    JTHorizontalCalendarView *_calendarContentView;
    
    JTCalendarManager *_calendarManager;
}

- (id)initWithFrame:(CGRect)frame withSetDate:(NSDate *)setDate
{
    if (self = [super initWithFrame:frame]) {
        _setDate = setDate;
        [self setCalendar];
    }
    return self;
}

- (void)setCalendar
{
    [self setMenuView];
    [self setContentView];
    
    _todayDate = [NSDate date];
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    
    [_calendarManager setMenuView:_calendarMenuView];
    [_calendarManager setContentView:_calendarContentView];
    
    _dateSelected = _setDate;
    [_calendarManager setDate:_setDate];
}

- (void)setMenuView
{
    _calendarMenuView = [[JTCalendarMenuView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kCalendarMenuHeight)];
    [self addSubview:_calendarMenuView];
    _calendarContentView.backgroundColor = [UIColor whiteColor];
}

- (void)setContentView
{
    WeakObj(_calendarMenuView)
    _calendarContentView = [[JTHorizontalCalendarView alloc] initWithFrame:CGRectMake(_calendarMenuView.frame.origin.x, _calendarMenuView.frame.origin.y+_calendarMenuView.frame.size.height, _calendarMenuView.frame.size.width, kScreenHeight*0.6)];
    [self addSubview:_calendarContentView];
    [_calendarContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_calendarMenuViewWeak.mas_bottom);
        make.left.right.bottom.offset(0);
    }];
    _calendarContentView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - CalendarManager delegate

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    // Today
  /*  if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        //        dayView.circleView.hidden = NO;
        //        dayView.circleView.backgroundColor = [UIColor blueColor];
        //        dayView.dotView.backgroundColor = [UIColor whiteColor];
        //        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else */if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    if([self haveEventForDay:dayView.date]){
        dayView.dotView.hidden = NO;
    }
    else{
        dayView.dotView.hidden = YES;
    }
}

- (void)calendar:(JTCalendarManager *)calendar prepareMenuItemView:(UIView *)menuItemView date:(NSDate *)date
{
    NSString *text = nil;
    
    if(date){
        NSCalendar *calendar1 = calendar.dateHelper.calendar;
        NSDateComponents *comps = [calendar1 components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
        NSInteger currentMonthIndex = comps.month;
        
        static NSDateFormatter *dateFormatter = nil;
        if(!dateFormatter){
            dateFormatter = [calendar.dateHelper createDateFormatter];
        }
        
        dateFormatter.timeZone = calendar.dateHelper.calendar.timeZone;
        dateFormatter.locale = calendar.dateHelper.calendar.locale;
        
        while(currentMonthIndex <= 0){
            currentMonthIndex += 12;
        }
        
        text = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
    }
    
    [(UILabel *)menuItemView setText:text];
    
    menuItemView.backgroundColor = [UIColor whiteColor];
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    _dateSelected = dayView.date;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:1.0f animations:^{
                            self.alpha = 0;
                        } completion:^(BOOL finished) {
                            [self removeFromSuperview];
                            if (_delegate && [_delegate respondsToSelector:@selector(CalendarView:didRemoveFromSuperView:)]) {
                                [_delegate CalendarView:self didRemoveFromSuperView:calendar];
                            }
//                            self.hidden = YES;
                        }];
                        
                    }];
    
    
    // Don't change page in week mode because block the selection of days in first and last weeks of the month
    if(_calendarManager.settings.weekModeEnabled){
        return;
    }
    
    // Load the previous or next page if touch a day from another month
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(CalendarView:didTouchDayView:)]) {
        [_delegate CalendarView:self didTouchDayView:dayView];
    }
    
}

#pragma mark - CalendarManager delegate - Page mangement

// Used to limit the date for the calendar, optional
//- (BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date
//{
//    return [_calendarManager.dateHelper date:date isEqualOrAfter:_minDate andEqualOrBefore:_maxDate];
//}

- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar
{
    //    NSLog(@"Next page loaded");
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar
{
    //    NSLog(@"Previous page loaded");
}

// Used only to have a key for _eventsByDate
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

- (BOOL)haveEventForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(_eventsByDate[key] && [_eventsByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
    
}

- (void)setSelectedDate:(NSDate *)newSelectedDate
{
    if (![_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:newSelectedDate]) {
        _dateSelected = newSelectedDate;
        [_calendarManager setDate:newSelectedDate];
    }
}


@end
