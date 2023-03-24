# ADR Base de Datos<!-- omit from toc -->

* Estado: aceptada
* Responsables:
  * Unai Biurrun Villacorta
  * Jorge Bruned Alamán
  * Iñaki Velasco Rodríguez
* Fecha: 28-02-2023

# Introducción
<div style="text-align: justify!important">

En este documento se recoge la información relativa a las decisiones iniciales en cuanto a la tecnología de Base de Datos que se utilizará en el proyecto. 
Para cada decisión, se listan las opciones consideradas junto a una breve descripción, ventajas y contras, así como la decisión final tomada.
</div>

## Tabla de contenidos

<!-- [TOC] -->
- [Introducción](#introducción)
  - [Tabla de contenidos](#tabla-de-contenidos)
- [Factores en la decisión](#factores-en-la-decisión)
- [Opciones consideradas](#opciones-consideradas)
  - [SQLite](#sqlite)
  - [Oracle Database Express Edition](#oracle-database-express-edition)
  - [PostgreSQL](#postgresql)
- [Decisión](#decisión)
- [Referencias](#referencias)


# Factores en la decisión
<div style="text-align: justify!important">

Para tomar la decisión se han priorizado los siguientes factores:
* Conocimiento existente en el equipo
* Sencillez
* Posibilidades de despliegue
</div>

# Opciones consideradas
<div style="text-align: justify!important">

Tras un análisis de las opciones disponibles actualmente, se han valorado las siguientes:
* SQLite
* Oracle Database Express Edition
* PostgreSQL
</div>

## SQLite
<div style="text-align: justify!important">

[SQLite](https://www.sqlite.org/index.html) es una opción habitual para proyectos pequeños y sencillos. A priori, podría parecer ideal para nuestro proyecto

Las ventajas que ofrece para nuestro proyecto son las siguientes:

* SQLite es muy sencillo de utilizar, debido a que las BDDs se escriben en ficheros directamente.
* Es una tecnología popular.
* Instalado por defecto con Python.

No obstante, presenta algunas desventajas para este proyecto:
* Al tratarse de BDDs en ficheros convencionales, se intuye que el despliegue no va a ser tan sencillo y por tanto choca con la asignatura. De hecho, en la propia página web de SQLite se indica que no intenta competir con BDDs cliente/servidor, que es una de las características de nuestro proyecto.
* En el equipo no se ha trabajado previamente con esta BDD, aunque dada su sencillez no supone un problema.

En general, es una tecnología ideal para proyectos pequeños, sí, pero la consideramos más adecuada para proyectos locales o proyectos en los que el interés principal no sea su despliegue.
</div>

## Oracle Database Express Edition
<div style="text-align: justify!important">

[Oracle Database Express Edition](https://www.oracle.com/es/database/technologies/appdev/xe.html), BDD de Oracle, es una versión gratuita de la BDD estándar de Oracle.

Las ventajas que ofrece para nuestro proyecto son las siguientes:
* Todos los miembros del equipo han utilizado Oracle XE durante los estudios de grado de forma ocasional.
* Es una BDD gratuita (con versiones de pago) y popular.

En cuanto a las desventajas, destacan las siguientes:

* Pese a que todos los miembros del equipo conocen la BDD, el conocimiento disponible no es muy alto.
* Su instalación puede resultar algo compleja.
* Es gratuita, pero con [funcionalidad limitada](https://soyundba.com/2021/05/19/diferencias-entre-enterprise-standard-standard-one-personal-y-express/) por existir versiones superiores de pago.

Debido a su instalación y a que cumple el mismo papel que otras BDD más sencillas de instalar y con más funcionalidad, no parece la opción ideal.
  
</div>

## PostgreSQL
<div style="text-align: justify!important">

[PostgreSQL](https://www.postgresql.org/) es una BDD Open Source muy popular y ampliamente utilizada.

Las ventajas que ofrece para nuestro proyecto son las siguientes:
* Algunos de los miembros del equipo poseen conocimiento profesional sobre la BDD y la han integrado con Python y SQLAlchemy, sistema ORM para Python (que es la tecnología back elegida en el proyecto).
* Es una BDD Open Source y completamente gratuita, con lo que no está limitada de ningún modo, a diferencia de BDDs como Oracle XE.
* La instalación es más sencilla que Oracle XE.
* Es una BDD tradicional y popular, con lo que su despliegue será posible de muchas formas. Dado que se desconoce el método exacto con el que se hará este proceso, es muy interesante que existan muchas opciones. De hecho, gracias a GitHub Student, puede utilizarse junto a [Heroku](https://www.heroku.com/github-students), si fuera necesario.

En cuanto a las desventajas, destacan las siguientes:
* La instalación no es tan sencilla como SQLite.
* No todo el equipo conoce la BDD, pero al ser SQL no supone un problema, pues todo el equipo conoce SQL.

Dada su naturaleza de BDD tradicional y al tratarse de un producto gratuito y con funcionalidad completa, será posible cumplir los requisitos del proyecto de forma total. 


# Decisión
<div style="text-align: justify!important">

 De entre todas las opciones barajadas y descritas previamente, finalmente se ha optado por utilizar PostgreSQL.

 Es una BDD tradicional, con lo que el despliegue será posible sin quebraderos de cabeza, es gratuita y es SQL (por lo que todo el equipo será capaz de manejarla más pronto que tarde)
</div>

# Referencias<!-- opcional -->
<div style="text-align: justify!important">

* [SQLite](https://www.sqlite.org/index.html)
* [Oracle Database Express Edition](https://www.oracle.com/es/database/technologies/appdev/xe.html)
* [PostgreSQL](https://www.postgresql.org/)

</div>