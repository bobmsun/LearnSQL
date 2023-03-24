
select 
pe.title as project_title_end,
ps.title as project_title_start,
pe.end_date as date 
from projects as pe 
join project as ps 
on to_char(ps.start_date, 'MM-DD-YYYY') = to_char(ps.end_date, 'MM-DD-YYYY')

-- on date(ps.start_date) = date(pe.end_date)
