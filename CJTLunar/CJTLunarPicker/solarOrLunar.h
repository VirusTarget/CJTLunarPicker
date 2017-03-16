//
//  solarOrLunar.h
//  iPhone4OriPhone5
//
//  Created by cqsxit on 13-11-14.
//  Copyright (c) 2013年 cqsxit. All rights reserved.
//

#ifndef iPhone4OriPhone5_solarOrLunar_h
#define iPhone4OriPhone5_solarOrLunar_h

typedef struct _hjz{
    int year;
    int month;
    int day;
    int reserved;
} hjz;


hjz lunar_to_solar(int year , int month , int day ,int reserved);/*农历转公历*/

hjz solar_to_lunar(int year , int month , int day );/*公历转农历*/
#endif
