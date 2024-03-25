SELECT
    'facilities' AS table_name,
    count(*) AS cnt
FROM
    cd.facilities

UNION ALL

SELECT
    'members' AS table_name,
    count(*) AS cnt
FROM
    cd.members

UNION ALL

SELECT
    'bookings' AS table_name,
    count(*) AS cnt
FROM
    cd.bookings