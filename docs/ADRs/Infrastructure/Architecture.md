# ADR Arquitectura

* Estado: aceptada
* Responsables:
    * Unai Biurrun Villacorta
    * Jorge Bruned Alamán
    * Iñaki Velasco Rodríguez
* Fecha: 24-03-2023

# Introducción

<div style="text-align: justify!important">

En este documento se recoge la información relativa a las decisiones iniciales en cuanto a la arquitectura del sistema.
Para cada decisión,
se listan las opciones consideradas junto a una breve descripción, ventajas y contras, así como la decisión final
tomada.
</div>

## Tabla de contenidos

<!--[TOC] -->
<!-- TOC -->

* [ADR Arquitectura](#adr-arquitectura)
* [Introducción](#introducción)
    * [Tabla de contenidos](#tabla-de-contenidos)
* [Factores en la Decisión](#factores-en-la-decisión)
* [Opciones Consideradas](#opciones-consideradas)
    * [Arquitectura basada en microservicios](#arquitectura-basada-en-microservicios)
    * [Arquitectura de 3 capas](#arquitecura-de-3-capas)
    * [Arquitectura de 2 capas](#arquitectura-de-2-capas)
* [Decisión](#decisión)

<!-- TOC -->

# Factores en la Decisión

<div style="text-align: justify!important">

Para tomar la decisión se han priorizado los siguientes factores:

* ¿Requisito del cliente?
* Desacoplamiento/modularidad
* Escalabilidad
* Sencillez de implementación

</div>

# Opciones Consideradas

<div style="text-align: justify!important">

Tras un análisis de distintas arquitecturas, se han valorado las siguientes:

* Arquitectura basada en microservicios
* Arquitectura de 3 capas
* Arquitectura de 2 capas

</div>

## Arquitectura basada en microservicios

<div style="text-align: justify!important">

La arquitectura basada en microservicios es una de las arquitecturas más populares actualmente.
Se basa en la idea de que cada servicio es independiente y se comunica con los demás a través de una API.
Esto permite que cada servicio pueda ser desarrollado por un equipo diferente, y que cada servicio pueda ser desplegado
de forma independiente. Además, permite que cada servicio pueda ser reemplazado por otro sin que afecte al resto de
servicios.

Esta arquitectura tiene varias ventajas. Algunas de ellas son:

* Escalabilidad: Se puede escalar cada servicio de forma independiente. Esto permite que, por ejemplo, si un servicio
  tiene un pico de tráfico, se pueda escalar de modo independiente al resto de servicios, sin que ello les afecte.
* Agilidad: resulta más fácil gestionar los errores y las distintas versiones de los servicios, ya que cada servicio
  es independiente. Así, es posible modificar de forma individualizada cada servicio en base a las necesidades del
  cliente sin tener que interrumpir toda la aplicación.
* Aislamiento: se aíslan los datos y los errores, con lo que se facilitan los cambios en el esquema de datos y se
  facilita la detección de errores. Eso sí, los servicios dependientes deben poder gestionar los errores de forma
  adecuada.
* Desacoplamiento: al separar los servicios, se consigue un mayor desacoplamiento entre ellos, lo que facilita la
  integración de nuevos servicios y la reutilización de los existentes.

Por otro lado, esta arquitectura tiene algunas desventajas. Algunas de ellas son:

* Complejidad: al tener que gestionar la comunicación entre los distintos servicios, la arquitectura se vuelve más
  compleja. Al hilo de ello, surgen desafíos como mantener la integridad de los datos o integrar diferentes lenguajes y
  tecnologías que podrían usarse en una misma aplicación.
* Lentitud en el desarrollo: dado que cada servicio necesita un sistema de comunicación propio, el desarrollo de la
  aplicación puede resultar más lento, sobre todo al principio.
* Congestión de la red: al separar los servicios, se puede producir una congestión de la red, ya que cada servicio
  necesita comunicarse con los demás. Esto puede ser especialmente problemático si los servicios se encuentran en
  distintas máquinas.

Al margen de lo descrito previamente, cabe destacar que los microservicios son prácticamente obligados en la asignatura,
ya que se requiere el uso de Docker, entre otros requisitos. Por otro lado, la asignatura requiere el uso de APIs y API
Gateways, con lo que el uso de esta arquitectura es casi obligado.
</div>

## Arquitectura de 3 capas

<div style="text-align: justify!important">

La arquitectura de 3 capas es una arquitectura clásica y muy utilizada que se basa en la separación de la aplicación en
3 partes o capas: la capa de presentación, la capa de lógica de negocio y la capa de acceso a datos. Esta arquitectura
es muy empleada en aplicaciones web, ya que permite separar la lógica de negocio de la interfaz de usuario, lo que
facilita la reutilización de la lógica de negocio en distintas aplicaciones.
Esta arquitectura podría considerarse una especialización de la arquitectura de N capas. Además, suele considerarse
monolítica.

La arquitectura de 3 capas tiene varias ventajas. Algunas de ellas son:

* Reutilización: al separar la lógica de negocio de la interfaz de usuario, se facilita la reutilización de la lógica de
  negocio en distintas aplicaciones. Sin embargo, su grado de reutilización es más limitado que en el caso de la
  arquitectura de microservicios, ya que al tratarse de una arquitectura monolítica hay acoplamiento.
* Simplicidad: en general, la arquitectura de 3 capas es más sencilla de implementar que la arquitectura de
  microservicios, en especial debido a la compleja comunicación que puede darse entre microservicios. Esto trae consigo
  una mayor velocidad de desarrollo.
* Ahorro de costes operacionales y de desplielgue: al tratarse de una arquitectura monolítica, no hay que contar con el
  sobrecoste de mantener múltiples servicios.

Sin embargo, también tiene algunas desventajas. He aquí algunas de ellas:

* Acoplamiento: al tratarse de una arquitectura monolítica, hay acoplamiento entre las distintas capas. Esto puede
  dificultar la reutilización de los componentes en otras aplicaciones o la incorporación de nuevos elementos.
* Escalabilidad: al tratarse de una arquitectura monolítica, no es posible escalar de forma independiente y horizontal
  cada capa, a diferencia de la arquitectura de microservicios.
* Adaptabilidad o agilidad: nuevamente, debido a la naturaleza monolítica de la arquitectura, puede resultar más
  complejo reaccionar a un cambio de necesidades del cliente o del entorno.

En cualquier caso, el concepto de las capas puede resultar de utilidad a la hora de decidir los microservicios que se
van a implementar. Por ejemplo, podría establecerse un microservicio de BDD, que es una de las capas en la arquitectura
de 3 capas.
</div>

## Arquitectura de 2 capas

<div style="text-align: justify!important">

La arquitectura de 2 capas es una variante de la arquitectura de N-capas más sencilla y acoplada que la arquitectura de
3 capas. En este caso, únicamente se distinguen dos componentes: el cliente y el servidor. La que era la capa de negocio
se integra en el cliente y/o en el servidor, ocultando dicha capa.

En general, podría decirse que comparte las ventajas similares que la arquitectura de 3 capas, pero con un menor
potencial de reutilización de sus componentes. Esto es, la simplicidad que caracterizaba la arquitectura de 3 capas se
acentúa todavía más.

Todo ello tiene un precio: las desventajas de la arquitectura de 3 capas se potencian y, como se ha anticipado,
disminuye el potencial de reutilización de los componentes.

</div>

# Decisión

<div style="text-align: justify!important">

De entre todas las opciones barajadas y descritas previamente, se ha optado por la arquitectura basada en
microservicios, debido a que es un requisito de la asignatura y a que aporta una modularidad, escalabilidad y
desacoplamiento superiores.

Una vez elegida la arquitectura, conviene especificar que componentes va a tener, sobre todo en el caso de la
arquitectura de microservicios, que puede implementarse de muchas formas. En este caso, no hay muchas opciones,
puesto que la asignatura requiere API y API gateway por separado. Por tanto, la elección es relativamente obvia y se
definen los siguientes elementos:

* Base de Datos o BDD: almacena los datos de la aplicación.
* API: internamente también se le denomina backend y su función es la de obtener y servir los datos de la BDD. Constará
  de endpoints abiertos y otros restringidos por API key, al menos inicialmente.
* API Gateway: cumplirá varias funciones como la de autenticación, autorización y auditoría de la aplicación, que son
  requisitos de la asignatura. Actuará de intermediario entre el cliente y la API.
* Cliente o frontend: será el componente con el que el usuario final interactuará directamente. Constará de una interfaz
  gráfica y se dirigirá a la API para obtener los datos necesarios.

En ADRs posteriores se concreta la implementación de cada uno de estos elementos, en cuanto a microservicios que los
componen y también en cuanto a tecnologías y herramientas utilizadas.

</div>
