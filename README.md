# README

# Database Setup

    We will be using `electron_user` as our database user for
    development. To create the user, run the following as database `root`.

    ```shell
    mysql -u root -p
    ```

    In the terminal, run the following:

    ```sql
    GRANT ALL PRIVILEGES ON *.* TO 'electron_user'@'localhost' IDENTIFIED BY 'electron';
    ```

    To exit, run the following or press `Ctrl-C Ctrl-C` or the like:

    ```sql
    \q
    ```

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
