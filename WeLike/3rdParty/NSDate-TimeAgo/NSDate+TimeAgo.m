#import "NSDate+TimeAgo.h"

@implementation NSDate (TimeAgo)

// Similar to timeAgo, but only returns "
- (NSString *)dateTimeAgo
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate * now = [NSDate date];
    NSDateComponents *components = [calendar components:
                                    NSCalendarUnitYear|
                                    NSCalendarUnitMonth|
                                    NSCalendarUnitWeekOfYear|
                                    NSCalendarUnitDay|
                                    NSCalendarUnitHour|
                                    NSCalendarUnitMinute|
                                    NSCalendarUnitSecond
                                               fromDate:self
                                                 toDate:now
                                                options:0];
    
    if (components.year >= 1)
    {
        if (components.year == 1)
        {
            return @"1 year ago";
        }
        return [NSString stringWithFormat:@"%d years ago", (int)components.year];
    }
    else if (components.month >= 1)
    {
        if (components.month == 1)
        {
            return @"1 month ago";
        }
        return [NSString stringWithFormat:@"%d months ago", (int)components.month];
    }
    else if (components.weekOfYear >= 1)
    {
        if (components.weekOfYear == 1)
        {
            return @"1 week ago";
        }
        return [NSString stringWithFormat:@"%d weeks ago", (int)components.weekOfYear];
    }
    else if (components.day >= 1)    // up to 6 days ago
    {
        if (components.day == 1)
        {
            return @"1 day ago";
        }
        return [NSString stringWithFormat:@"%d days ago", (int)components.day];
    }
    else if (components.hour >= 1)   // up to 23 hours ago
    {
        if (components.hour == 1)
        {
            return @"An hour ago";
        }
        return [NSString stringWithFormat:@"%d hours ago", (int)components.hour];
    }
    else if (components.minute >= 1) // up to 59 minutes ago
    {
        if (components.minute == 1)
        {
            return @"A minute ago";
        }
        return [NSString stringWithFormat:@"%d minutes ago", (int)components.minute];
    }
    else if (components.second < 5)
    {
        return @"Just now";
    }
    
    // between 5 and 59 seconds ago
    return [NSString stringWithFormat:@"%d seconds ago", (int)components.second];
}

@end
