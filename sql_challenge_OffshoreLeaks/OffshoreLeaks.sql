# SEE WHAT YOU HAVE
# $ more file.name
# $ file file.name

# install preg_replace package
# https://github.com/mysqludf/lib_mysqludf_preg

use OffshoreLeaks;

create table countries
(
country_id int,
country_code varchar(2),
country_name varchar(255)
);

load data
infile '20140423/countriesNW.csv'
into table countries
fields terminated by ';'
enclosed by '"'
escaped by ''
lines terminated by '\r\n'
ignore 1 lines
(@vcountry_id, @vcountry_code, @vcountry_name)
set
country_id = nullif(@vcountry_id,''),
country_code = nullif(@vcountry_code,''),
country_name = nullif(@vcountry_name,'')
;

create table edges
  (unique_id int,
   entity_id1 int,
   entity_id2 int,
   description varchar(255),
   date_from varchar(255),
   date_to varchar(255),
   direction int,
   chinesePos int,
   link_type varchar(2)
   );

load data infile '20140423/edges_1DNW.csv'
into table edges
fields terminated by ';'
enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines
(@vunique_id, @ventity_id1, @ventity_id2, @vdescription, @vdate_from, @vdate_to, @vdirection, @vchinesePos, @vlink_type)
set
unique_id = nullif(@vunique_id,''),
entity_id1 = nullif(@ventity_id1,''),
entity_id2 = nullif(@ventity_id2,''),
description = nullif(@vdescription,''),
date_from =
  case when @vdate_from = ''
  then NULL
  else str_to_date(preg_replace('/[A-Z][A-Z][A-Z]/','',@vdate_from),'%a %b %d %H:%i:%s %Y')
  end,
date_to =
  case when @vdate_to = ''
  then NULL
  else str_to_date(preg_replace('/[A-Z][A-Z][A-Z]/','',@vdate_to),'%a %b %d %H:%i:%s %Y')
  end,
direction = nullif(@vdirection,''),
chinesePos =
  case when @vchinesePos = ''
  then NULL
  else '1'
  end,
link_type = nullif(@vlink_type,'')
;

create table node_countries
  (
   node_id int,
   country_code varchar(2),
   country_name varchar(255),
   country_id int
   );

load data infile '20140423/node_countriesNW.csv'
into table node_countries
fields terminated by ';'
enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines
(@vnode_id, @vcountry_code, @vcountry_name, @vcountry_id)
set
node_id = nullif(@vnode_id,''),
country_code = nullif(@vcountry_code,''),
country_name = nullif(@vcountry_name,''),
country_id = nullif(@vcountry_id,'')
;

create table nodes
  (
   unique_id int,
   subtypes varchar(255),
   description varchar(255),
   searchfield text,
   status varchar(1),
   desc_status varchar(255),
   type varchar(255),
   desc_company_type varchar(255),
   inc_dat datetime,
   dorm_dat datetime,
   juris varchar(15),
   desc_juris varchar(255),
   address text,
   agency_id int,
   tax_stat varchar(15),
   desc_tax_stat varchar(255)
   );

load data infile '20140423/nodesNW.csv'
into table nodes
fields terminated by ';'
enclosed by '"'
lines terminated by '\r\n'
ignore 1 lines
(@vunique_id, @vsubtypes, @vdescription, @vsearchfield, @vstatus, @vdesc_status, @vtype, @vdesc_company_type, @vinc_dat,
@vdorm_dat, @vjuris, @vdesc_juris, @vaddress, @vagency_id, @vtax_stat, @vdesc_tax_stat)
set
unique_id = nullif(@vunique_id,''),
subtypes = nullif(@vsubtypes,''),
description = nullif(@vdescription,''),
searchfield = nullif(@vsearchfield,''),
status = nullif(@vstatus,''),
desc_status = nullif(@vdesc_status,''),
type = nullif(@vtype,''),
desc_company_type = nullif(@vdesc_company_type,''),
inc_dat =
  case when @vinc_dat = ''
  then NULL
  else str_to_date(preg_replace('/[A-Z][A-Z][A-Z]/','',@vinc_dat),'%a %b %d %H:%i:%s %Y')
  end,
dorm_dat =
  case when @vdorm_dat = ''
  then NULL
  else str_to_date(preg_replace('/[A-Z][A-Z][A-Z]/','',@vdorm_dat),'%a %b %d %H:%i:%s %Y')
  end,
juris = nullif(@vjuris,''),
desc_juris = nullif(@vdesc_juris,''),
address = nullif(@vaddress,''),
agency_id = nullif(@vagency_id,''),
tax_stat = nullif(@vtax_stat,''),
desc_tax_stat = nullif(@vdesc_tax_stat,'')
;

# A LITTLE EXPLORATION

# DATES: are there companies created and ended in less than a year?
CREATE TEMPORARY TABLE lessyear
(SELECT d.description, d.ddate * 12
FROM  (SELECT unique_id, description, DATEDIFF(dorm_dat,inc_dat)/365 AS ddate
    FROM nodes
    WHERE dorm_dat IS NOT NULL AND inc_dat IS NOT NULL) AS d
WHERE d.ddate < 1);
# Yes. There are 27, 2 of which seem to be errors. Created temporary table to continue working with.

# What countries are the companies from?
SELECT ly.description, nc.country_name
FROM lessyear AS ly
LEFT JOIN node_countries AS nc
ON ly.unique_id = nc.node_id
WHERE nc.country_name NOT LIKE 'Not Identified';

# Which countries have the most short term offshores?
SELECT COUNT(ly.description) AS counts, nc.country_name
FROM lessyear AS ly
LEFT JOIN node_countries AS nc
ON ly.unique_id = nc.node_id
WHERE nc.country_name NOT LIKE 'Not Identified'
GROUP BY nc.country_name
ORDER BY counts;
# Panama and the United Kingdom, with 6 each.



