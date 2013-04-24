Overview
========

[![Build Status](https://travis-ci.org/xeger/cql-model.png?branch=master)](https://travis-ci.org/xeger/cql-model)

TODO

To-Do List
==========

## Features

* Add support for Time and other obvious Cassandra data types
* Using-keyspace override
* Declaration, read and write of set/list/map properties
* Batch mutations
* Notation for composite partition key (CompositeType), e.g. `primary_key [:id, :surname], :first_name`
* Prepared statement support for SELECT & named scopes
* Prepared statement support for INSERT/UPDATE

## Usability / Correctness / Performance

* Better solution for using and switching namespaces -- thread/fiber safety
* Better use of cql-rb connection pooling
