#a Find all pizzerias frequented by at least one person under the age of 18.
SELECT pizza.Frequents.pizzeria 
FROM pizza.Frequents
WHERE pizza.Frequents.name IN (SELECT pizza.Person.name FROM pizza.Person WHERE pizza.Person.age <18);

#b Find the names of all females who eat either mushroom or pepperoni pizza (or both).
WITH fem AS 
	(SELECT name
	FROM pizza.Person
	WHERE gender='female'),

mash_pep AS 
	(SELECT DISTINCT name
	FROM pizza.Eats
	WHERE pizza = 'pepperoni' OR pizza = 'mushroom')

SELECT fem.name 
FROM fem 
INNER JOIN mash_pep
ON fem.name=mash_pep.name;

#c Find the names of all females who eat both mushroom and pepperoni pizza.
WITH fem AS 
	(SELECT name
	FROM pizza.Person
	WHERE gender='female'),

mash_pep AS 
	(SELECT name, COUNT(pizza) OVER w AS variety
	FROM pizza.Eats
	WHERE pizza = 'pepperoni' OR pizza = 'mushroom'
	WINDOW w AS (PARTITION BY name
			rows between unbounded preceding and unbounded following))

SELECT DISTINCT fem.name
FROM fem 
INNER JOIN mash_pep
ON fem.name=mash_pep.name
WHERE variety = 2;

#d Find all pizzerias that serve at least one pizza that Amy eats for less than $10.00.
SELECT pizzeria
FROM pizza.Serves 
WHERE pizza IN (SELECT pizza FROM pizza.Eats WHERE name = 'Amy')
	AND price < 10;

#e Find all pizzerias that are frequented by only females or only males.
WITH pizz_gender AS 
(SELECT pizzeria, gender
FROM pizza.Frequents f
LEFT JOIN pizza.Person p
ON f.name=p.name
GROUP BY pizzeria, gender)

SELECT pizzeria, COUNT(gender) AS divers_factor
FROM pizz_gender
GROUP BY pizzeria
HAVING divers_factor = 1;


# For each person, find all pizzas the person eats that are not served by any pizzeria the person frequents. Return all such person (name) / pizza pairs.
