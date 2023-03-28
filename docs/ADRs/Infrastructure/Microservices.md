# ADR Microservicios

* Estado: **comenzada**
* Responsables:
    * Unai Biurrun Villacorta
    * Jorge Bruned Alamán
    * Iñaki Velasco Rodríguez
* Fecha: 26-03-2023

# Introducción

<div style="text-align: justify!important">

En este documento se recoge la información relativa a las decisiones iniciales en cuanto a los microservicios de la aplicación. Para cada uno de ellos se recogen decisiones en cuanto al desarrollo, consideraciones a tener en cuenta y su funcionalidad.
</div>

## Tabla de contenidos

**TODO ACTUALIZAR**

<!--[TOC] -->
<!-- TOC -->

* [ADR **TODO**](#adr-todo)
* [Introducción](#introducción)
    * [Tabla de contenidos](#tabla-de-contenidos)
* [Factores en la Decisión](#factores-en-la-decisión)
* [Opciones Consideradas](#opciones-consideradas)
    * [Ventajas y Desventajas de las opciones](#ventajas-y-desventajas-de-las-opciones)
    * [[opción 1]](#opción-1)
    * [[opción 2]](#opción-2)
    * [[opción 3]](#opción-3)
* [Decisión](#decisión)
* [Enlaces <!-- opcional -->](#enlaces----opcional---)

<!-- TOC -->

# Factores en la Decisión

<div style="text-align: justify!important">

Para cada microservicio y su desarrollo se han tenido en cuenta factores como:

* ¿Requisito del cliente?
* Conocimiento existente en el equipo
* Sencillez
* Popularidad
* Eficiencia
* Escalabilidad
* Consideraciones en vista al RFI III

</div>

# Listado de microservicios

<div style="text-align: justify!important">

Tras un análisis de las opciones disponibles actualmente, se han valorado las siguientes:

* Base de datos
* Backend
* API Gateway

</div>

## Funcionalidad & Alternativas en el desarrollo

## Base de datos

<div style="text-align: justify!important">

La funcionalidad de este microservicio será la de almacenar todos los datos necesarios para la aplicación referentes a las encuestas.
La base de datos estará formada por 4 tablas y cada una de ellas contendrá la información correspondiente:
* answers
* options
* polls
* settings

Tal y como se define en el RFI I, se hará uso de PostgreSQL debido a sus ventajas respecto al resto de alternativas planteadas. Será el único servicio que hará uso de volúmenes para persistir sus datos.

</div>

## Backend

<div style="text-align: justify!important">

**TODO**
[ejemplo | descripción | puntero a más información [URL | doc anexo al ADR ] | …] <!-- opcional -->

* Positivo, porque [argumento a]
* Positivo, porque [argumento b]
* Negativo, porque [argumento c]
* …

</div>

## API Gateway

<div style="text-align: justify!important">

Se ha hecho uso de Kong API Gateway, ya que permite administrar y monitorear de manera centralizada todas las API y servicios conectados, lo que facilita la implementación y la integración de aplicaciones y sistemas. 
Se encargará de la correcta redirección según el tipo de petición y el endpoint al que se vaya a acceder, además de otras funcionalidades como los *logging* para auditoría.
Cabe mencionar dos puntos en concretos acerca de este microservicio:

* Logging: a pesar de que se ha conseguido desarrollar un método de logging que no requiere de elementos adicionales como plugings, finalmente se ha hecho uso del pluging [*File Log*](https://docs.konghq.com/hub/kong-inc/file-log/) que proporciona una mayor y más completa información. Estos logs se almacenan en la máquina del host por lo que, si lo ejecuta el administrador, será él el que podrá consultarlos.
* Base de datos para el API Gateway: se ha considerado su uso. No obstante, se ha decidido evitarlo ya que, de esta forma, se obtenían ventajas como la reducción del número de dependencias (al no necesitar de otra base de datos, ni de su instalación, etc) o una mayor sencillez de configuración de servicios y rutas mediante ficheros YAML.

</div>

# Decisión

<div style="text-align: justify!important">

De entre todas las opciones barajadas y descritas previamente, finalmente se ha optado por la opción ___
**TODO** igual se puede sustituir este apartado por una especie de conclusión
</div>

# Enlaces <!-- opcional -->

<div style="text-align: justify!important">

* [Link type] (InsertarLink)

</div>
