//
//  CJTLunarPicker.m
//  CJTLunar
//
//  Created by chenjintian on 17/3/15.
//  Copyright © 2017年 CJT. All rights reserved.
//

#import "CJTLunarPicker.h"
#import "solarOrLunar.h"
@interface CJTLunarPicker ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView *lunarPickerView;

@property (nonatomic, strong, readonly) NSDictionary *lunaDict;//农历字典

@property (nonatomic, strong) NSArray *yearArr;//年份数组
@property (nonatomic, strong) NSArray *monthArr;//月份数组
@property (nonatomic, strong) NSArray *dayArr;//日期数组

@property (nonatomic, strong) NSString *choiceString;//选择的年份
@property (nonatomic, assign) NSInteger choiceMonth;//选择的月份
@property (nonatomic, assign) NSInteger leapMonth;//闰月的月数

@property (nonatomic, assign) bool choiceLeap;//选择的是否是闰月
@property (nonatomic, assign) bool bigMonth;//该月是大月还是小月

@property (nonatomic, assign) hjz solarResult;//C 结构体
@end
@implementation CJTLunarPicker

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.lunarPickerView];
        _choiceString = @"";
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.lunarPickerView];
        self.lunarPickerView.frame = frame;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame WithDate:(NSDate *)date {
    if (self = [self initWithFrame:frame]) {
        [self beginWithDate:date];
    }
    return self;
}

#pragma mark- <UIPickerViewDelegate>
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0)
        return self.yearArr.count;
    else if (component == 1)
        return self.monthArr.count;
    else
        return _bigMonth ? 30 : 29;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(component == 0)
        return self.yearArr[row];
    else if (component == 1)
        return self.monthArr[row];
    else
        return self.dayArr[row];
}

#pragma mark- <UIPickerViewDataSource>
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        [self lunarPickerView:pickerView yearChoice:row];
    }
    if (component == 1) {
        [self lunarPickerView:pickerView monthChoice:row];
    }
    if (component == 2) {
        [self lunarPickerView:pickerView dayChoice:row];
    }
}

#pragma mark- private method
//取 shift 前 length 位值为 1 的值
int GetBitInt(int data, int length, int shift) {
    /**
     1.前4位,即0在这一年是润年时才有意义,它代表这年润月的大小月,为1则润大月,为0则润小月。
     2.中间12位,即4bd,每位代表一个月,为1则为大月,为0则为小月
     3.最后4位,即8,代表这一年的润月月份,为0则不润,首4位要与末4位搭配使用
     */
    int value = (1 << length) - 1;
    int shiftValue = value << shift;
    int andValue = data & shiftValue;
    int resultValue = andValue >> shift;
    return resultValue;
}

#pragma mark 公历时间转农历
//公历的年份、月份与日期
- (void)beginWithSolarYear:(int)year month:(int)month day:(int)day {
    hjz lunar = solar_to_lunar(year, month, day);
    
    [self.lunarPickerView selectRow:lunar.year-1901 inComponent:0 animated:NO];
    [self lunarPickerView:self.lunarPickerView yearChoice:lunar.year-1901];
    
    [self.lunarPickerView selectRow:lunar.month-1 inComponent:1 animated:NO];
    [self lunarPickerView:self.lunarPickerView monthChoice:lunar.month-1];
    
    [self.lunarPickerView selectRow:lunar.day-1 inComponent:2 animated:NO];
    [self lunarPickerView:self.lunarPickerView dayChoice:lunar.day-1];
}

- (void)beginWithDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    int year = (int)[calendar component:NSCalendarUnitYear fromDate:date];
    int month = (int)[calendar component:NSCalendarUnitMonth fromDate:date];
    int day = (int)[calendar component:NSCalendarUnitDay fromDate:date];
    
    [self beginWithSolarYear:year month:month day:day];
}

