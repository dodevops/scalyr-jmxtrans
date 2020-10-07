# Scalyr JMX fetching

![Docker Build Status](https://img.shields.io/docker/build/dodevops/scalyr-jmxtrans) ![Docker Image Version (latest by date)](https://img.shields.io/docker/v/dodevops/scalyr-jmxtrans) ![Docker Pulls](https://img.shields.io/docker/pulls/dodevops/scalyr-jmxtrans)

## Introduction

This repository holds a Dockerized solution for fetching JMX metrics and 
transferring them to the [Scalyr Cloud](https://scalyr.com).

As Scalyr doesn't support JMX out of the box yet, this is done by fetching
JMX metrics using [JMXTRANS](http://jmxtrans.org/) and feeding them to
the Scalyr agent using the 
[Graphite relay](https://app.scalyr.com/help/data-sources#graphite) feature.

## Usage

Start your app and a container using this image as a sidecar container and 
set the following environment variables:

* JMX_PORT: The JMX port your app JVM listens to on localhost
* JMX_USERNAME: (optional) username to use when connecting 
* JMX_PASSWORD: (optional) password to use when connecting
* JMX_QUERIES: The JMX queries to run from JMXTRANS
* SCALYR_VERSION: Version of the Scalyr agent to install
* SCALYR_APIKEY: API Key to use when sending to scalyr
* SCALYR_SERVER: Scalyr Server to send logs to

## Queries

The JMX_QUERIES environment variable holds a list of queries for JMXTRANS.

It is formatted as:

* All queries are separated by |
* A query starts with the JMX bean object to query (e.g. java.lang:type=Memory)
* After the query a ; separates the query from the attributes to fetch
* The attributes are separated by , (e.g. HeapMemoryUsage,NonHeapMemoryUsage)

This will add the requested queries to the JMXTRANS configuration and write
all results to Scalyr.

The resulting metrics will have the full object class path as a key (e.g. sun_management_MemoryImpl_HeapMemoryUsage.used).
If you like to shorten that up, you can add an @ and an alias to the object name.

Please see [JMXTRANS' queries documentation](https://github.com/jmxtrans/jmxtrans/wiki/Queries) for more details.

## Example

    JMX_QUERIES=java.lang:type=Memory@memory;HeapMemoryUsage,NonHeapMemoryUsage|java.lang:type=Threading@threading;ThreadCount

Will fetch the following beans and attributes:

* java.lang:type=Memory (metrics received from this bean are prefixed with the alias "memory")
  * HeapMemoryUsage
  * NonHeapMemoryUsage
* java.lang:type=Threading (metrics received from this bean are prefixed with the alias "threading")
  * ThreadCount



