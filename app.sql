create or replace function public.prepare_my_checklist_for_date(p_work_date date default current_date)
returns void language plpgsql security invoker as $func$
begin
insert into public.checklists(staff_id,work_date,task_no,done,completed_at)
select t.staff_id,p_work_date,t.task_no,false,null
from public.task_templates t
where t.active=true and t.staff_id=auth.uid()
and (t.frequency='daily'
or (t.frequency='weekly' and t.weekly_day is not null and extract(dow from p_work_date)=t.weekly_day)
or (t.frequency='monthly' and t.monthly_day is not null and extract(day from p_work_date)=t.monthly_day)
or (t.frequency='biweekly' and t.biweekly_anchor is not null and mod(p_work_date-t.biweekly_anchor,14)=0)
or (t.frequency='yearly' and t.yearly_month is not null and t.yearly_day is not null and extract(month from p_work_date)=t.yearly_month and extract(day from p_work_date)=t.yearly_day)
or (t.frequency='scheduled' and t.scheduled_date=p_work_date))
on conflict(staff_id,work_date,task_no) do nothing;
end;
$func$;
