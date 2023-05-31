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
	l.id_lieu,
	l.nom_lieu,
	COUNT(pe.id_personnage) AS nbr_perso
FROM
	personnage pe
INNER JOIN lieu l ON l.id_lieu = pe.id_lieu
GROUP BY
	l.id_lieu

SELECT 
	nbr_perso,
	id_lieu,
	nom_lieu
FROM
	persoParLieu
GROUP BY 
	nbr_perso,
	id_lieu
ORDER BY 
	nbr_perso DESC

-- 3. Nom des personnages + spécialité + adresse et lieu d'habitation, triés par lieu puis par nom de personnage.

SELECT 
	pe.nom_personnage,
	s.nom_specialite,
	pe.adresse_personnage,
	l.nom_lieu
FROM
	personnage pe
INNER JOIN lieu l ON l.id_lieu = pe.id_lieu
INNER JOIN specialite s ON s.id_specialite = pe.id_specialite
GROUP BY
	pe.id_personnage
ORDER BY
	l.nom_lieu,
	pe.nom_personnage;

-- 4. Nom des spécialités avec nombre de personnages par spécialité  (trié  par  nombre  de personnagesdécroissant).

CREATE VIEW persoSpecEtLieu AS
SELECT 
	COUNT(pe.id_personnage) AS nbr_perso,
	pe.nom_personnage,
	pe.adresse_personnage,
	s.id_specialite
	s.nom_specialite
FROM
	personnage pe
INNER JOIN specialite s ON s.id_specialite = pe.id_specialite
GROUP BY
	pe.id_personnage,
	pe.adresse_personnage,
   	s.nom_specialite

SELECT 
	SUM(nbr_perso) AS persoParSpec,
   	id_specialite,
	nom_specialite
FROM
	persoSpecEtLieu
GROUP BY
   	id_specialite
ORDER BY
	persoParSpec DESC

-- 5. Nom, date etlieu des batailles, classées de la plus récente à la plus ancienne (dates affichées au format jj/mm/aaaa).

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
	po.id_potion,
	po.nom_potion,
	SUM(i.cout_ingredient*co.qte) AS coutPotion
FROM
	composer co
INNER JOIN potion po ON po.id_potion = co.id_potion
INNER JOIN ingredient i ON i.id_ingredient = co.id_ingredient
GROUP BY 
	po.id_potion
ORDER BY
	coutPotion DESC

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

SELECT
	pe.id_personnage,
	pe.nom_personnage,
	SUM(pc.qte) AS sommeCasques
FROM
	prendre_casque pc
INNER JOIN personnage pe ON pe.id_personnage = pc.id_personnage
INNER JOIN bataille ba ON ba.id_bataille = pc.id_bataille
WHERE ba.nom_bataille LIKE "%Bataille du village gaulois%"
GROUP BY
	pe.id_personnage
-- On utilise un SELECT intérieur pour obtenir la valeur max d'une colonne en rapport avec une autre colonne
HAVING
	sommeCasques >= ALL
	(
		SELECT
			SUM(pc.qte) AS sommeCasquesMax
		FROM
			prendre_casque pc
		INNER JOIN bataille ba ON ba.id_bataille = pc.id_bataille
		WHERE ba.nom_bataille LIKE "%Bataille du village gaulois%"
		GROUP BY
			id_personnage
	)
ORDER BY
	sommeCasques DESC
;

-- 9. Nom des personnages et leur quantité de potion bue (en les classant du plus grand buveur au plus petit).

SELECT
	pe.id_personnage,
	pe.nom_personnage,
	SUM(bo.dose_boire) AS qttBue
FROM
	boire bo
INNER JOIN personnage pe ON pe.id_personnage = bo.id_personnage
INNER JOIN potion po ON po.id_potion = bo.id_potion
GROUP BY
	pe.id_personnage
ORDER BY 
	qttBue DESC

-- 10. Nom de la bataille où le nombre de casques pris a été le plus important.

SELECT 
ba.id_bataille,
ba.nom_bataille, 
SUM(pc.qte) AS sommeQte
FROM
	bataille ba
	INNER JOIN prendre_casque pc
	ON ba.id_bataille = pc.id_bataille 
