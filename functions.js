var weekday = [qsTr("Monday"),
               qsTr("Tuesday"),
               qsTr("Wednesday"),
               qsTr("Thursday"),
               qsTr("Friday"),
               qsTr("Saturday"),
               qsTr("Sunday")];

var weekdayShort = [qsTr("Mon"),
                    qsTr("Tue"),
                    qsTr("Wed"),
                    qsTr("Thu"),
                    qsTr("Fri"),
                    qsTr("Sat"),
                    qsTr("Sun")];

function formatTime(hour, min)
{
    return localeHelper.localTime(new Date(2000, 0, 1, hour, min, 0, 0), Labs.LocaleHelper.TimeFull);
}

function isDay(hour)
{
    return (hour < 21)&&(hour > 5);
}

function daysFriendly(days)
{
    if((days&0x7f) == 0x7f)
        return qsTr("Every Day");
    else if((days&0x7f) == 0x1f)
        return qsTr("Weekdays");
    else if((days&0x7f) == 0x60)
        return qsTr("Weekends");

    var res = "";
    var cnt = 0;
    var idx = 0;
    for(idx = 0; idx < 7; idx++)
    {
        if(days&(1<<idx))
        {
            if(cnt > 0)
                res += ",";
            res += weekdayShort[idx];
            cnt++;
        }
    }
    return res;
}
