The key idea of this task is to optimize the request so that it can be
operated much quicker.

This request should provide the list of all containers, which are ready
to be transported. We are working with two tables - boxes and
containers. The box table contains the list of all boxes- their number,
number of the corresponding container, the number of a new container (if
it's applicable) if the box is reserved, and so on.

A container is ready to be transported if:
* its status is 0,
* sum of width * height * length of all boxes inside > 500 K

Boxes to be included in the calculation:
* ID_STOCK = 1
* STATUS = 0
* NN_REZERV = 0

**Credentials to connect to the database:**

server (host): mysql-srv43968.hts.ru

user: srv43968_test

password: test01

port: 3306

database: srv43968_test

**The request to optimize:**

    SELECT *
    FROM containers c
    WHERE c.STATUS = 0
      AND (select sum(width* height * length/10000) 
          from boxes b 
          where
            ((b.ID_CONTAINER = c.ID and b.ID_CONTAINER_MOVE = 0) 
              OR
              (b.ID_CONTAINER_MOVE = c.ID)) 
            and b.ID_STOCK = 1 
            and b.STATUS = 0 
            and b.NN_REZERV = 0) > 50

The detailed description can be found [here](https://www.youtube.com/watch?v=pmkBZmgkdss)
