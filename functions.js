function formatTime(hour, min)
{
    return ((hour%12)?(hour%12):12) + ((min<10)?":0":":") + min + " " + ((hour < 12)?"am":"pm");
}

function isDay(hour)
{
    return (hour < 21)&&(hour > 5);
}

function daysFriendly(days)
{
    var weekday = [qsTr("Mon"),
                   qsTr("Tue"),
                   qsTr("Wed"),
                   qsTr("Thu"),
                   qsTr("Fri"),
                   qsTr("Sat"),
                   qsTr("Sun")];

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
            res += weekday[idx];
            cnt++;
        }
    }
    return res;
}
