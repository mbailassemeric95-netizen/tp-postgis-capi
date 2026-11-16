-- -- Etape 0 : Détermination de l’emprise du territoire d’identification du gisement
-- ----------------------------

-- -- créer un schéma pour y stocker les tables hébergeant nos requetes
-- \set ON_ERROR_STOP on
-- SET client_encoding = 'UTF8';

-- -- Dump de mes resultats pour livraison aux etudiants
-- --pg_dump -E UTF8 -U dba_pg15 -O -v -x -w --format=p -t geonum_capi.data
-- create schema if not exists geonum_capi ;

-- --create table if not exists geonum_capi.data as
-- --> disable > la table est cree pour la premiere execution, puis on utilise la commande qui suit

-- drop table if exists geonum_capi.emprise_capi;
-- create table geonum_capi.emprise_capi as
-- select *
-- from geonum_reference.epci
-- where epci = '243800604';

-- drop table if exists geonum_capi.data;
drop table if exists geonum_capi.zonage_urbain_capi;

create table geonum_capi.zonage_urbain_capi as
select (st_dump(st_union(zu.geom))).geom as geom
from geonum_reference.zonage_urbanisme zu
join geonum_capi.emprise_capi ec
on st_intersects(ec.geom, zu.geom)
where zu.typezone in ('AUc', 'AUs', 'U');




-- -- Etape 1 : Création du masque bâtiment
-- -- Adaptation du masque selon la taille du bati (2m <50m² sinon 50m)
-- -- Etape 2 : Création du masque des infrastructures linéaires (route, rail)
-- -- Adaptation du masque selon l’importance de l’infra linéaire (15m pour voirie principal et rail, 7m voirie secondaire)

-- -- Etape 3 : Création du masque des équipements et des spécificités du territoire
-- -- Etape 4 : Identification des parcelles candidates
-- -- Etape 5 : Identification du gisement non bâti
-- -- Etape 7 : Mise en forme de la couche finale
