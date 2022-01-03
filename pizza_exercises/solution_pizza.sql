#a
SELECT pizza.Frequents.pizzeria 
FROM pizza.Frequents
WHERE pizza.Frequents.name IN (SELECT pizza.Person.name FROM pizza.Person WHERE pizza.Person.age <18);

#b
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

#c
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

