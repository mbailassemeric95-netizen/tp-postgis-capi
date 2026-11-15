-- Etape 0 : Détermination de l’emprise du territoire d’identification du gisement
create schema if not exists geonum_gst;
create table geonum_gst.zonage_urbain as
select geom
from geonum_reference.zonage_urbanisme
where typezone in ('AUs', 'Aus', 'U');


-- Etape 1 : Création du masque bâtiment
-- Adaptation du masque selon la taille du bati (2m <50m² sinon 50m)
-- Etape 2 : Création du masque des infrastructures linéaires (route, rail)
-- Adaptation du masque selon l’importance de l’infra linéaire (15m pour voirie principal et rail, 7m voirie secondaire)
-- Etape 3 : Création du masque des équipements et des spécificités du territoire
-- Etape 4 : Identification des parcelles candidates
-- Etape 5 : Identification du gisement non bâti
-- Etape 7 : Mise en forme de la couche finale
