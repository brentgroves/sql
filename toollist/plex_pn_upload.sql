
create table bt_plex_pn
(
  part_key int,
  part_no varchar(100),
  revision varchar(8),
  part_no_rev varchar(113)
)
Bulk insert bt_plex_pn
from 'c:\toollist_pn.csv'
with
(
	fieldterminator = ',',
	rowterminator = '\n'
)

/*
select 
--count(*) 
top(100) 
p.part_key,
p.part_no,
p.revision,
case 
when p.revision = '' then p.part_no
else p.part_no + '_Rev_' + p.revision 
end part_no_rev  
from part_v_part p
inner join part_v_part_source ps
on p.part_source_key=ps.part_source_key
where p.part_status='Production'
and ps.part_source = 'Manufactured'  --359
*/