#pragma mark 选择器选择事件
//农历选择年份
- (void)lunarPickerView:(UIPickerView *)pickerView yearChoice:(NSInteger)year {
    //保存获取的年份
    _choiceString = self.yearArr[year];
    //获取该年份的元数据
    NSString *resultString = self.lunaDict[_choiceString];
    int mac1 =  (int)strtoul([resultString UTF8String], 0, 16);
    //通过末 4 位（从右往左 1-4 位）判断闰月的月份（如果没有，则为0）
    _leapMonth = GetBitInt(mac1, 4, 0);
    
    [pickerView reloadComponent:1];
    [self lunarPickerView:pickerView monthChoice:[pickerView selectedRowInComponent:1]];
    
}

//农历选择月份
- (void)lunarPickerView:(UIPickerView *)pickerView monthChoice:(NSInteger)month {
    //获取当前月份，由于 row 从 0 开始，所以 ＋1
    _choiceMonth = month + 1;
    //获取该年份的元数据
    NSString *resultString = self.lunaDict[_choiceString];
    int mac1 =  (int)strtoul([resultString UTF8String], 0, 16);
    
    //如果当前月是闰月，则通过前 4 位（从右往左 17-20 位）的值判断该闰月是大月还是小月（大月 1，小月 0）
    if (_leapMonth == month && _leapMonth > 0) {
        _bigMonth = GetBitInt(mac1, 4, (int)(16));
        //记录选中的是闰月
        _choiceLeap = 1;
    }
    //如果不是闰月，则通过 4-16 位（从右往左 16-4 位）的值判断 1 月判断第 16 位的 0、1 值，2 月第 15 位，以此类推
    else {
        _bigMonth = GetBitInt(mac1, 1, (int)(15 - month));
        //记录选中的不是闰月
        _choiceLeap = 0;
    }
    
    //如果当前月大于闰月，月份 －1
    if (_leapMonth > 0 && _choiceMonth > _leapMonth) {
        _choiceMonth -= 1;
    }
    
    //刷新日期 Component
    [pickerView reloadComponent:2];
    [pickerView selectRow:[pickerView selectedRowInComponent:2] inComponent:2 animated:false];
}

//农历选择日期
- (void)lunarPickerView:(UIPickerView *)pickerView dayChoice:(NSInteger)day {
    
    /**
     农历转公历
     
     传参 年份、月份、日期、是否闰月
     返回 年月日的结构体
     */
    _solarResult = lunar_to_solar((int)(1901 + [self.yearArr indexOfObject:_choiceString]), (int)_choiceMonth, (int)(day + 1), (int)_choiceLeap);
    //输出公历的年月日
    NSLog(@"%d %d %d",self.solarResult.year,self.solarResult.month,self.solarResult.day);
    //输出农历的年月日
    NSLog(@"%@ %ld %ld %d",_choiceString,_choiceMonth,day+1,_choiceLeap);
}

#pragma mark- getter/setter
- (UIPickerView *)lunarPickerView {
    if (!_lunarPickerView) {
        _lunarPickerView = [[UIPickerView alloc] init];
        _lunarPickerView.delegate = self;
        _lunarPickerView.dataSource = self;
        _lunarPickerView.showsSelectionIndicator = YES;
    }
    return _lunarPickerView;
}

- (NSDictionary *)lunaDict {
    NSString * strBasePath =[[NSBundle mainBundle] pathForResource:@"lunarcalenda" ofType:@"plist"];
    return [[NSDictionary alloc] initWithContentsOfFile:strBasePath];
}

