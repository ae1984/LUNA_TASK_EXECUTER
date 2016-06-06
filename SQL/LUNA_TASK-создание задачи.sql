--truncate table LUNA_TASK
insert into LUNA_TASK
select 
    sysdate as DT
    ,row_number() over (order by t.c_photo_date desc) as nn
    ,'http://vislabs-node1.hq.bc:8082/similar_templates?id='||to_char(t.c_bin_id)||'&'||'candidates='||to_char(t.c_bin_id) as rest_query
from U1.V_RFO_DEV_Z#PHOTO4UPLOAD t 
where t.c_photo_type = 'FOTO_FL' --and rownum <=10000;

insert into LUNA_TASK
select 
    sysdate as dt
    ,row_number() over (order by t.nn asc) as nn
    ,t.rest_query 
from LUNA_TASK t
left join LUNA_RES a on a.dt = t.dt and a.nn = t.nn
where t.dt = (select max(dt) from LUNA_TASK) and a.sdt is null

select dt, count(*) 
from LUNA_TASK t
group by dt

select * from LUNA_TASK

--truncate table LUNA_RES
select * from LUNA_RES
select count(*) from LUNA_RES

select * from LUNA_TASK t
where nn= 182626



select 
   count(*) as cnt
   ,sum(case when t.rest_resp ='Ошибка в ответе с сервера LUNA' then 1 else 0 end) as cnt_luna_err
   ,sum(case when t.rest_resp like '%"similarity":1%' then 1 else 0 end) as cnt_ok
   ,sum(case when t.rest_resp not like '%"similarity":1%'
                  and t.rest_resp <> 'Ошибка в ответе с сервера LUNA' 
             then 1 else 0 end) as cnt_other_error
from LUNA_RES t
where t.dt = (select max(dt) from LUNA_TASK)

select 
   trunc(t.nn/10000)
   ,count(*) 
   ,trunc((max(sdt)-min(sdt))*60*24) as "время обр. мин"
from LUNA_RES t
where t.dt = (select max(dt) from LUNA_TASK)
group by trunc(t.nn/10000)
order by trunc(t.nn/10000) desc

delete from LUNA_RES t
where t.dt = (select max(dt) from LUNA_TASK)

select * from LUNA_RES t
where t.dt = (select max(dt) from LUNA_TASK)

select * 
from (
    SELECT 
       jt.reference
       ,jt.id as candidates_id
       ,jt.similarity
       ,jt.error
       ,jt.desc_
       ,jt.detail
    FROM LUNA_RES t,
           json_table(t.rest_resp,
                      '$' COLUMNS(
                           reference VARCHAR2(32 CHAR) PATH '$.reference',
                           NESTED PATH '$.matches[*]'
                              COLUMNS(id NUMBER PATH '$.id',
                                      similarity NUMBER PATH '$.similarity'
                                      ),
                           desc_ VARCHAR2(200 CHAR) PATH '$.desc',
                           detail VARCHAR2(200 CHAR) PATH '$.detail',
                           error VARCHAR2(10 CHAR) PATH '$.error'
                        )
                      ) jt
    where t.rest_resp like '%"similarity":1%'                      
                  
) t
left join LUNA_SIMILAR_TEMPLATES_RES_ALL a on a.id = t.reference
where a.jsontext not like '%"similarity":1%'   



    SELECT 
       jt.reference
       ,jt.id as candidates_id
       ,jt.similarity
       ,jt.error
       ,jt.desc_
       ,jt.detail
    FROM LUNA_RES t,
           json_table(t.rest_resp,
                      '$' COLUMNS(
                           reference VARCHAR2(32 CHAR) PATH '$.reference',
                           NESTED PATH '$.matches[*]'
                              COLUMNS(id NUMBER PATH '$.id',
                                      similarity NUMBER PATH '$.similarity'
                                      ),
                           desc_ VARCHAR2(200 CHAR) PATH '$.desc',
                           detail VARCHAR2(200 CHAR) PATH '$.detail',
                           error VARCHAR2(10 CHAR) PATH '$.error'
                        )
                      ) jt
    where t.rest_resp like '%"similarity":1%'     


--фото, по которым есть хэши в 27-й версии

select count(*)
from u1.V_RFO_DEV_Z#PHOTO4UPLOAD af
join (
select luna_id as luna_id from U1.t_luna_result_1
union all
select luna_id as luna_id from U1.t_luna_result_2
union all
select luna_id as luna_id from U1.t_luna_result_3
union all
select luna_id as luna_id from U1.t_luna_result_4
union all
select luna_id as luna_id from U1.t_luna_result_6
union all
select luna_id as luna_id from U1.t_luna_result_7
union all
select luna_id2 as luna_id from U1.t_luna_result_1
union all
select luna_id2 as luna_id from U1.t_luna_result_2
union all
select luna_id2 as luna_id from U1.t_luna_result_3
union all
select luna_id2 as luna_id from U1.t_luna_result_4
union all
select luna_id2 as luna_id from U1.t_luna_result_6
union all
select luna_id2 as luna_id from U1.t_luna_result_7) bf on af.c_bin_id = bf.luna_id
