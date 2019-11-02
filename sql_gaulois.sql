/* 1) Nombre de gaulois par lieu (trié par nombre de gaulois décroissant) */
SELECT nom_lieu AS 'lieu', COUNT(v.id_lieu) AS nb_villageois
FROM villageois v, lieu l
WHERE v.id_lieu = l.id_lieu
GROUP BY lieu
ORDER BY nb_villageois DESC;

/* 2) Nom des gaulois + spécialité + village */
SELECT nom, nom_specialite, nom_lieu
FROM villageois v, specialite s, lieu l
WHERE v.id_lieu = l.id_lieu
AND s.id_specialite = v.id_specialite
ORDER BY nom;

/* 3) Nom des spécialités avec nombre de gaulois par spécialité (trié par nombre de gaulois décroissant) */
SELECT nom_specialite, COUNT(s.id_specialite) AS nb_gaulois
FROM specialite s, villageois v
WHERE s.id_specialite = v.id_specialite
GROUP BY nom_specialite
ORDER BY nb_gaulois DESC;

/* 4) Nom des batailles + lieu de la plus récente à la plus ancienne (dates au format jj/mm/aaaa) */
SELECT nom_bataille, nom_lieu, DATE_FORMAT(date_bataille, '%d/%m/%Y') AS date
FROM bataille b, lieu l
WHERE b.id_lieu = l.id_lieu
ORDER BY date_bataille DESC;

/* 5) Nom des potions + coût de réalisation de la potion (trié par coût décroissant) */
SELECT nom_potion, SUM(cout_ingredient*qte) AS cout
FROM potion p, ingredient i, compose c
WHERE p.id_potion = c.id_potion
AND i.id_ingredient = c.id_ingredient
GROUP BY nom_potion
ORDER BY cout DESC;

/* 6) Nom des ingrédients + coût + quantité de chaque ingrédient qui composent la potion 'Potion V' */
SELECT nom_ingredient, cout_ingredient, qte
FROM potion p, ingredient i, compose c
WHERE p.id_potion = c.id_potion
AND i.id_ingredient = c.id_ingredient
AND nom_potion = 'Potion V';

/* 7) Nom du ou des villageois qui ont pris le plus de casques dans la bataille 'Babaorum' */
SELECT nom, qte AS 'Nb de casques'
FROM villageois v, bataille b, prise_casque pc
WHERE v.id_villageois = pc.id_villageois
AND b.id_bataille = pc.id_bataille
AND nom_bataille = 'Babaorum'
AND qte IN (SELECT MAX(qte)
	FROM bataille b, prise_casque pc
	WHERE b.id_bataille = pc.id_bataille
	AND nom_bataille = 'Babaorum');

/* 8) Nom des villageois et la quantité de potion bue (en les classant du plus grand buveur au plus petit) */
SELECT nom, SUM(dose) AS quantite_dose
FROM villageois v, boit b
WHERE v.id_villageois = b.id_villageois
GROUP BY nom
ORDER BY quantite_dose DESC;

/* 9) Nom de la bataille où le nombre de casques pris a été le plus important */
SELECT nom_bataille, SUM(qte) AS nb_casquesMAX
FROM bataille b, prise_casque pc
WHERE b.id_bataille = pc.id_bataille
GROUP BY nom_bataille
ORDER BY nb_casques DESC
LIMIT 1;

-- ou 

SELECT nom_bataille, SUM(qte) AS nb_casques
FROM bataille b, prise_casque pc
WHERE b.id_bataille = pc.id_bataille
GROUP BY nom_bataille
HAVING nb_casques >= ALL(SELECT SUM(qte) 
			FROM bataille b, prise_casque pc
                   	WHERE b.ID_BATAILLE = pc.ID_BATAILLE
                      	GROUP BY nom_bataille);

/* 10) Combien existe-t-il de casques de chaque type et quel est leur coût total ? (classés par nombre décroissant) */
SELECT nom_type_casque, COUNT(*) AS nb_casques, SUM(cout_casque) AS 'cout'
FROM type_casque tc, casque c
WHERE tc.id_type_casque = c.id_type_casque
GROUP BY nom_type_casque
ORDER BY nb_casques DESC;

/* 11) Noms des potions dont un des ingrédients est la cerise */
SELECT nom_potion
FROM potion p, compose c, ingredient i
WHERE p.id_potion = c.id_potion
AND i.id_ingredient = c.id_ingredient
AND LOWER(nom_ingredient) = 'cerise';

/* 12) Nom du / des village(s) possédant le plus d'habitants */
SELECT nom_lieu, COUNT(l.id_lieu) AS nb
FROM villageois v, lieu l
WHERE v.id_lieu = l.id_lieu
GROUP BY nom_lieu
HAVING COUNT(l.id_lieu) >= ALL (SELECT COUNT(l.id_lieu) AS nb
FROM villageois v, lieu l
WHERE v.id_lieu = l.id_lieu
GROUP BY nom_lieu);

/* 13) Noms des villageois qui n'ont jamais bu de potion */
SELECT nom
FROM villageois v
WHERE v.id_villageois NOT IN (SELECT b.id_villageois
FROM boit b);

-- ou 

SELECT nom
FROM villageois v
LEFT OUTER JOIN boit b
ON v.ID_VILLAGEOIS = b.ID_VILLAGEOIS
WHERE ISNULL(dose);

/* 14) Noms des villages qui contiennent la particule 'um' */
SELECT nom_lieu
FROM lieu
WHERE nom_lieu LIKE '%um%';

/* Bonus : 3 premières lettres e majuscules des gaulois dont le nom termine par 'rix' */
SELECT LEFT(UPPER(NOM), 3)
FROM villageois
WHERE NOM LIKE '%rix';

-- ou

SELECT UPPER(LEFT(NOM,3))
FROM villageois
WHERE NOM LIKE '%rix';

/* 15) Nom du / des villageois qui n'ont pas le droit de boire la potion 'Rajeunissement II' */
SELECT nom
FROM villageois v, peut pt, potion po
WHERE v.id_villageois = pt.id_villageois
AND pt.id_potion = po.id_potion
AND po.nom_potion = 'Rajeunissement II'
AND pt.a_le_droit = 0;