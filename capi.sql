-- Etape 0 : Détermination de l’emprise du territoire d’identification du gisement
----------------------------

-- créer un schéma pour y stocker les tables hébergeant nos requetes
\set ON_ERROR_STOP on
SET client_encoding = 'UTF8';

-- Dump de mes resultats pour livraison aux etudiants
--pg_dump -E UTF8 -U dba_pg15 -O -v -x -w --format=p -t geonum_capi.data
create schema if not exists geonum_capi ;

--create table if not exists geonum_capi.data as
--> disable > la table est cree pour la premiere execution, puis on utilise la commande qui suit

--Création de l'emprise de la zone d'étude
drop table if exists geonum_capi.emprise_capi;
create table geonum_capi.emprise_capi as
select *
from geonum_reference.epci
where epci = '243800604';

-- drop table if exists geonum_capi.data;
drop table if exists geonum_capi.zonage_urbain_capi;

-- Création masque pour le zonage urbain
create table geonum_capi.zonage_urbain_capi as
select (st_dump((st_union(zu.geom)))).geom as geom
from geonum_reference.zonage_urbanisme zu
join geonum_capi.emprise_capi ec
on st_intersects(ec.geom, zu.geom)
where zu.typezone in ('AUc', 'AUs', 'U');

create index gx_zonage_urbain_capi on geonum_capi.zonage_urbain_capi using gist(geom);

-- Etape 1 : Création du masque bâtiment
-- Adaptation du masque selon la taille du bati (2m <50m² sinon 50m)
drop table if exists geonum_capi.batiment;
create table geonum_capi.batiment as
select st_intersection(bat.geom, emp.geom) as geom, bat.nature, bat.usage_1
from geonum_reference.bdtopo_batiment as bat
inner join geonum_capi.zonage_urbain_capi as emp
on st_intersects(bat.geom, emp.geom);
create index gx_batiment_v2 on geonum_capi.batiment_v2 using gist(geom);

-- Etape 2 : Création du masque des infrastructures linéaires 
-- (route, rail)
-- Adaptation du masque selon l’importance de l’infra linéaire 
-- (15m pour voirie principal et rail, 7m voirie secondaire)
-- Création du masque pour la voirie
drop table if exists geonum_capi.masque_voirie;
create table geonum_capi.masque_voirie as

with route_capi as(
select ro.ogc_fid, 'route'::text as categorie, ro.highway as type_voie, ro.geom
from geonum_capi.emprise_capi as ec
join geonum_reference.osm_road ro
on st_intersects(ro.geom, ec.geom)

union all

select ra.ogc_fid, 'rail' ::text as categorie, 'rail'::text as type_voie, ra.geom
from geonum_capi.emprise_capi as ec
join geonum_reference.osm_railway ra
on st_intersects(ra.geom, ec.geom)
)

select ogc_fid, categorie, type_voie,
    case
        when type_voie in ('rail', 'motorway', 'primary', 'secondary', 'tertiary') then st_buffer(geom, 15)
        else st_buffer(geom, 7)
    end as geom
from route_capi;

create index gx_masque_voirie on geonum_capi.masque_voirie using gist (geom);

-- Etape 3 : Création du masque des équipements et des spécificités du territoire
drop table if exists geonum_capi.equipement;
create table geonum_capi.equipement as
select st_intersection(cim.geom, emp.geom) as geom
from geonum_reference.bdtopo_cimetiere as cim
inner join geonum_capi.zonage_urbain_capi as emp
on st_intersects(cim.geom, emp.geom);
create index gx_cimetiere on geonum_capi.equipement using gist(geom);

-- Etape 4 : Identification des parcelles candidates
-- Etape 5 : Identification du gisement non bâti
-- Etape 7 : Mise en forme de la couche finale
