-- A  partir  du  script  SQL Gaulois  fourni  par  votre  formateur,  écrivez  et  exécutez  les requêtes SQL suivantes:

-- 1. Nom des lieux qui finissent par 'um'.
SELECT 
	l.nom_lieu
FROM 
	lieu l 
WHERE
	l.nom_lieu LIKE '%um'

-- 2. Nombre de personnages par lieu (trié par nombre de personnages décroissant).

CREATE VIEW persoParLieu AS
SELECT 
	COUNT(pe.id_personnage) AS nbr_perso,
	l.nom_lieu
FROM
	personnage pe
INNER JOIN lieu l ON l.id_lieu = pe.id_lieu
GROUP BY
	l.nom_lieu

SELECT 
	nbr_perso,
	nom_lieu
FROM
	persoParLieu
GROUP BY 
	nbr_perso,
	nom_lieu
ORDER BY 
	nbr_perso DESC

-- 3. Nom des personnages + spécialité + adresse et lieu d'habitation, triés par lieu puis par nom de personnage.

SELECT 
	pe.id_personnage,
	pe.nom_personnage,
	s.nom_specialite,
	pe.adresse_personnage,
	l.nom_lieu
FROM
	personnage pe
INNER JOIN lieu l ON l.id_lieu = pe.id_lieu
INNER JOIN specialite s ON s.id_specialite = pe.id_specialite
GROUP BY
	pe.id_personnage,
	pe.nom_personnage,
	s.nom_specialite,
	pe.adresse_personnage,
	l.nom_lieu
ORDER BY
	l.nom_lieu,
	pe.nom_personnage;

-- 4. Nom des spécialités avec nombre de personnages par spécialité  (trié  par  nombre  de personnagesdécroissant).

CREATE VIEW persoSpecEtLieu AS
SELECT 
	COUNT(pe.id_personnage) AS nbr_perso,
	pe.nom_personnage,
	pe.adresse_personnage,
    s.nom_specialite
FROM
	personnage pe
INNER JOIN specialite s ON s.id_specialite = pe.id_specialite
GROUP BY
	pe.nom_personnage,
	pe.adresse_personnage,
    s.nom_specialite

SELECT 
	nbr_perso,
   nom_specialite
FROM
	persoSpec
GROUP BY
	nbr_perso,
   nom_specialite
ORDER BY 
	nbr_perso DESC

-- 5. Nom,date etlieu des batailles, classées de la plus récente à la plus ancienne (dates affichées au format jj/mm/aaaa).

CREATE VIEW vueDateBataille AS
SELECT
	ba.nom_bataille,
	ba.date_bataille,
	l.nom_lieu
FROM
	bataille ba
INNER JOIN lieu l ON l.id_lieu = ba.id_lieu
GROUP BY 
	ba.nom_bataille,
	ba.date_bataille,
	l.nom_lieu

SELECT
	DATE_FORMAT(date_bataille, '%d/%m/%Y'),
	nom_lieu
FROM
	vueDateBataille
GROUP BY 
	date_bataille,
	nom_lieu
ORDER BY 
	date_bataille DESC

-- 6. Nom des potions + coût de réalisation de la potion (trié par coût décroissant).

SELECT
	po.nom_potion,
	i.cout_ingredient
FROM
	composer co
INNER JOIN potion po ON po.id_potion = co.id_potion
INNER JOIN ingredient i ON i.id_ingredient = co.id_ingredient
ORDER BY
	i.cout_ingredient DESC

-- 7. Nom des ingrédients + coût + quantité de chaque ingrédient qui composent la potion 'Santé'.

SELECT
	po.nom_potion,
	i.nom_ingredient,
	i.cout_ingredient,
	co.qte
FROM
	composer co
INNER JOIN potion po ON po.id_potion = co.id_potion
INNER JOIN ingredient i ON i.id_ingredient = co.id_ingredient
WHERE po.nom_potion LIKE '%Santé%'

-- 8. Nom du ou des personnages qui ont pris le plus de casques dans la bataille 'Bataille du village gaulois'.

CREATE VIEW casqueBataille AS
SELECT
	pe.nom_personnage,
	SUM(pc.qte) AS sommeQte,
	ba.nom_bataille
FROM
	prendre_casque pc
INNER JOIN personnage pe ON pe.id_personnage = pc.id_personnage
INNER JOIN bataille ba ON ba.id_bataille = pc.id_bataille
GROUP BY 
	pe.nom_personnage,
	ba.nom_bataille


	

-- 9. Nom des personnages et leur quantité de potion bue (en les classant du plus grand buveur au plus petit).

SELECT
	nom_personnage,
	po.nom_potion,
	bo.dose_boire
FROM
	boire bo
INNER JOIN personnage pe ON pe.id_personnage = bo.id_personnage
INNER JOIN potion po ON po.id_potion = bo.id_potion
ORDER BY 
	bo.dose_boire DESC

-- 10. Nom de la bataille où le nombre de casques pris a été le plus important.

SELECT 
nom_personnage,
nom_bataille, 
sommeQte
FROM casqueBataille
WHERE sommeQte = (SELECT MAX(sommeQte) FROM casqueBataille)

-- 11. Combien existe-t-il de casques de chaque type et quel est leur coût total ? (classés par nombre décroissant)

CREATE VIEW casqueCout AS
SELECT 
	tc.id_type_casque,
	tc.nom_type_casque,
	SUM(ca.cout_casque) AS totalCout
FROM 
	casque ca
INNER JOIN type_casque tc ON tc.id_type_casque = ca.id_type_casque
GROUP BY 
	tc.id_type_casque,
	tc.nom_type_casque

SELECT 
	totalCout,
	id_type_casque,
	nom_type_casque
FROM 
	casqueCout
ORDER BY 
	totalCout DESC

-- 12. Nom des potions dont un des ingrédients est le poisson frais.

SELECT 
	po.id_potion,
	po.nom_potion,
	i.nom_ingredient
FROM
	composer co
INNER JOIN potion po ON po.id_potion = co.id_potion
INNER JOIN ingredient i ON i.id_ingredient = co.id_ingredient
WHERE i.nom_ingredient LIKE '%Poisson frais%'

-- 13. Nom du / des lieu(x) possédant le plus d'habitants, en dehors du village gaulois.



