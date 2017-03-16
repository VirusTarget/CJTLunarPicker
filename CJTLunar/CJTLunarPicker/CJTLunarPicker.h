//
//  CJTLunarPicker.h
//  CJTLunar
//
//  Created by chenjintian on 17/3/15.
//  Copyright © 2017年 CJT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJTLunarPicker : UIView

/** 农历年份 */
@property (nonatomic, assign, readonly) int solarYear;
/** 农历月份 */
@property (nonatomic, assign, readonly) int solarMonth;
/** 农历日期 */
@property (nonatomic, assign, readonly) int solarDay;
#pragma mark- method

/**
 初始化(需要自行设置 frame，调用 beginWithSolarYear:month:day:)
 */
- (instancetype)init;

/**
 初始化(需要自行调用 beginWithSolarYear:month:day:)

 @param frame 尺寸
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 初始化

 @param frame 尺寸
 @param date 现在的公历日期
 */
- (instancetype)initWithFrame:(CGRect)frame WithDate:(NSDate *)date;

/**
 设置开始时候的公历年月日

 @param year 公历的年份
 @param month 公历的月份
 @param day 公历的日期
 */
- (void)beginWithSolarYear:(int)year month:(int)month day:(int)day;

/**
 设置开始时候的公历日期

 @param date 日期
 */
- (void)beginWithDate:(NSDate *)date;
@end
