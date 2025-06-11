--Rollback segment spaced is used by a SQL session
SELECT
     r.name "Rollback|Segment",
     l.Sid "Oracle|PID", 
     p.spid "Sys|PID",
     NVL(p.username, 'no transaction') "Transaction",
     p.program "Program",
     s.curext "Current|Extent",
     s.curblk "Current|Block" 
FROM
     v$lock l,
     v$process p,
     v$rollname r,
     v$rollstat s
WHERE l.Sid = p.pid (+)
     AND TRUNC(l.id1(+) / 65536) = r.usn
     AND l.type(+) = 'TX'
     AND l.lmode(+) = 6
     AND r.usn=s.usn
     AND p.username is not null
ORDER BY r.name;

