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


#f For each person, find all pizzas the person eats that are not served by any pizzeria the person frequents. Return all such person (name) / pizza pairs.
SELECT *
FROM pizza.Eats e 
WHERE pizza NOT IN (SELECT DISTINCT s.pizza
					FROM pizza.Frequents f 
					LEFT JOIN pizza.Serves s 
						ON f.pizzeria = s.pizzeria 
					WHERE f.name = e.name);


#g Find the names of all people who frequent only pizzerias serving at least one pizza they eat.
WITH num_pizza_per_pizzeria AS
(SELECT f.name, f.pizzeria,
	(SELECT COUNT(pizza)
	FROM pizza.Eats e 
	WHERE e.name=f.name 
		AND 
		e.pizza IN (SELECT pizza FROM pizza.Serves s WHERE s.pizzeria = f.pizzeria)
	) AS num_of_served_pizza
FROM pizza.Frequents f)

SELECT name
FROM num_pizza_per_pizzeria
GROUP BY name
HAVING MIN(num_of_served_pizza) > 0;


#h Find the names of all people who frequent every pizzeria serving at least one pizza they eat.
WITH should_be_list AS
	(SELECT name, GROUP_CONCAT(DISTINCT pizzeria ORDER BY pizzeria SEPARATOR ',') AS pizzerias_list
	FROM pizza.Serves s 
	JOIN pizza.Eats e 
	ON e.pizza=s.pizza
	GROUP BY name),

actual_list AS 
	(SELECT name, GROUP_CONCAT(DISTINCT pizzeria ORDER BY pizzeria SEPARATOR ',') AS pizzerias_list
	FROM pizza.Frequents f 
	GROUP BY name)

SELECT should_be_list.name
FROM should_be_list 
INNER JOIN actual_list 
ON should_be_list.pizzerias_list=actual_list.pizzerias_list;

#i Find the pizzeria serving the cheapest pepperoni pizza. In the case of ties, return all of the cheapest-pepperoni pizzerias
SELECT pizzeria
FROM pizza.Serves
WHERE pizza='pepperoni' AND price = (SELECT MIN(price) 
									FROM pizza.Serves
									WHERE pizza='pepperoni');
