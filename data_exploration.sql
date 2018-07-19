select exam_group, count(*) from SYSADM.EXAM_SCHEDULE_VIEW WHERE facility_id != '-' AND crse_offer_nbr = 1 GROUP BY EXAM_GROUP;


--View statement


CREATE OR REPLACE VIEW sysadm.exam_schedule_view
AS
  SELECT c.crse_id,
         c.crse_offer_nbr,
         c.strm,
         c.session_code,
         c.class_section,
         c.subject,
         c.catalog_nbr,
         c.class_nbr,
         m.class_mtg_nbr,
         m.facility_id,
         m.meeting_time_start,
         m.meeting_time_end,
         m.stnd_mtg_pat,
         c.class_stat,
         c.enrl_cap,
         c.enrl_tot,
         CASE
           WHEN m.stnd_mtg_pat IN ( 'M', 'W', 'F', 'MTW',
                                    'MWR', 'MTWF', 'MWRF', 'MTWRF',
                                    'MW', 'WF', 'MWF', 'MF',
                                    'WR', 'MT' )
                AND NOT ( m.meeting_time_start >= To_date('01-01-1900 16:00:00',
                                                  'mm-dd-yyyy hh24:mi:ss'
                                                      )
                          AND m.stnd_mtg_pat IN ( 'M', 'W', 'F' ) ) THEN 'G1'
           WHEN m.stnd_mtg_pat IN ( 'TR', 'T', 'R', 'TWR',
                                    'MTR', 'TRF', 'MTRF', 'MTWR',
                                    'TWRF', 'RF', 'TF' )
                AND NOT ( meeting_time_start >= To_date('01-01-1900 16:00:00',
                                                'mm-dd-yyyy hh24:mi:ss')
                          AND stnd_mtg_pat IN ( 'T', 'R' ) ) THEN 'G2'
           WHEN m.meeting_time_start >= To_date('01-01-1900 18:30:00',
                                       'mm-dd-yyyy hh24:mi:ss') THEN 'G4'
           WHEN m.meeting_time_start >= To_date('01-01-1900 16:00:00',
                                       'mm-dd-yyyy hh24:mi:ss') THEN 'G3'
           
         END AS exam_group
    FROM sysadm.ps_class_tbl c,
         sysadm.ps_class_mtg_pat m
   WHERE m.strm = '2182'
     --AND m.crse_offer_nbr = 1
     AND m.crse_id = c.crse_id
     AND m.crse_offer_nbr = c.crse_offer_nbr
     AND m.strm = c.strm
     AND m.session_code = c.session_code
     AND m.class_section = c.class_section
;

/* Collision count by each group 1, 2
*/
SELECT exam_group,
       SUM(collision)
  FROM (SELECT exam_group,
               facility_id,
               meeting_time_start,
               Count(*) AS collision
          FROM sysadm.exam_schedule_view
         WHERE facility_id != '-'
           AND crse_offer_nbr = 1
           AND ( exam_group = 'G1'
                  OR exam_group = 'G2' )
           AND stnd_mtg_pat != '-'
           --AND facility_id = 'WSQ109'
           AND class_stat = 'A'
         GROUP BY exam_group,
                  facility_id,
                  meeting_time_start
        HAVING Count(*) > 1)
 GROUP BY exam_group
 ORDER BY exam_group; 

SELECT exam_group,
       SUM(collision)
  FROM (SELECT exam_group,
               facility_id,
               day_group,
               Count(*) AS collision
          FROM (SELECT exam_group,
                       facility_id,
                       crse_id,
                       CASE
                         WHEN Instr(stnd_mtg_pat, 'W') > 0 THEN 'W'
                         WHEN Instr(stnd_mtg_pat, 'R') > 0 THEN 'R'
                         WHEN Instr(stnd_mtg_pat, 'F') > 0 THEN 'F'
                         WHEN Instr(stnd_mtg_pat, 'M') > 0 THEN 'M'
                         WHEN Instr(stnd_mtg_pat, 'T') > 0 THEN 'T'
                       END AS day_group
                  FROM sysadm.exam_schedule_view
                 WHERE ( exam_group = 'G3'
                          OR exam_group = 'G4' )
                   AND facility_id != '-'
                   AND stnd_mtg_pat != '-'
                   AND class_stat = 'A')
         GROUP BY exam_group,
                  facility_id,
                  day_group
        HAVING Count(*) > 1)
 GROUP BY exam_group; 

