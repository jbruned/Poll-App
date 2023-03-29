# ADR Microservicios

* Estado: aceptada
* Responsables:
    * Unai Biurrun Villacorta
    * Jorge Bruned Alamán
    * Iñaki Velasco Rodríguez
* Fecha: 26-03-2023

# Introducción

<div style="text-align: justify!important">

En este documento se recoge la información relativa a las decisiones iniciales en cuanto a los microservicios de la
aplicación. Para cada uno de ellos se recogen decisiones en cuanto al desarrollo, consideraciones a tener en cuenta y su
funcionalidad.
</div>

## Tabla de contenidos

**TODO ACTUALIZAR**

<!--[TOC] -->
<!-- TOC -->
- [ADR Microservicios](#adr-microservicios)
- [Introducción](#introducción)
  - [Tabla de contenidos](#tabla-de-contenidos)
- [Factores en la Decisión](#factores-en-la-decisión)
- [Listado de microservicios](#listado-de-microservicios)
  - [Funcionalidad \& Alternativas en el desarrollo](#funcionalidad--alternativas-en-el-desarrollo)
  - [Base de datos](#base-de-datos)
  - [Backend](#backend)
  - [API Gateway](#api-gateway)
  - [Autorización y Autenticación](#autorización-y-autenticación)
- [Comunicación entre microservicios](#comunicación-entre-microservicios)
- [Despliegue local de los microservicios](#despliegue-local-de-los-microservicios)
- [Prueba de funcionalidad del sistema en entorno de test local](#prueba-de-funcionalidad-del-sistema-en-entorno-de-test-local)

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

Tras un análisis de las opciones disponibles en base a la arquitectura escogida para el proyecto y expuesta en
el [ADR correspondiente](Architecture.md), se han considerado los siguientes microservicios:

* Base de datos
* Backend
* API Gateway

</div>

## Funcionalidad & Alternativas en el desarrollo

## Base de datos

<div style="text-align: justify!important">

La funcionalidad de este microservicio será la de almacenar todos los datos necesarios para la aplicación referentes a
las encuestas.
La base de datos estará formada por 4 tablas y cada una de ellas contendrá la información correspondiente:

* answers: almacenará las respuestas a las opciones de las encuestas
* options: almacenará las opciones de las encuestas
* polls: almacenará las encuestas
* settings: almacenará ajustes varios, entre los cuales se encuentra el hash de la contraseña del administrador

Tal y como se define en el [RFI I](../../RFIs/RFI%20I.md) y a su vez en el [ADR de BDD](../Tech/Database.md), se hará
uso de PostgreSQL debido a sus ventajas respecto al resto de alternativas planteadas. No obstante, no será el único
servicio que utilice volúmenes para almacenar datos, ya que el servicio del API Gateway (Kong) también requerirá de
volúmenes para efectuar su labor de Logging, entre otras funciones.

</div>

## Backend

<div style="text-align: justify!important">

La funcionalidad de este servicio es servir como API para obtener y escribir los datos necesarios para su funcionamiento. Para ello, provee distintos endpoints que en base a los métodos HTTP utilizados efectúan unas acciones u otras.

Dado que se cuenta con varias colecciones Postman en la que se definen las requests que se pueden realizar, no se
explicitan los endpoints y su función en este documento.

En cualquier caso, cabe mencionar que los endpoints disponibles desde el frontend únicamente permiten hacer lo siguiente:
* Obtener las encuestas creadas (con algunos datos estadísticos)
* Obtener las opciones creadas de las encuestas creadas
* Votar a alguna de las opciones disponibles

Las opciones de crear, modificar y eliminar encuestas o votos no están disponibles desde el frontend por el momento, pero son accesibles mediante peticiones HTTP (curl, Postman, etc.)


</div>

## API Gateway

<div style="text-align: justify!important">

Por requisito de la asignatura y con objetivo de gestionar el tráfico entrante y poder gestionar la autenticación, autorización y auditoría del sistema se ha implantado un API Gateway que actuará de intermediario entre la aplicación front (o el exterior en general) y el microservicio backend.

Para ello, se ha hecho uso de Kong API Gateway, ya que permite administrar y monitorear de manera centralizada todas las API y
servicios conectados, lo que facilita la implementación y la integración de aplicaciones y sistemas.

Dado que el uso de este API Gateway en concreto venía obligado por los requisitos de la entrega, no se han considerado otras opciones. En cualquier caso, es un buen API Gateway relativamente sencillo de implementar y gratuito, por lo que resulta una buena opción.

Kong se encargará de la correcta redirección según el tipo de petición y el endpoint al que se vaya a acceder, además de
otras funcionalidades como los *logging* para auditoría.

A pesar de haber contemplado inicialmente el uso de Kong para la autorización y autenticación, finalmente no ha sido posible utilizarlo para tal efecto. Sin embargo, se ha investigado como podría implementarse en un futuro, lo que se detalla más adelante.

Dicho esto, cabe mencionar dos puntos en concreto acerca de la implementación de este microservicio:

* Logging: se ha implementado un sistema de Logging doble:
  * Por un lado, se ha empleado la configuración del contenedor de Kong para definir 4 ficheros de logs distintos para almacenar lo siguiente:
    * Accesos del administrador
    * Errores del administrador
    * Accesos al proxy inverso
    * Errores del proxy inverso
  * Por otro lado, a pesar del método de logging previo sin plugins, también se ha hecho uso del pluging [*File Log*](https://docs.konghq.com/hub/kong-inc/file-log/) que
proporciona una mayor y más completa información acerca de las peticiones. 
Estos logs se almacenan en la máquina del host por lo que, si lo
ejecuta el administrador, será él el que podrá consultarlos. 
De cara al RFI III esto será importante, ya que los ficheros generados se guardarán en el entorno Cloud en lugar de en uno de los contenedores.
En todo caso, también se ha probado a almacenar los logs en el contenedor del API Gateway, sin éxito.
* Base de datos para el API Gateway: se ha considerado su uso y de hecho ha llegado a utilizarse. No obstante, se ha decidido evitarlo y utilizar Kong en el modo *Dbless* con configuración declarativa, ya que de esta
forma, se obtienen ventajas como la reducción del número de dependencias (al no necesitar de otra base de datos, ni de
su instalación, etc) o una mayor sencillez de configuración de servicios y rutas mediante ficheros YAML.

## Autorización y Autenticación
Como se ha anticipado, no ha sido posible implementar la autorización y autenticación en el sistema mediante Kong. 
En su lugar, se ha empleado un sistema más rudimentario basado en definir un usuario administrador con una contraseña conocida por el equipo que, tras efectuar un post en el endpoint login con la contraseña adecuada, es capaz de acceder a rutas que de otro modo impedirían el acceso tras un error 401 Unauthorized.

Sin embargo, se ha investigado que habría que hacer para implementar estas funciones mediante Kong. Los resultados de esta investigación arrojan la necesidad de utilizar nuevos plugins como los siguientes:

* [Basic Authentication](https://docs.konghq.com/hub/kong-inc/basic-auth/)
* [JWT](https://docs.konghq.com/hub/kong-inc/jwt/)
* [Key Authentication](https://docs.konghq.com/hub/kong-inc/key-auth/)
* [OAuth 2.0 Authentication](https://docs.konghq.com/hub/kong-inc/oauth2/)
* [Session](https://docs.konghq.com/hub/kong-inc/session/)

De todos estos plugins JWT (Json Web Token) parece especialmente útil, ya se basa en el uso de tokens autocontenidas que no necesitan de BDD, pueden ir firmadas y, además, pueden almacenar mucha información que puede ser accesible después de decodificarlas ([Ejemplo](https://jwt.io/)). 

</div>

# Comunicación entre microservicios

<div style="text-align: justify!important">
Una vez que se han definido los microservicios, es de suma importancia decidir cómo se van a comunicar. Para ello, surgen varias ideas:

* Lanzar todos los microservicios en la misma máquina
* Lanzar todos los microservicios en la misma red pero en máquinas distintas
* Lanzar los microservicios en redes distintas

Estas opciones están ordenadas de arriba a abajo de mayor sencillez y menor seguridad a menor sencillez y mayor seguridad.

De entre todas estas opciones se ha escogido la segunda por ofrecer un balance razonable entre seguridad y sencillez. 
Además, dado que se emplea Docker en el proyecto, simplemente definiendo un Compose con distintos servicios se está emulando esta forma de comunicación: a grandes rasgos, los contenedores simulan máquinas independientes y el docker compose los situa a todos en la misma red virtual por defecto.

Bien es cierto que también podrían definirse redes diferentes dentro del Docker compose. Sin embargo, esto conlleva dificultad adicional que no es recomendable para esta entrega. Sin embargo, de cara al RFI III en el que se mostrará el sistema al mundo exterior, sí que sería interesante esta aproximación.
</div>

# Despliegue local de los microservicios
Como se ha descrito en la sección anterior, se utiliza Docker Compose para lanzar todos los microservicios. Los detalles de dicho fichero no son objeto de este documento, pero es importante ser consciente de las dependencias entre servicios.

Por ejemplo: el backend depende de la BDD, por lo que el contenedor backend deberá ejecutarse una vez aque la BDD se haya inicializado y esté lista para recibir datos.

# Prueba de funcionalidad del sistema en entorno de test local
Para probar el funcionamiento del sistema se ha elaborado un documento de instrucciones en el que se detallan los pasos a seguir para configurar todo lo necesario. 

También se ha definido un makefile para lanzar los comandos más habituales y recomendados para lanzar el sistema

Una vez que esté todo configurado y se lance el sistema, el usuario podrá acceder a la aplicación React y votar en las encuestas disponibles interactuando con la interfaz de usuario.

Al margen de ello, también es posible efectuar peticiones utilizando otras herramientas como Postman. De hecho, se ha utilizado Postman para almacenar y probar todas las peticiones que pueden realizarse al sistema. 
