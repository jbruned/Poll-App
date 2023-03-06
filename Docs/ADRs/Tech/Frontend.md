# ADR Backend<!-- omit from toc -->

* Estado: aceptada
* Responsables:
  * Unai Biurrun Villacorta
  * Jorge Bruned Alamán
  * Iñaki Velasco Rodríguez
* Fecha: 28-02-2023

# Introducción
<div style="text-align: justify!important">

En este documento se recoge la información relativa a las decisiones iniciales en cuanto a la tecnología Backend que se utilizará en el proyecto. 
Para cada decisión, se listan las opciones consideradas junto a una breve descripción, ventajas y contras, así como la decisión final tomada.
</div>

## Tabla de contenidos

<!-- [TOC] -->
- [Introducción](#introducción)
  - [Tabla de contenidos](#tabla-de-contenidos)
- [Factores en la decisión](#factores-en-la-decisión)
- [Opciones consideradas](#opciones-consideradas)
  - [Java](#java)
  - [.NET](#net)
  - [Python + Flask](#python--flask)
- [Decisión](#decisión)
- [Referencias](#referencias)

# Factores en la decisión
<div style="text-align: justify!important">

Para tomar la decisión se han priorizado los siguientes factores:
* Conocimiento existente en el equipo
* Sencillez
* Popularidad
</div>

# Opciones consideradas
<div style="text-align: justify!important">

Tras un análisis de las opciones disponibles actualmente, se han valorado las siguientes:
* Java
* .NET
* Python + Flask
</div>

## Java
<div style="text-align: justify!important">

Mundialmente conocido y utilizado, [Java](https://www.java.com/es/) es una de las tecnologías más habituales para el desarrollo de aplicaciones de todo tipo. 

Las ventajas que ofrece para nuestro proyecto son las siguientes:

* Todos los miembros del equipo poseen conocimientos sobre esta tecnología, a nivel académico.
* Es una tecnología asentada en el mercado, con lo que hay muchos recursos para documentarse, mucho soporte, etc.
* Es un lenguaje Orientado a Objetos, con lo que es mantenible.
* Herramientas de desarrollo gratuitas disponibles.

En cuanto a las desventajas, destacan las siguientes:
* No es muy rápido.
* Generalmente, presenta mucho boilerplate, lo que no agrada a los miembros del equipo, ya que se requiere de más líneas de código (y por tanto tiempo) para lograr lo mismo
* Pese a contar con experiencia, los miembros del equipo tienen más experiencia con otras tecnologías.
* Las herramientas de desarrollo no nos resultan especialmente agradables.

En general, es una tecnología que encontramos más adecuada para proyectos más grandes. Dado el reducido tamaño de nuestro proyecto, parece que habría tecnologías más adecuadas.
  
</div>

## .NET
<div style="text-align: justify!important">

Otra de las tecnologías más populares, de la mano de Microsoft. Tiene muchas posibilidades, al igual que Java.

Las ventajas que ofrece para nuestro proyecto son las siguientes:
* Algunos miembros del equipo poseen conocimiento previo del ecosistema [.NET](https://dotnet.microsoft.com/es-es/), a nivel profesional.
* Es popular, con lo que, de forma similar a Java, existen muchos recursos para documentarse al respecto.
* El ecosistema de trabajo y las herramientas (Visual Studio, NuGet, etc.) es francamente cómodo de utilizar en base a la experiencia previa de algunos miembros del equipo.
* Herramientas de desarrollo gratuitas disponibles.

En cuanto a las desventajas, destacan las siguientes:

* No todos los miembros del equipo tienen experiencia con esta tecnología.
* Es una tecnología grande y cuya posibilidad de despliegue se intuye más compleja que en otros casos. Debido al alcance del proyecto, se piensa que habría opciones más sencillas y eficientes de acuerdo a nuestro tiempo de desarrollo disponible.

En general, es una tecnología que encontramos más adecuada para proyectos más grandes, pero la elegiríamos antes que Java por su ecosistema de trabajo. Dado el reducido tamaño de nuestro proyecto, parece que habría tecnologías más adecuadas.
  
</div>

## Python + Flask
<div style="text-align: justify!important">

La combinación de [Python](https://www.python.org/downloads/) y [Flask](https://flask.palletsprojects.com/en/2.2.x/) es una de las opciones disponibles para el desarrollo de aplicaciones web con Python, uno de los lenguajes de programación más populares.

Las ventajas que ofrece para nuestro proyecto son las siguientes:
* Todos los miembros del equipo poseen un conocimiento amplio de Python a nivel educativo e incluso a nivel profesional.
* Python es un lenguaje sencillo y con poco boilerplate, con lo que se intuye que el desarrollo será más rápido y el despliegue más fácil.
* Al igual que el resto de tecnologías consideradas, Python es muy popular y Flask también, aunque en menor medida (al ser más específica).
* Herramientas de desarrollo gratuitas disponibles. Incluso herramientas de pago como PyCharm (gracias a nuestra condición de estudiantes).
* El personal docente puede guiarnos en caso de requerirlo sin problemas.

En cuanto a las desventajas, destacan las siguientes:
* No todo el equipo posee conocimientos de Flask
* Posible dificultad para separar el código de instanciación de BBDD y servidor web al ir los paquetes ya integrados con un cierto nivel de acoplación entre ambos

En definitiva, consideramos que dada su sencillez y el conocimiento de Python del qye ya disponemos, la combinación de Python y Flask es ideal para un proyecto de la envergadura del nuestro.
</div>


# Decisión
<div style="text-align: justify!important">

De entre todas las opciones barajadas y descritas previamente, finalmente se ha optado por utilizar Python y Flask para el desarrollo, dada su sencillez, principalmente.

El proyecto no es muy grande y consideramos que lo más interesante del mismo en relación con la asignatura es su arquitectura y su despliegue. Por tanto, cuanto menos tiempo sea necesario invertir en otros elementos, habrá más tiempo disponible para profundizar en estos aspectos. 
</div>

# Referencias<!-- opcional -->
<div style="text-align: justify!important">

* [Java](https://www.java.com/es/)
* [.NET](https://dotnet.microsoft.com/es-es/)
* [Python](https://www.python.org/downloads/)
* [Flask](https://flask.palletsprojects.com/en/2.2.x/)

</div>