GROUP BY ba.id_bataille
HAVING sommeQte >= ALL 
		(	
			SELECT SUM(pc.qte) 
			FROM
				bataille ba
			INNER JOIN prendre_casque pc ON ba.id_bataille = pc.id_bataille
			GROUP BY ba.id_bataille
		)

-- 11. Combien existe-t-il de casques de chaque type et quel est leur coût total ? (classés par nombre décroissant)

CREATE OR REPLACE VIEW casqueCout AS
SELECT 
	tc.id_type_casque,
	COUNT(ca.id_type_casque) AS casqueParType,
	tc.nom_type_casque,
	SUM(ca.cout_casque) AS totalCout
FROM 
	casque ca
INNER JOIN type_casque tc ON tc.id_type_casque = ca.id_type_casque
GROUP BY 
	tc.id_type_casque,
	tc.nom_type_casque
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

SELECT 
l.id_lieu,
l.nom_lieu, 
COUNT(id_personnage) AS nbrHbts
FROM
	lieu l
	INNER JOIN personnage pe ON pe.id_lieu = l.id_lieu
GROUP BY 
	l.id_lieu	
HAVING
	nbrHbts >= ALL
		(
		SELECT 
			COUNT(id_personnage)
		FROM
			lieu l
			INNER JOIN personnage pe ON pe.id_lieu = l.id_lieu										
		WHERE 
			l.nom_lieu NOT LIKE '%Village gaulois%'			
		GROUP BY 
			l.id_lieu				
		)		
AND 
	l.nom_lieu NOT LIKE  '%Village gaulois%'

-- 14 Nom des personnages qui n'ont jamais bu aucune potion.

SELECT 
	pe.nom_personnage,
	bo.dose_boire
FROM personnage pe
LEFT JOIN boire bo ON bo.id_personnage = pe.id_personnage
WHERE bo.dose_boire IS NULL
GROUP BY 
	pe.nom_personnage,
	bo.dose_boire

-- 15. Nom du / des personnages qui n'ont pas le droit de boire de la potion 'Magique'.

SELECT 
	po.nom_potion,
	abo.id_personnage,
	pe.nom_personnage
FROM 
	autoriser_boire abo
LEFT JOIN potion po ON po.id_potion = abo.id_potion
INNER JOIN personnage pe ON pe.id_personnage = abo.id_personnage
WHERE NOT po.nom_potion LIKE '%Magique%' OR abo.id_personnage IS NULL

-- A. Ajoutez le personnage suivant : Champdeblix, agriculteur résidant à la ferme Hantassion de Rotomagus.

INSERT INTO personnage (id_personnage, nom_personnage, adresse_personnage , image_personnage, id_lieu, id_specialite)
 VALUES
 (46, 'Champdeblix', 'ferme Hantassion','indisponible.jpg', 5, 12);

-- B. Autorisez Bonemine à boire de la potion magique, elle est jalouse d'Iélosubmarine...

DELETE FROM autoriser_boire
WHERE id_personnage = 12 AND id_potion = 1

INSERT INTO autoriser_boire (id_potion, id_personnage)
VALUES
(1, 12);

-- C. Supprimez les casques grecs qui n'ont jamais été pris lors d'une bataille.

DELETE FROM casque
WHERE id_type_casque = '2'
AND id_casque NOT IN
(
	SELECT 
		pc.id_casque 
	FROM prendre_casque pc
);

-- D. Modifiez l'adresse de Zérozérosix : il a été mis en prison à Condate.

UPDATE personnage
SET 
	adresse_personnage = 'Prison',
	id_lieu = 9
WHERE id_personnage = 23;

-- E. La potion 'Soupe' ne doit plus contenir de persil.

DELETE FROM composer
WHERE id_potion = 9 AND id_ingredient = 19

-- F. Obélix s'est trompé : ce sont 42 casques Weisenau, et non Ostrogoths, qu'il a pris lors de la bataille 'Attaque de la banque postale'. Corrigez son erreur !

UPDATE prendre_casque pc
SET 
	pc.id_casque = 10,
	pc.qte = 42
WHERE pc.id_bataille = 9