- (NSArray *)yearArr {
    return @[@"一九零一",@"一九零二",@"一九零三",@"一九零四",@"一九零五",@"一九零六",@"一九零七",@"一九零八",@"一九零九",/*1*/
             @"一九一零",@"一九一一",@"一九一二",@"一九一三",@"一九一四",@"一九一五",@"一九一六",@"一九一七",@"一九一八",@"一九一九",/*2*/
             @"一九二零",@"一九二一",@"一九二二",@"一九二三",@"一九二四",@"一九二五",@"一九二六",@"一九二七",@"一九二八",@"一九二九",/*3*/
             @"一九三零",@"一九三一",@"一九三二",@"一九三三",@"一九三四",@"一九三五",@"一九三六",@"一九三七",@"一九三八",@"一九三九",/*4*/
             @"一九四零",@"一九四一",@"一九四二",@"一九四三",@"一九四四",@"一九四五",@"一九四六",@"一九四七",@"一九四八",@"一九四九",/*5*/
             @"一九五零",@"一九五一",@"一九五二",@"一九五三",@"一九五四",@"一九五五",@"一九五六",@"一九五七",@"一九五八",@"一九五九",/*6*/
             @"一九六零",@"一九六一",@"一九六二",@"一九六三",@"一九六四",@"一九六五",@"一九六六",@"一九六七",@"一九六八",@"一九六九",/*7*/
             @"一九七零",@"一九七一",@"一九七二",@"一九七三",@"一九七四",@"一九七五",@"一九七六",@"一九七七",@"一九七八",@"一九七九",/*8*/
             @"一九八零",@"一九八一",@"一九八二",@"一九八三",@"一九八四",@"一九八五",@"一九八六",@"一九八七",@"一九八八",@"一九八九",/*9*/
             @"一九九零",@"一九九一",@"一九九二",@"一九九三",@"一九九四",@"一九九五",@"一九九六",@"一九九七",@"一九九八",@"一九九九",/*10*/
             @"二零零零",@"二零零一",@"二零零二",@"二零零三",@"二零零四",@"二零零五",@"二零零六",@"二零零七",@"二零零八",@"二零零九",/*11*/
             @"二零一零",@"二零一一",@"二零一二",@"二零一三",@"二零一四",@"二零一五",@"二零一六",@"二零一七",@"二零一八",@"二零一九",/*12*/
             @"二零二零",@"二零二一",@"二零二二",@"二零二三",@"二零二四",@"二零二五",@"二零二六",@"二零二七",@"二零二八",@"二零二九",/*13*/
             @"二零三零",@"二零三一",@"二零三二",@"二零三三",@"二零三四",@"二零三五",@"二零三六",@"二零三七",@"二零三八",@"二零三九",/*14*/
             @"二零四零",@"二零四一",@"二零四二",@"二零四三",@"二零四四",@"二零四五",@"二零四六",@"二零四七",@"二零四八",@"二零四九",/*15*/
             ];
}

- (NSArray *)monthArr {
    NSMutableArray *monthMutable = [@[@"正月",@"二月",@"三月",@"四月",@"五月",@"六月",@"七月",@"八月",@"九月",@"十月",@"十一月",@"腊月"] mutableCopy];
    if (self.leapMonth > 0) {
        //如果有闰月，则插入闰 X 月
        [monthMutable insertObject:[NSString stringWithFormat:@"闰%@",monthMutable[self.leapMonth-1]] atIndex:self.leapMonth];
    }
    return monthMutable;
}

- (NSArray *)dayArr {
    return @[@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",
             @"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",
             @"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十"];
}

- (hjz)solarResult {
    if (_choiceString.length == 0 || _choiceMonth == 0 || _solarResult.year == 0) {//表示从没设置过原始日期 (可能有点损耗性能)
        int year = (int)[self.lunarPickerView selectedRowInComponent:0]+1901;
        int month = (int)[self.lunarPickerView selectedRowInComponent:1]+1;
        int day = (int)[self.lunarPickerView selectedRowInComponent:2]+1;
        _solarResult = lunar_to_solar(year, month, day, self.choiceLeap);
    }
    return _solarResult;
}

- (int)solarYear {
    return self.solarResult.year;
}

- (int)solarMonth {
    return self.solarResult.month;
}

- (int)solarDay {
    return self.solarResult.day;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.lunarPickerView.frame = frame;
}
@end
