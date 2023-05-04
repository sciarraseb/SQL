#Date: 2021/02/17

setwd('~/Desktop/Datacamp/SQL')

library(easypackages)
packages <- c('readr', 'tidyverse', 'RSQLite', 'dbplyr', 'DBI', 'odbc', 'RMySQL')
libraries(packages)


# Part 1: Transfer tables from SQLite file to MySQL database-----------------------------------------
#connect to SQLite RDBMS
conn_sqlite <- dbConnect(RSQLite::SQLite(), 'professor_data/unitransparenz.sqlite')

#MySQL database management system
conn_mysql <- dbConnect(drv = MySQL(), user = 'root', port = 3306, dbname = 'information_schema', password = 'tiramisu')

#view tables in SQLite database 
table_names_sqlite <- dbListTables(conn = conn_sqlite)

#transfer each table to MySQL (note this requiers allowing MySQL database to accept local files  [SET GLOBAL local_infile = true;])
for (table_name in table_names_sqlite) {
  #load table into temporary dataframe
  df_temp <- dbReadTable(conn = conn_sqlite, name = table_name) 
  
  #write table into MySQL database (on hard disk)
  dbWriteTable(conn = conn_mysql, name = table_name, value = df_temp, append = F, overwrite=T)
}

dbListTables(conn = conn_mysql)
dbListFields(conn = conn_mysql, name = 'SCHEMA_PRIVILEGES')
dbGetQuery(conn_mysql, "SELECT * FROM PARTITIONS LIMIT 20")


#shows databases
dbGetQuery(conn_mysql, "show databases")

#
dbGetQuery(conn = conn_mysql, statement = "SELECT column_name, data_type  FROM information_schema.columns WHERE table_name = 'Anstellung'")









#we can also add databases to the SQL database 
car <- c('Camaro', 'California', 'Mustang', 'Explorer')
make <- c('Chevrolet','Ferrari','Ford','Ford')
df1 <- data.frame(car,make)

car <- c('Corolla', 'Lancer', 'Sportage', 'XE')
make <- c('Toyota','Mitsubishi','Kia','Jaguar')
df2 <- data.frame(car,make)

# Add them to a list
dfList <- list(df1,df2)
# Write a table by appending the data frames inside the list
for(k in 1:length(dfList)){
  dbWriteTable(conn,"Cars_and_Makes", dfList[[k]], append = TRUE)
}

# List all the Tables
dbListTables(conn)

#let's now query the database to access specific datasets 
dbGetQuery(conn, "SELECT * FROM cars_data LIMIT 10")



# Part 2. SQL database management ----------------------------------------------
##2.1) Basic functions for inspecting SQL database 
#list data sets or fields 
dbListTables(conn = conn)

#view column names in a field 
dbListFields(conn = conn, name = "cars_data")

#view first rows of data set
(dbReadTable(conn = conn, name = 'cars_data')) #OR
dbGetQuery(conn, "select * from cars_data limit 5")


##2.2) Basic queries for extracting data from fields using SQL and dbplyr 
#load cars_data into R object to enable later dbplyr queries 
cars <- dbReadTable(conn = conn, name = 'cars_data')

#view first few rows using SQL and dbplyr 
dbGetQuery(conn, "SELECT * FROM cars_data LIMIT 5")
cars %>% head(n = 5)

#check whether query has been completed 
query_5 <- dbSendQuery(conn, "select * from cars_data limit 5")
dbFetch(query_5)

dbHasCompleted(query_5) #returns TRUE after the query has been fetched 

#get info on query 
dbGetInfo(query_5)

#view latest query 
dbGetStatement(query_5)

#get column info (equivalent of glimpse())
dbColumnInfo(query_5)

#disconnect so that no computer processing power is unnecessarily used
dbDisconnect(conn)


# Part 3: Basic SQL commands ----------------------------------------------
#the following commands must be listed in the following order: SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY
#select distinct values from a column. Can be applied to any data type (numeric, character, factor)
dbGetQuery(conn = conn, statement = 'SELECT DISTINCT gear FROM cars_data')

#determine the number of rows in a table 
dbGetQuery(conn = conn, statement = 'SELECT COUNT(DISTINCT gear) FROM cars_data') #3 different values 
dbGetQuery(conn = conn, statement = 'SELECT COUNT (*) FROM cars_data') #32 rows in entire data set 

dbGetQuery(conn = conn, statement = "SELECT * FROM cars_data LIMIT 5")


#filtering for rows
dbGetQuery(conn = conn, "SELECT car_names FROM cars_data WHERE car_names = 'Mazda RX4' AND cyl = 6")
dbGetQuery(conn = conn, "SELECT COUNT(*) FROM cars_data WHERE car_names IS NULL") #no rows have missing values of var_names
dbGetQuery(conn = conn, "SELECT * FROM cars_data WHERE car_names LIKE 'M%'") #selects rows where car name begins with and M; not case sensitive 
dbGetQuery(conn = conn, "SELECT * FROM cars_data WHERE car_names LIKE '_a%'") #selects rows where car name begins with any letter and has a second letter as 'a' 

#aggregate functions 
dbGetQuery(conn = conn, "SELECT AVG(mpg) FROM cars_data")
dbGetQuery(conn = conn, "SELECT MAX(mpg) FROM cars_data")
dbGetQuery(conn = conn, "SELECT SUM(mpg) FROM cars_data")

#aliasing can be used to change variable names within the query 
dbGetQuery(conn = conn, "SELECT MAX(mpg) AS max_mpg FROM cars_data")
dbGetQuery(conn = conn, "SELECT MAX(mpg) - MIN(mpg) AS mpg_range FROM cars_data")

#use ORDER BY to arrange order of rows in either ascending or descending order of some variable(s)
dbGetQuery(conn = conn, "SELECT * FROM cars_data ORDER BY mpg, cyl DESC")

#use GROUP BY to organize output according to a category. Useful for counting number of values in each category 
dbGetQuery(conn = conn, "SELECT cyl, gear, COUNT(*) FROM cars_data GROUP BY cyl, gear")

#use HAVING to filter records based on aggregate functions 
dbGetQuery(conn = conn, "SELECT cyl, gear, COUNT(*) FROM cars_data GROUP BY cyl, gear HAVING COUNT(*) > 2")


# Part 4: Joining data sts ------------------------------------------------

my_db <- src_sqlite(path = "my_test_db.sqlite3", create = T)
db_faithful <- copy_to(dest = my_db, faithful, temporary = F)

explain(db_faithful)
tbl

RSiteSearch(string = 'mixture', restrict = 'functions')
