The key idea of this task is to create a request from the item table.
We want to show, which items can satisfy our wish. Our wish is formulated as the needed quantity of one item.  
For example, we want to show a list of ids with the following requirements: article = A030001, total quantity = 2.5.
Total quantity can be a natural number or a natural number with half, including 0.5.

The algorithm of choosing items is the following:
1) The quantity is natural -> choose only items with natural volume,
2) The quantity is natural + 0.5 -> choose 1 item with the volume of 0.5, 1.5 etc + items with natural volumes.
If it's not possible, we can combine halves.

Item status should equal 0, which means, that this item isn't reserved.

The note about my solution. I wanted to create a procedure to execute this request properly. Unfortunately, this user role isn't allowed to create its own procedure. I've exported the item table to my local host and changed the name of the database to my own one. That's why my script isn't using the srv43968_test database, but my own.

**Credentials to connect to the database:**

server (host): mysql-srv43968.hts.ru

user: srv43968_test

password: test01

port: 3306

database: srv43968_test

**The request to update:**

    SELECT
    FROM items i
    WHERE i.STATUS = 0
      AND i.ARTICLE = 'A030001'

The detailed description can be found [here](https://youtu.be/HX1ja1WWcc8)
