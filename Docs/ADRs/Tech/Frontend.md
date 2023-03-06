# ADR Frontend<!-- omit from toc -->

* Estado: aceptada
* Responsables:
  * Unai Biurrun Villacorta
  * Jorge Bruned Alamán
  * Iñaki Velasco Rodríguez
* Fecha: 05-03-2023

# Introducción
<div style="text-align: justify!important">

En este documento se recoge la información relativa a las decisiones iniciales en cuanto a la tecnología Frontend que se utilizará en el proyecto. 
Para cada decisión, se listan las opciones consideradas junto a una breve descripción, ventajas y contras, así como la decisión final tomada.
</div>

## Tabla de contenidos

<!-- [TOC] -->
- [Introducción](#introducción)
  - [Tabla de contenidos](#tabla-de-contenidos)
- [Factores en la decisión](#factores-en-la-decisión)
- [Opciones consideradas](#opciones-consideradas)
  - [Server-side rendering](#server-side-rendering)
  - [Client-side rendering](#client-side-rendering)
    - [HTML + *JavaScript* puro](#html--javascript-puro)
    - [React](#react)
    - [Angular](#angular)
- [Decisión](#decisión)
- [Referencias](#referencias)

# Factores en la decisión
<div style="text-align: justify!important">

Para tomar la decisión se han priorizado los siguientes factores:
* Velocidad de ejecución/requerimientos del equipo cliente
* Sencillez de cara al desarrollo
* Popularidad
* Conocimiento existente en el equipo
</div>

# Opciones consideradas
<div style="text-align: justify!important">

Tras un análisis de las opciones disponibles actualmente, se han valorado las siguientes:
* Server-side rendering
* React
* Angular
* HTML + *JavaScript* puro
</div>

## Server-side rendering
<div style="text-align: justify!important">

En primer lugar, se consideró la opción de hacer todo el renderizado en el servidor y responder con una página HTML estática a cada petición. Esto presenta algunas ventajas:
* Simplificación del código necesario para el frontend, no se ejecuta nada de código en el cliente.
* La aplicación funcionará en equipos con peores especificaciones de hardware el no ejecutarse código en él.
* Mejor de cara al indexado en motores de búsqueda y RRSS, aunque en principio no nos influye dada la naturaleza de nuestra aplicación.

Sin embargo, priman los inconvenientes:
* Nos interesa dentro de la asignatura, tener varios componentes que se comuniquen entre sí. El frontend en este caso sería muy simple y no tendrái que comunicarse con el backend.
* Necesidad de recargar la página constantemente para cualquier interacción con el backend.
* Mayores tiempos de carga cuando el backend tenga una alta carga de trabajo.
* Falta de aislamiento entre componentes; si por ejemplo el backend se cae no recibiríamos absolutamente ninguna respuesta (p. ej: *timeout*).
* Respuestas del servidor de mucho mayor tamaño (página completa frente a, por ejemplo, un pequeño JSON con la información necesaria).
* Imposibilidad de servir desde diferentes servidores la vista y los datos.
* Este modelo está quedando obsoleto, debido entre otras cosas a estas desventajas.
</div>

## Client-side rendering
<div style="text-align: justify!important">

Una primera posibilidad, sería la de devolver una página estática directamente desde el *backend*, con todos los datos recogidos de la base de datos ya integrados en la misma. Esto es muy típico en páginas desarrolladas con *PHP*, aunque obviamente podemos hacer lo mismo con *Python*+*Flask*, devolviendo un HTML con *placeholders* sustituidos por los datos deseados.

Las ventajas comunes al resto de opciones planteadas incluyen:

* Nos interesa dentro de la asignatura, especialmente de cara a aprender cómo hacer un buen despliegue, tener varios componentes que se comuniquen entre sí.
El frontend en este caso sería un componente más que debe comunicarse con el backend, en lugar de que simplemente el backend nos devuelva una página estática.
* Menor tamaño de las respuestas (pequeño *JSON* frente a página *HTML* completa).
* No hace falta recargar la página constantemente, especialmente útil en conexiones lentas, gracias también al punto anterior.
* Independencia entre componentes: por ejemplo, podemos servir la página desde una *CDN* y disponer de un servidor central donde se hagan pequeñas peticiones *JSON*.
* Independencia entre componentes: si el backend tiene una carga muy alta o se cae, podemos mostrar un mensaje de error y parte de la página puede funcionar igualmente (en lugar de un *timeout*, por ejemplo).
* Modelo más extendido y usado a día de hoy.

Algunas desventajas serían:
* Mayor complejidad del código *frontend*.
* Necesarias mejores especificaciones/requisitos del equipo cliente o un mejor navegador.
* Se complica el despliegue; esto no es algo negativo, puesto que en esta asignatura estamos adquiriendo conocimientos relativos al despliegue y nos interesa ponerlos en práctica.
</div>

### HTML + *JavaScript* puro

<div style="text-align: justify!important">

Una de las opciones planteadas consiste en no utilizar ninguna librería en el *frontend*, sino hacerlo todo desde cero con HTML+CSS+JS puro. Esto plantea algunas ventajas:

* Menor número de dependencias
* No tenemos que cargar las librerías sino solo nuestra propia web
* No cargamos código que no se vaya a usar (las librerías habría que cargarlas enteras, no solo lo que se usa)
* Mayor control sobre la arquitectura, la implementación y lo que hace nuestro código "por detrás"

Sin embargo, abundan los inconvenientes:

* Código redundante
* Hay que "picar" todo "desde cero"
* Productividad muy reducida; tardaríamos mucho más para desarrollar las mismas funcionalidades.
* Mayor probabilidad de cometer errores de seguridad o ineficiencias, dado que las librerías están desarrolladas y revisadas por expertos y por una comunidad muy grande mientras que en *JavaScript* lo haríamos todo a mano nosotros mismos.
</div>

### React
<div style="text-align: justify!important">

Una de las librerías para desarrollar interfaces de usuario web es [React](https://reactjs.org/). Las ventajas y desventajas se van a analizar frente a *Angular*, que es la otra opción considerada.

Entre las ventajas encontradas, destacaríamos:

* Algunos miembros del equipo poseen conocimientos sobre esta tecnología y la han utilizado para desarrollar otros proyectos con anterioridad.
* Es una tecnología asentada en el mercado y la más popular en su sector, lo que hace que haya muchos recursos de cara a documentación, soporte, solución de problemas, etc.
* Permite dividir el código en componentes y lograr una mayor abstracción, un código más legible, mantenible y estructurado según patrones de diseño.
* Más ligero en cuanto a peso que, por ejemplo, *Angular*.
* Posibilidad de extender su funcionalidad mediante paquetes adicionales como podrían ser *Redux*, *React Router*, etc.
* En general, se suele decir que tiene una mejor curva de aprendizaje respecto a *Angular*.
* Mejor rendimiento que otras alternativas.
* Mayor adaptabilidad para desarrollar una aplicación multi-plataforma que funcione correctamente por ejemplo en dispositivos móviles.
* Disponibilidad de paquetes como *create-react-app* que simplifican la creación del entorno y compilación.
* Posibilidad de utilizar *TypeScript*, con ventajas como el tipado de variables y una sintaxis mejorada pero compatible con *JavaScript*

En cuanto a las desventajas, destacan las siguientes:
* Gestión del estado más pobre.
* Falta de características "*built-in*", siendo necesario utilizar librerías para muchos aspectos básicos.
* El *data-binding* es unidireccional (no dispone de elementos como *observers*)
  
</div>

### Angular
<div style="text-align: justify!important">

Otra de las tecnologías más populares, utilizada y mantenida por *Google*, es [Angular](https://angular.io/). Se trata de un *frontend framework*, siendo *React* definido como una librería para crear GUIs.

Las ventajas que ofrece para nuestro proyecto son las siguientes:
* *Data-binding* bidireccional.
* Mayor funcionalidad.
* También ofrece la posibilidad de utilizar *TypeScript*, con ventajas como el tipado de variables y una sintaxis mejorada pero compatible con *JavaScript*

En cuanto a las desventajas, destacan las siguientes:

* En general, los miembros del equipo tienen una menor experiencia con esta tecnología.
* Proceso de aprendizaje más complejo en general (lo cual, junto al punto anterior, es bastante negativo).
* Menor libertad de cara a estructura y patrones de diseño que *React*.
* Mayor tamaño.
* Menor popularidad.
  
</div>

# Decisión
<div style="text-align: justify!important">

De entre todas las opciones enumeradas y discutidas con anterioridad, finalmente se ha optado por utilizar React para el desarrollo del frontend, principalmente debido a su sencillez y su popularidad, aunque, naturalmente, se han tenido en cuenta todas las ventajas y desventajas recogidas en los correspondientes apartados.

Las opciones de página estática o desarrollo con *JavaScript* puro fueron rápidamente descartadas por estar más obsoletas y ofrecer una peor experiencia tanto de usuario como de cara al desarrollo.

También nos ha parecido interestante esta combinación de cara al despliegue por los motivos mencionados: dentro de la asignatura estamos adquiriendo conocimientos de despliegue que nos interesa poner en práctica. Con la elección realizada, tendremos más componentes que deben comunicarse entre sí; el frontend en este caso sería un componente más que debe comunicarse con el backend, en lugar de que simplemente el backend nos devuelva una página estática. Esto puede requerir de ajustes y configuraciones extra (por ejemplo, para evitar errores *CORS*).
</div>

# Referencias<!-- opcional -->
<div style="text-align: justify!important">

* [React](https://reactjs.org/)
* [Angular](https://angular.io/)
* [TypeScript](https://www.typescriptlang.org/)

</div>