/* Issue with this data. how was this class structured.

SELECT * from sysadm.exam_schedule_view where FACILITY_ID = 'BBC021' and exam_group = 'G3' and STND_MTG_PAT = 'F';

select INSTR('Sudheuru', 'u',3,2) from dual;

SELECT EXAM_GROUP, CRSE_ID,
CASE 
WHEN INSTR(STND_MTG_PAT, 'W') > 0 THEN 'W'
WHEN INSTR(STND_MTG_PAT, 'R') > 0 THEN 'R'
WHEN INSTR(STND_MTG_PAT, 'F') > 0 THEN 'F'
WHEN INSTR(STND_MTG_PAT, 'M') > 0 THEN 'M'
WHEN INSTR(STND_MTG_PAT, 'T') > 0 THEN 'T'
END AS day_group
FROM sysadm.exam_schedule_view
WHERE (exam_group = 'G3' OR exam_group = 'G4')
AND facility_id != '-' AND stnd_mtg_pat != '-' AND crse_id = '010649';

*/


/*same facility same time same crse but different sections. 
why not same section?
*/
SELECT *
  FROM sysadm.exam_schedule_view
 WHERE facility_id = 'WSQ109'
   AND exam_group = 'G1'
   AND meeting_time_start = To_date('01-01-1900 13:30:00',
                            'mm-dd-yyyy hh24:mi:ss'); 



SELECT exam_group,
               facility_id,
               meeting_time_start
          FROM sysadm.exam_schedule_view
         WHERE facility_id != '-'
           AND crse_offer_nbr = 1
           AND ( exam_group = 'G1'
                  OR exam_group = 'G2' )
           AND stnd_mtg_pat != '-'
           AND facility_id = 'WSQ109'
        ;

SELECT exam_group,
               facility_id,
               meeting_time_start,
               Count(*) AS collision
          FROM sysadm.exam_schedule_view
         WHERE facility_id != '-'
           AND crse_offer_nbr = 1
           AND facility_id = 'ENG343'
           AND ( exam_group = 'G1'
                  OR exam_group = 'G2' )
           AND stnd_mtg_pat != '-'
           --AND facility_id = 'WSQ109'
           AND class_stat = 'A'
         GROUP BY exam_group,
                  facility_id,
                  meeting_time_start
        HAVING Count(*) > 1
        ;

Select * from sysadm.exam_schedule_view where (exam_group, facility_id, meeting_time_start) in (SELECT exam_group,
               facility_id,
               meeting_time_start
          FROM sysadm.exam_schedule_view
         WHERE facility_id != '-'
           AND crse_offer_nbr = 1
           --AND facility_id = 'ENG343'
           AND ( exam_group = 'G1'
                  OR exam_group = 'G2' )
           AND stnd_mtg_pat != '-'
           --AND facility_id = 'WSQ109'
           AND class_stat = 'A'
         GROUP BY exam_group,
                  facility_id,
                  meeting_time_start
        HAVING Count(*) > 1
        )
        ORDER BY facility_id, meeting_time_start;


--facility_id = 'DH441' and meeting_time_start = To_date('01-01-1900 14:30:00', 'mm-dd-yyyy hh24:mi:ss');


--Trying to find if the count matches the total records in class
-- This query gives all the classes that have collision in final exam timings 
--in group 1 and group 2
Select * from sysadm.sdw_final_exam_schdl_vw where (exam_group, facility_id, meeting_time_start) in 
   (SELECT exam_group,
               facility_id,
               meeting_time_start
          FROM sysadm.exam_schedule_view
         WHERE facility_id != '-'
           AND crse_offer_nbr = 1
           AND ( exam_group = 'G1'
                  OR exam_group = 'G2' )
           AND stnd_mtg_pat != '-'
           --AND facility_id = 'WSQ109'
           AND class_stat = 'A'
         GROUP BY exam_group,
                  facility_id,
                  meeting_time_start
        HAVING Count(*) > 1)
     AND crse_offer_nbr = 1
     ORDER BY facility_id, crse_id, meeting_time_start
     ;
 
sdw_final_exam_schdl_vw
