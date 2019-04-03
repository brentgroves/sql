--inventory location
--Location,Building Code,Location Type,Note,Location Group
select 
'"' + CribBin + '"'  as location,
'BPG Central Stores' as building_code,
'Supply Crib' as location_type,
'' as note,
'MRO Crib' as location_group
from station
where crib = 12

-- Supply Item Locations
select 
'"' + item + '"' as item_no,
'"' + CribBin + '"' as location,
BinQuantity as quantity,
'N' as Building_Default,
'' Transaction_Type
from station
where crib = 12

Create View bvCribItems
as
	select	
	--'"' + itemnumber + '"' as "Item_No",
	itemnumber as "Item_No",
	Brief_Description,Description,Note,Item_Type,Item_Group,Item_Category,
	Item_Priority,Customer_Unit_Price,Average_Cost,Inventory_Unit,Min_Quantity,Max_Quantity,
	Tax_Code,Account_No,Manufacturer,Manf_Item_No,Drawing_No,Item_Quantity,Location,Supplier_Code,
	Supplier_Part_No,Supplier_Std_Purch_Qty,Currency,Supplier_Std_Unit_Price,Supplier_Purchase_Unit,
	Supplier_Unit_Conversion,Supplier_Lead_Time,Update_When_Received,Manufacturer_Item_Revision,
	Country_Of_Origin,Commodity_Code_Key,Harmonized_Tariff_Code,Cube_Length,Cube_Width,Cube_Height,
	Cube_Unit			
	from
	(
			select 
		--		row_number() OVER(ORDER BY vn.VendorName ASC) AS Row#,
		--		'"' + inv.itemnumber + '"' as "Item_No",
				inv.ItemNumber,
				Description1 as "Brief_Description", 
				ISNULL(Description2, Description1) as Description, 
				case 
					when inv.Comments is null then ' '
					else inv.Comments
				end as Note,
				case
					when InactiveItem = 1 then 'Obsolete'
					else 'Tooling'
				end as item_type,
				case 
					when CHARINDEX('R',right(inv.ItemNumber,1)) <> 0 then 'Regrinds-Repair-Retip'
					else 'Tooling'
				end as Item_Group,
				case
					-- Added these 2 item classes to table
					-- when inv.ItemClass = 'HYDRUALIC VALVE' then 'Hydraulic Valve' 
					-- when inv.ItemClass = 'PIVOT PIN' then 'Pivot Pin'
					when inv.ItemClass is null then 'Misc'
					else cat.ItemClass 
				end as Item_Category,
				case
					when CriticalItemOption = 1 then 'High'
					when InactiveItem = 1 then 'Low'
					else 'Medium'
				end as Item_Priority,
				av.Cost as Customer_Unit_Price,
				'' as Average_Cost,
				'Ea' as Inventory_Unit,
				mQty.Min_Quantity,
				mQty.Max_Quantity,
				'' as Tax_Code,
				'' as Account_No,
				'' as Manufacturer,
				Description1 as Manf_Item_No,
				'' as Drawing_No,
				'' as Item_Quantity,
				'' as Location,
				vn.VendorName as Supplier_Code,
				Description1 as Supplier_Part_No,
				'' as Supplier_Std_Purch_Qty,
				'USD' as Currency,
				av.Cost as Supplier_Std_Unit_Price,
				'Ea' as Supplier_Purchase_Unit,
				1 as Supplier_Unit_Conversion,
				'' as Supplier_Lead_Time,
				'Y' as Update_When_Received,
				'' as Manufacturer_Item_Revision,
				'' as Country_Of_Origin,
				'' as Commodity_Code_Key,
				'' as Harmonized_Tariff_Code,
				'' as Cube_Length,
				'' as Cube_Width,
				'' as Cube_Height,
				'' as Cube_Unit
			-- select 
			-- count(*) -- 16631 
			-- distinct inv.ItemNumber --16631
			-- btRemoveItems count	    -  982
			--                          =15649     
			-- inv.ItemNumber
			-- count(*)
			--select 
			--	vn.VendorName as Supplier_Code
			from INVENTRY inv 
			left outer join btRemoveItems2 ri
				on inv.ItemNumber=ri.itemnumber
			-- where ri.ItemNumber is null --15709
			left outer join btItemClassCatKey cat
				on inv.ItemClass = upper(cat.itemclass)
			--where inv.ItemClass is null  -- 20 null items
			-- where cat.ItemClass is null --15709
			left outer join AltVendor av
				ON inv.AltVendorNo = av.RecNumber
			left outer join VENDOR vn
				on av.VendorNumber = vn.VendorNumber
			--where ri.ItemNumber is null --15709
			left outer join (
				select item, max(OverrideOrderPoint) as Min_Quantity, max(Maximum) as Max_Quantity
				from 
				(
					select item, OverrideOrderPoint, Maximum from STATION
					where OverrideOrderPoint is not null and Maximum is not null and CHARINDEX('R',right(item,1)) = 0 
				)lv1
				group by item
			) mQty
			on inv.ItemNumber = mQty.Item
			where inv.ItemNumber <> '' and left(inv.ItemNumber,1) <> ' ' 
			and ri.itemnumber is null
			and item='15977' --test avilla
	)lv1

