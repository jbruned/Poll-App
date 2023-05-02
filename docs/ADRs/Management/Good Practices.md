# ADR buenas prácticas <!-- omit from toc -->

* Estado: aceptada
* Responsables:
  * Unai Biurrun Villacorta
  * Jorge Bruned Alamán
  * Iñaki Velasco Rodríguez
* Fecha: 28-02-2023

# Introducción
<div style="text-align: justify!important">

En este documento se recoge la información relativa a las decisiones iniciales en cuanto a diversas buenas prácticas que se van a aplicar en el desarrollo del proyecto. Para cada decisión, se listan las opciones consideradas junto a una breve descripción, ventajas y contras, así como la decisión final tomada.
</div>

## Tabla de contenidos

<!-- TOC -->
- [Introducción](#introducción)
  - [Tabla de contenidos](#tabla-de-contenidos)
* [Factores en la Decisión](#factores-en-la-decisión)
* [Opciones Consideradas](#opciones-consideradas)
  * [Ventajas y Desventajas de las opciones](#ventajas-y-desventajas-de-las-opciones)
  * [Gestionar repositorio Git](#gestionar-repositorio-git)
  * [Releases y tags](#releases-y-tags)
  * [Uso de pipelines](#uso-de-pipelines)
  * [Documentación de las APIs](#documentación-de-las-apis)
* [Enlaces](#enlaces)
<!-- TOC -->


# Factores en la Decisión
<div style="text-align: justify!important">

Para tomar la decisión se han priorizado los siguientes factores:
* Valor aportado de cara a las entregas (requisitos asignatura)
* Valor aportado de cara al desarrollo
* Sencillez de implementación
</div>

# Opciones Consideradas
<div style="text-align: justify!important">

Tras un análisis de algunas de las buenas prácticas que pueden aplicarse en el desarrollo software, se han valorado las siguientes prácticas:
* Gestionar repositorio Git
* Releases y tags
* Uso de pipelines
* Documentación de las APIs

</div>

## Ventajas y Desventajas de las opciones

## Gestionar repositorio Git
<div style="text-align: justify!important">

A la hora de gestionar un repositorio Git existen muchas estrategias: crear una única rama y trabajar sobre ella, crear una rama por división de trabajo (que puede ser de cualquier tamaño: épicas, historias, tareas, etc.), crear ramas por entornos (desarrollo, test, etc.)

El objetivo de estas técnicas de trabajo no es otro que procurar que los desarrolladores puedan desempeñar su labor sin pisarse mutuamente y que haya líneas base que sigan funcionando. 
Por tanto, se escoge la opción de crear ramas por divisiones de trabajo que irán fusionándose con main periódicamente y tras su validación. 
Eso sí, no se harán ramas adicionales desde el principio ni para toda tarea, puesto que al comienzo del proyecto no habrá una línea base que mantener y existen tareas que no suponen un riesgo para la integridad de main (documentación, por ejemplo).

Naturalmente, esta técnica tiene puntos positivos y negativos. Algunos de sus puntos positivos son los siguientes:

* Se dota al desarrollador de una gran libertad para desarrollar y probar soluciones sin temor a romper nada, puesto que al usar una rama distina a main siempre podría descartar sus cambios y volver al punto de partida.
* Se reducen las dependencias entre desarrolladores, ya que pueden trabajar sin molestarse.
* El equipo casi siempre tendrá una línea base disponible para ejecutar, con lo que podría enseñar un producto al cliente en todo momento.

No obstante, también existen puntos negativos:
* Crear ramas adicionales consume más tiempo que utilizar main directamente, por lo que el desarrollo podría ser más lento (suponiendo que todo vaya bien claro, ya que si se rompe main el ahorro de tiempo se perdería arreglando dicha rama).
* El manejo de distintas ramas podría llevar a confusiones por parte del desarrollador como, por ejemplo, usar ramas erróneas al momento de desarrollar o fusionar ramas que no tocan.
* Si una rama se crea para una tarea compleja y el desarrollador está mucho tiempo en ella sin incorporar cambios de main, al momento de fusionarlas podrían surgir muchos conflictos.

A pesar de estos inconvenientes, se considera que el hecho de evitar romper main si se hace un uso adecuado de las ramas es sumamente valioso y compensa completamente los aspectos negativos de esta técnica.

**En resumen, se crearán ramas individuales en tareas de tamaño medio-alto y/o que supongan un riesgo para el funcionamiento de main. Las ramas se incorporarán a main una vez validadas.**
</div>

## Releases y tags
<div style="text-align: justify!important">

A la hora de trabajar con Git hay un gran número de acciones que los desarrolladores realizan sobre el repositorio: commits, pushes, merges, etc. 
Entre todas estas acciones puede resultar complejo determinar hasta que punto unos cambios pertenecen a una release concreta o si hay cambios más importantes que otros.

Para mitigar este problema, existen varias formas: crear documentos, utilizar mensajes concretos al hacer commit, etc. Pero también pueden utilizarse tags.

Las ventajas de las tags son las siguientes:
* Son sencillas de utilizar, una vez se conocen
* Se integran con herramientas como GitHub para generar información más visual/práctica como la sección de Releases

Respecto a los aspectos negativos, el único que parece destacable es el hecho de que podrían no conocerse las tags, pues no se obliga su uso en Git. No obstante, no es un gran obstáculo y los beneficios que aportan las tags son sustanciales.

**Así pues, se decide crear Tags para marcar releases como mínimo. También se permite la creación de Tags intermedios a juicio del desarrollador para marcar cambios que considere especialmente relevantes.**
</div>

## Uso de pipelines
<div style="text-align: justify!important">

La automatización en un proyecto software (o de cualquier tipo) resulta de gran ayuda, puesto que ahorra muchísimo tiempo a todos los integrantes del mismo. 
Una de las acciones mecánicas más costosas en tiempo en el desarrollo software es el despliegue del proyecto.

Las pipelines CI/CD buscan automatizar este proceso, por lo que suponen una gran adición a cualquier proyecto. Pero no solo son capaces de eso, también es posible hacer acciones como pruebas para garantizar que el código funciona bien, uso de linters para evitar subir código de baja calidad, etc.

Las ventajas de estos procesos son las siguientes:
* Una vez que están en marcha, ahorran mucho tiempo a los desarrolladores al mismo tiempo que se reduce la posibilidad de errores de despliegue.
* Se reduce la probabilidad de incorporar cambios con errores al código, si se implementan medidas como test automáticos, cancelación de despliegue si hay errores de compilación, etc.
* Permiten aumentar la calidad del código mediante la incorporación de Linters.
* Son un requisito de la asignatura.

Como puntos negativos, destacan los siguientes:
* Crear una pipeline completa es un proceso relativamente complejo y requiere de tiempo y conocimiento específico. 
* Generalmente, la creación de Pipelines está limitada en muchas plataformas y suele ser necesario pagar para hacer Pipelines más completas.
* En relación con el punto anterior, para un mayor rendimiento se requiere de muchos recursos de computación, que conllevan un desembolso económico para nada despreciable. 

**En resumen, dados sus beneficios y a que constituyen un requisito en la asignatura, se implementarán pipelines de despliegue. No obstante, el resto de funcionalidades no se garantizan, dada su complejidad, posible coste económico y caracter optativo en la asignatura.**
</div>

## Documentación de las APIs
<div style="text-align: justify!important">

Una vez se crea una API, resulta conveniente conocer de algún modo qué endopoints hay disponibles, cual es su modo de uso, etc. Esto es interesante para usuarios y desarrolladores. Estos últimos, además, podrían beneficiarse de algún sistema para probar las APIs en distintos entornos y direcciones web sin tener que copiar y modificar las peticiones a mano.

Para todo ello existen varias alternativas: crear documentos (descartada por su naturaleza estática), utilizar herramientas como [Swagger](https://swagger.io/) para definir y documentar la API al mismo tiempo, usar [Postman](https://www.postman.com/), etc.

De todas ellas se elige postman, por los siguientes motivos:
* Es muy sencillo y agradable. En este ultimo aspecto destaca mucho por encima de Swagger, por lo menos a juicio de los integrantes del equipo.
* Es gratuito, incluso para colaborar entre miembros del equipo en una misma Workspace
* Aporta utilidades de desarrollo que ahorran mucho tiempo: CRUD de peticiones, variables de entorno, etc.

Como puntos negativos, destacan los siguientes:
* Requiere de una herramienta adicional. Swagger puede integrarse directamente en el proyecto, en una página propia e interactiva, mientras que Postman es una herramienta software adicional. Eso sí, en cierta forma esto también podría interpretarse como un beneficio, ya que en ocasiones Swagger requiere anotaciones dentro del código que podrían actuar a modo de Boilerplate.
* De cara al usuario, Postman no es muy viable, a diferencia de Swagger, que por lo menos está integrado en el proyecto.

**En resumen, dado el alcance de la asignatura, se escoge Postman para documentar la API y facilitar su testeo por parte de los desarrolladores.**
</div>


# Enlaces
<div style="text-align: justify!important">

* [Swagger](https://swagger.io/)
* [Postman](https://www.postman.com/)

</div>