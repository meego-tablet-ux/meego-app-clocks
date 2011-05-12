var weekday = [qsTr("Sunday"),
               qsTr("Monday"),
               qsTr("Tuesday"),
               qsTr("Wednesday"),
               qsTr("Thursday"),
               qsTr("Friday"),
               qsTr("Saturday")];

var weekdayShort = [qsTr("Sun"),
                    qsTr("Mon"),
                    qsTr("Tue"),
                    qsTr("Wed"),
                    qsTr("Thu"),
                    qsTr("Fri"),
                    qsTr("Sat")];

function formatTime(hour, min)
{
    return qsTr("%1:%2").arg(hour).arg(min<10?"0"+min:min)
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