-- Supply Items in Plex
--CREATE TABLE Cribmaster.dbo.btPlexItem (
	Item_No varchar(50) NOT NULL,
)
Bulk insert btPlexItem
from 'C:\PlexItemGT14000.csv'
with
(
fieldterminator = ',',
rowterminator = '\n'
)
--7000 
--5000
--2000
--4237
-- Items in plex but not it Cribmaster = 4423
--0012785/plex - 12785/Crib
--0007290
--0013739
--0011226
--0007675
--0009171/plex - 009171/Crib
select pi.*
from btPlexItem pi
left outer join INVENTRY inv
on pi.item_no=inv.ItemNumber
where inv.ItemNumber is null

select * from INVENTRY 
where ItemNumber like '%7675%'
where Description1 like '%05518-12.50%'

-- Items in Cribmaster but not in Plex
--select count(*) from (select distinct item_no from btPlexItem)lv1 where item_no = ''
--delete from btPlexItem 
where item_no like '%--%'
--where LTRIM(RTRIM(item_no)) = ''
select * from btPlexItem where item_no like '%011458%'
select * from INVENTRY where itemnumber like '%011458%'	
--Create map from Plex supplier_code to Crib vendorName	
--Busche Albion,Busche 
update btSupplyCode
set VendorName = 'BUSCHE ENTERPRISES'
where Supplier_Code = 'Busche Albion'

select top 10 *
from STATION st
where crib = 11


select *
from
(
select ROW_NUMBER() OVER(ORDER BY VendorName ASC) AS Row#, VendorName
from (
select 
--top 100 inv.ItemNumber,inv.Description1,vn.VendorName,sc.supplier_code
distinct vn.VendorName  --159
-- done 3/159
from INVENTRY inv 
left outer join btRemoveItems2 ri
	on inv.ItemNumber=ri.itemnumber
-- where ri.ItemNumber is null --15709
left outer join btItemClassCatKey cat
	on inv.ItemClass = upper(cat.itemclass)
--where inv.ItemClass is null  -- 20 null items
-- where cat.ItemClass is null --15709
left outer join AltVendor av
	ON inv.AltVendorNo = av.RecNumber
left outer join VENDOR vn
	on av.VendorNumber = vn.VendorNumber
left outer join btSupplyCode sc
	on vn.VendorName=sc.VendorName
left outer join STATION st 
	on inv.ItemNumber=st.Item
where ri.ItemNumber is null --15709
--and item='15977'
--and sc.vendorname is not null
--order by vn.VendorName
)lv1
)lv2
where row# > 25




















-- Cant find these in plex
-- 2L INC
select * from btSupplyCode where supplier_code like '%3D Scan IT%'
--Bulk insert btRemoveItems
--from 'C:\itemsremove2.csv'
Bulk insert btSupplyCode
from 'C:\supplier_code.csv'
with
(
fieldterminator = ',',
rowterminator = '\n'
)


-- btRemoveItems csv import file was saved in excel so some leading zeros got deleted.
-- select top 10 * from btRemoveItems --982
-- insert records with 1 and 2 zeros
-- select count(*) 	--982*3=2946
-- select * into btRemoveItems2 
from (
	--982*3=2946
	select ItemNumber from btRemoveItems
	UNION
	select '0' + ItemNumber from btRemoveItems
	UNION
	select '00' + ItemNumber from btRemoveItems
)lv1
--select * from btRemoveItems2 where itemnumber like '%15222%'

-- Is all the needed item classes in plex?
select DISTINCT ItemClass
from
(
	select inv.ItemClass, cat.itemclass class 
	from INVENTRY inv 
	left outer join btItemClassCatKey cat 
	on upper(cat.itemclass) = inv.ItemClass
	where cat.ItemClass is null
)lv1
-- Pivot Pin is in plex so insert in table
-- Hydraulic Valve is spelled wrong in Cribmaster so insert with misspelling but correct cat key.
INSERT INTO Cribmaster.dbo.btItemClassCatKey
(ItemClass, ItemCategoryKey)
VALUES('HYDRUALIC VALVE', '18201');
--VALUES('Pivot Pin', '14734');

select * from btItemClassCatKey cat where cat.ItemClass like '%Pivot%'

--Are there any item classes in Plex we don't need?
select distinct rm.itemclass
from 
(
select cat.itemclass, inv.ItemClass class 
from btItemClassCatKey cat
left outer join INVENTRY inv 
on upper(cat.itemclass) = inv.ItemClass
where inv.ItemClass is null
) rm

