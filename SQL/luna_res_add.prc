create or replace procedure luna_res_add(
   p_nn  NUMBER
  ,p_dt  DATE
  ,p_jsontext VARCHAR2
) is
begin
  begin
     insert into luna_res(
        sdt
        ,dt
        ,nn
        ,rest_resp
     ) values (
        sysdate
        ,p_dt
        ,p_nn
        ,p_jsontext
     );
     commit;
  exception
    when OTHERS then
        rollback;
  end;
end luna_res_add;
/
