/*
    Quick and dirty script to help determine growth rate of SQLMON data.
*/

SELECT  f1.timestamp,
        f1.spaceusedmb,
        f2.timestamp,
        f2.spaceusedmb,
        f1.spaceusedmb - f2.spaceusedmb 'difference',
        (f1.spaceusedmb - f2.spaceusedmb) * (90/7) 'Per 90',
        (f1.spaceusedmb - f2.spaceusedmb) * 52 'Per Year',
        *
        
FROM sqlmon_files f1
    LEFT JOIN sqlmon_files f2
        ON  f1.databasename = f2.databasename
        AND f1.fileid = f2.fileid
        AND dateadd(MINUTE, datediff(MINUTE, 30, f2.Timestamp), 0) = DATEADD(DAY, -7, dateadd(MINUTE, datediff(MINUTE, 30, f1.Timestamp), 0))

WHERE f1.databasename = 'SQLMON'
AND   f1.fileid = 1

ORDER BY f1.Timestamp desc
