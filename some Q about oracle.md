Why people prefer to use oracle?

People often choose Oracle Database because it has a long history of being extremely reliable, scalable, and feature-rich for large enterprise systems. However, whether it's "better" than SQL Server, PostgreSQL, or MySQL depends on the use case.



Why Organizations Choose Oracle

1\. High Reliability and Availability



Oracle is known for running critical systems that cannot afford downtime, such as:



Banks

Telecommunications companies

Airlines

Government systems



Features like Oracle RAC (Real Application Clusters) and advanced recovery tools help keep systems available even when hardware fails.



2\. Excellent Performance for Large Databases



Oracle is designed to handle:



Very large databases (terabytes to petabytes)

Thousands of concurrent users

Complex transactions and queries



Large enterprises often choose Oracle when they expect massive workloads.



3\. Strong Security Features



Oracle provides advanced security options such as:



Transparent Data Encryption (TDE)

Fine-grained access control

Data masking

Auditing



These are important for industries with strict compliance requirements.



4\. Advanced Enterprise Features



Oracle includes many built-in features:



Partitioning

Materialized views

Advanced replication

Data Guard (disaster recovery)

RAC (clustering)

Flashback technology (recovering data from mistakes)



Many of these features are highly valued in enterprise environments.



5\. Strong PL/SQL Language



Oracle's procedural language, PL/SQL, is powerful for:



Stored procedures

Functions

Packages

Triggers



>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.

###### \-what's triggers?



A Trigger is a special type of stored program that automatically executes when a specific event occurs on a table or view.



You don't run a trigger manually. SQL Server or Oracle runs it automatically when an event happens.



\------------------------

In the SQL server when want to delete the parent table and child table related to it there is cases : set null(child), no action , CASCADE and set by default.



What's CASCADE case:

CASCADE in SQL Server (ON DELETE CASCADE)

CASCADE means that when a parent row is deleted, SQL Server automatically deletes all related child rows that reference it.



Parent row deleted

&#x20;      ↓

All related child rows deleted automatically

-------------------------


###### **Every column in DB have domain (range and data type) so in oracle the data type:**



###### **Character Types:**



**CHAR(n)	Fixed-length      character string**

**VARCHAR2(n)	          Variable-length character string**

**NCHAR(n)	          Fixed-length Unicode string**

**NVARCHAR2(n)	          Variable-length Unicode string**

**CLOB	                  Large character data**



###### **Date and Time Types:**



**DATE	                  Date and time (to seconds)**

**TIMESTAMP	          Date and time with fractional seconds**

**TIMESTAMP                 WITH TIME ZONE	Timestamp plus timezone**

**INTERVAL                  YEAR TO MONTH	Time interval**

**INTERVAL                  DAY TO SECOND	Time interval**



###### **Binary Types:**



**RAW(n)	                 Binary data**

**LONG RAW               	Large binary data**

**BLOB	                 Binary large object**

