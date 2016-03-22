=========
om-nomnom
=========

/!\ The lib is currently in early development, even if it's pretty stable (unit tested and used daily on dev machines),
some part of the work is missing and needs to be done.

Install
=======
npm instal om-nomnom

Get started
===========
check test/mappers-unit.js for code samples

Note that there are currently 3 mappers:
- mongo
- redis
- local (db = a javascript Object, in-memory only /!\)

7 files, each less than 100 lines, really quick to get in hands.
2 files (constants.coffee and collections.coffee) are used for data management, but are currently not used by mapper.


Dev notes
=========

I've been working with databases for a decade now, and i've been looking for the best solution to manage data in my applications (web, desktop, game, mobile, ...). By best solution, I mean:

- usable and easily ported on any lang
- simple and quick to understand/master by any developper
- flexible, so anyone take or throw any part from it and make its own
- A cool name like om-nomnom !


When I started coding my first project, I was exclusively using raw SQL to access my data.
Very soon I started using a driver to reduce code repetition of basic operation (managing connections, queries ...)

A bit later i was working on a big e-commerce engine that was using an ORM based on active record.
Working and saving directly with Object felt really awesome.
However using a querying langage for complex query ended to add a point of failure and a layer obscuring the interaction with the database.

Also, when I started getting intersted into big application with sometime scaling requirement, i started using several type of database at the same type (relational and non-relational). I also started to use more sane workflow for coding such as TDD, and trying to build package/module of logic to increase reusability of code accross projects.
From this point active record got simply out of the table. ( unit testing without a database, object get coupled to the database, non-atomic operation, ...)


At this point I started to search and think of an alternative, I read a book from martin fowler and oriented my interest toward the datamapper pattern.
No depandency to any database, simple object, theoritically pure flexibility and happiness.

I started using ruby project datamapper which really felt like a breeze,
I was able to reuse entire modules and switching database or using several databases without changing a line of code.
However, one day I had to create some complex query, and yet again I faced an obscuring querying langage the same way I did with active record in the past.
Long story short: I realized that coding a querying langage that could support all database is a really tough challenge, and keeping that querying langage up to all the database engine updates would be close to impossible.


But yeah, let's not forget the main purpose, we want to code apps, not spend our time learning/maintaining a library.

Lastly, i'd like to share a great lesson I learnt was when using key-value database (dynamodb, redis, ...).
Working with those databases felt a bit frustrating at first, because I was so used to those database with a stack of advanced features.
But very soon, I reallized that the complexity and the quantity of the code I was producing was vanishing.
(I could/should probably quote or reference Domain driven design book around here);


With that background, what do I want now ?

- simple object (POJO)
- simple mappers accepting Object or raw data
- data types validation on objects
- essential database operation -> objectMapper[create, update, find, get, incr, remove]
- using official driver for each database
