# ADR **CI/CD**

* Estado: aceptada
* Responsables:
    * Unai Biurrun Villacorta
    * Jorge Bruned Alamán
    * Iñaki Velasco Rodríguez
* Fecha: 01-05-2023

# Introducción

<div style="text-align: justify!important">

En este documento se recoge la información relativa a las decisiones iniciales en cuanto al establecimiento de pipelines
para la integración y despliegue continuos o CI/CD. Para cada decisión, se listan las opciones consideradas junto a una
breve descripción, ventajas y contras, así
como la decisión final tomada.

Antes de comenzar, cabe destacar que dado que la herramienta de control de versiones que se está utilizando es GitHub y
ya incluye un conjunto de funcionalidades para la implementación de pipelines (GitHub Actions), no se han considerado
otras opciones para implementar pipelines.
GitHub es gratuito y sus actions también, al menos para proyectos Open Source y para estudiantes, por lo que debido a su
coste nulo y a su integración con la herramienta que utilizamos para el control de versiones, nos proporciona muchas
ventajas y ningún inconveniente. Utilizar otras herramientas como Jenkins sería más costoso y no aportaría ninguna
ventaja dentro del contexto de este proyecto.

También cabe destacar que como sustituto a los componentes de un pipeline y al pipeline en sí, casi siempre es posible
idear una solución manual o semiautomática basada en scripts o similares. Sin embargo, por su poca escalabilidad y
mantenibilidad, no se considera una opción viable en ningún caso.

En cuanto al entorno cloud que se va a utilizar es AWS, por ser requisito de la asignatura y por ofrecer
recursos gratuitos para estudiantes.

Por tanto, este documento se centra en detallar qué componentes se han considerado para el pipeline así como su
alcance y funcionamiento.

</div>

## Tabla de contenidos

<!--[TOC] -->
<!-- TOC -->

- [ADR **CI/CD**](#adr-cicd)
- [Introducción](#introducción)
  - [Tabla de contenidos](#tabla-de-contenidos)
- [Factores en la Decisión](#factores-en-la-decisión)
- [Componentes considerados](#componentes-considerados)
  - [Linting](#linting)
    - [Ventajas](#ventajas)
    - [Inconvenientes](#inconvenientes)
    - [Opciones consideradas](#opciones-consideradas)
  - [Testing](#testing)
    - [Ventajas](#ventajas-1)
    - [Inconvenientes](#inconvenientes-1)
    - [Opciones consideradas](#opciones-consideradas-1)
  - [Build](#build)
    - [Ventajas](#ventajas-2)
    - [Inconvenientes](#inconvenientes-2)
    - [Opciones consideradas](#opciones-consideradas-2)
  - [Publish](#publish)
    - [Ventajas](#ventajas-3)
    - [Inconvenientes](#inconvenientes-3)
    - [Opciones consideradas](#opciones-consideradas-3)
  - [Deploy](#deploy)
    - [Ventajas](#ventajas-4)
    - [Inconvenientes](#inconvenientes-4)
    - [Opciones consideradas](#opciones-consideradas-4)
- [Pipeline creado](#pipeline-creado)

<!-- TOC -->
# Factores en la Decisión

<div style="text-align: justify!important">

Para tomar la decisión se han priorizado los siguientes factores, suponiendo herramientas gratuitas o incluidas en el
GitHub Student Pack:

* Valor aportado
* Sencillez
* Popularidad
* Escalabilidad

</div>

# Componentes considerados

<div style="text-align: justify!important">

Tras un análisis de posibles componentes de un pipeline CI/CD, se han considerado los siguientes componentes, todos
ellos implementados en GitHub Actions:

* Linting
* Testing
* Build
* Publish
* Deploy

</div>

## Linting

<div style="text-align: justify!important">

El linting es una técnica de análisis estático de código que se utiliza para encontrar errores en el código fuente.
Gracias a este proceso, se pueden encontrar errores de sintaxis, de estilo, etc. que pueden pasar
desapercibidos en la fase de desarrollo. Lo ideal es que sea un proceso automático para que el desarrollador pueda
despreocuparse y centrarse en tareas más productivas y también para evitar olvidos.
</div>

### Ventajas

<div style="text-align: justify!important">

* Aumenta la mantenibilidad del código, ya que fuerza a los desarrolladores a seguir un estilo de código común.
* Aumenta la calidad del código, ya que se reduce la probabilidad de aplicar malas prácticas e introducir *code smells*.
* Reduce la probabilidad de introducir errores al repositorio de código, ya que el proceso puede automatizarse para
  procesos como commits, pushes y pull-requests y puede obligarse a superar el linting para poder aplicar estas
  acciones.

</div>

### Inconvenientes

<div style="text-align: justify!important">

* Reduce la velocidad de incorporación de cambios, puesto que para poder aplicar cambios al repositorio, es necesario
  que el código pase el proceso de linting, si así se ha configurado.
* Puede reducir la velocidad de desarrollo, puesto que si el proceso de linting es muy estricto, puede obligar a los
  desarrolladores a invertir mucho tiempo en corregir errores de estilo que no son importantes de cara a la
  funcionalidad, pero que hace falta corregir para poder incorporar cambios.
* Puede aumentar el coste del sistema, puesto que existen herramientas de pago
  como [SonarQube](https://www.sonarqube.org/), que permiten realizar un análisis más exhaustivo del código y detectar
  más errores.

</div>

### Opciones consideradas

<div style="text-align: justify!important">

* **Instalación y configuración de linters individuales para los componentes principales del proyecto (frontend y
  backend
  en JS y Python respectivamente)**: [ESLint](https://eslint.org/) y [pylint](https://github.com/pylint-dev/pylint)
* **Instalación y configuración de linters individuales para todos los lenguajes de programación usados (JS, Python,
  HTML,
  CSS, etc.)**: ESLint, pylint, HTMLHint, CSSLint, etc.
* **Instalación y configuración de un linter global configurable para todos los lenguajes de programación usados (JS,
  Python, HTML, CSS, etc.)**: [Super-Linter](https://github.com/marketplace/actions/super-linter)

De estas tres opciones se ha optado por la última, puesto que es la que más lenguajes permite cubrir, pero con un coste
considerablemente menor que la segunda opción, que requiere una instalación y configuración individual de todos los
linters. Gracias a su configuración, se logra una gran escalabilidad, con lo que el linting puede evolucionar junto a
la madurez del proyecto y del equipo.
La primera opción es la más sencilla de implementar, pero también es la menos escalable, puesto que para incluir
lenguajes adicionales se requeriría un proceso diferente cada vez, y acabaría siendo muy similar a la segunda opción.

Super-linter es una herramienta de GitHub Actions que agrega una gran cantidad de linters para la mayoría de lenguajes
de programación pero también para otros tipos de archivos como Dockerfiles, Markdown, etc. Además, permite configurar
los linters que se quieren utilizar y los que no, el alcance del linting, así como la severidad de los errores que se
quieren detectar. Además, dado que simplemente reúne y aplica linters existentes como pylint y otros, es posible
configurar dichos linters del mismo modo que si se instalaran por separado.
También es posible configurarlo y ejecutarlo localmente, con lo que el desarrollador puede comprobar si su código supera
el linting antes de incorporarlo al repositorio.

También resulta conveniente establecer el alcance del linting, ya que además del código podrían validarse ficheros txt,
markdown, etc. Todo ello supondría un esfuerzo considerable para los desarrolladores, puesto que idealmente el linting
debería incorporarse desde el principio para resolver los errores según vayan surgiendo. Dado que el proyecto tiene
varios meses de vida, habrá muchos errores de entrada si se validan todos los ficheros. Para el contexto actual del
proyecto, se ha decidido validar principalmente el código funcional del sistema. Esto es:

- Código Python del backend
- Código JavaScript y HTML del frontend
- Lenguaje natural
- Dockerfiles
- JSON
- YAML
- Fichero de GitHub Actions

</div>

## Testing

<div style="text-align: justify!important">

La incorporación de test automáticos del código, ya sean unitarios, de integración etc. es una práctica que reduce la
probabilidad de introducir bugs en el código y aumenta la calidad del mismo, puesto que, si el código
desarrollado no supera todos los test debería ser rechazado.
Eso sí, la eficacia de los test depende de su calidad y de su cobertura, por lo que es importante que los test estén
bien desarrollados y la cobertura del código sea lo más alta posible.

</div>

### Ventajas

<div style="text-align: justify!important">

* Reduce la probabilidad de introducir bugs al código, al obligar la superación de todos los test para validar los
  cambios, con lo que la calidad del código aumenta.
* Permite la detección temprana de bugs, al ejecutar los test de forma automática en cada cambio. De este modo, se
  reduce el coste de su arreglo.

</div>

### Inconvenientes

<div style="text-align: justify!important">

* Reduce la velocidad de incorporación de cambios, puesto que para poder aplicar cambios al repositorio, es necesario
  que el código pase todos los test. Este es un problema proporcional al tamaño de la solución y a la cobertura de los
  test.
* Reduce la velocidad de desarrollo, ya que es necesario invertir tiempo en desarrollar y mantener los test, además de
  en el desarrollo del código en sí. Esto es especialmente notable si se plantea una cobertura casi total del código y
  la incorporación de test de distinto tipo: unitarios, de integración, etc.
* A pesar de su utilidad, es imposible eliminar el 100% de los bugs con este sistema, ya que es posible que los test
  no cubran todos los casos posibles, en especial en componentes de difícil testeo como la interfaz de usuario.
* Puede aumentar el coste del pipeline, al tratarse de un componente más.

</div>

### Opciones consideradas

<div style="text-align: justify!important">

Dado que el proyecto no requiere la implementación de testing, el tiempo de desarrollo es limitado y crear proyectos de
testing desde cero es una tarea muy costosa, no se han implementado test automáticos. Sin embargo, sí que se ha incluido
una fase de testing en blanco en el pipeline de CI/CD, de modo que, si en el futuro se decide implementar testing, la
pipeline ya estaría preparada.

</div>

## Build

<div style="text-align: justify!important">

El proceso de compilación del código, conocido como *build*, es un proceso necesario y predecible para poder ejecutar el
software desarrollado. Dada su predictibilidad, es posible automatizarlo para ahorrar tiempo al desarrollador y evitar
errores.
</div>

### Ventajas

<div style="text-align: justify!important">

* Aumenta la velocidad de desarrollo, puesto que el desarrollador no tiene que preocuparse de compilar el código
  manualmente.
* Reduce la probabilidad de errores, al automatizar un proceso que, de hacerse manualmente, podría
  introducir errores.
* Aumenta la disponibilidad del sistema, ya que no hace falta esperar a que un desarrollador compile el código para
  poder ejecutarlo, se hará de forma automática. Esto también aporta agilidad.

</div>

### Inconvenientes

<div style="text-align: justify!important">

* Reduce la velocidad de incorporación de cambios, puesto que la compilación podría ser un proceso lento, especialmente
  si se trata de un proyecto grande. El pipeline no finalizaría hasta que termine la compilación, por lo que habría que
  esperar.
* Puede aumentar el coste del sistema, por dos motivos. Por un lado, los requerimientos del pipeline aumentan y, por
  otro, se requiere de espacio de almacenamiento de artefactos, que suele ser caro y reducido (tómese como ejemplo
  GitHub, que permite hasta 500 MB gratuitos).
* Aumenta la complejidad del sistema (sobre todo inicialmente), puesto que es necesario implementar el proceso de
  compilación además del producto software en sí.

</div>

### Opciones consideradas

<div style="text-align: justify!important">

* **Acción de GitHub Actions**: Se utilizan acciones como *Docker Image* disponibles en en el listado de Workflows
  de GitHub Actions.
* **Integración manual con makefile**: Se crean comandos en el makefile del proyecto que pueden invocarse desde el
  fichero yml de configuración de GitHub Actions.

De estas dos opciones se ha optado por la segunda, puesto que no requiere conocimiento específico de acciones concretas
del listado de Workflows de GitHub Actions y puede configurarse de acuerdo a nuestras necesidades.

</div>

## Publish

<div style="text-align: justify!important">

La publicación de software es el proceso mediante el cual el software pasa a estar disponible para el uso externo. De
forma similar al proceso de compilación, es un proceso que puede automatizarse para ahorrar tiempo al
desarrollador y evitar errores, aunque en este caso, el proceso suele ser algo más complejo y algo menos predecible que
el de compilación.

En este documento, se entiende despliegue como el proceso de subir o *pushear* el artefacto generado por el proceso de
build al entorno cloud de AWS.

</div>

### Ventajas

<div style="text-align: justify!important">

* Aumenta la velocidad de desarrollo, puesto que el desarrollador no tiene que preocuparse de desplegar el código
  manualmente.
* Reduce la probabilidad de errores humanos al desplegar.
* Habilita el versionado y facilita el mantenimiento del proceso de despliegue, al incorporarse como un componente del
  pipeline, que puede configurarse con una utilidad software dedicada en lugar de utilizar scripts.

</div>

### Inconvenientes

<div style="text-align: justify!important">

* Puede aumentar el coste del sistema, por dos motivos análogos al componente de *Build* descrito previamente: el
  pipeline debe ser más complejo y se requiere almacenamiento en AWS, en este caso.
* Al igual que el resto de componentes de un pipeline, aumenta la complejidad de implementación del sistema (sobre todo
  inicialmente), puesto que además de desarrollar el producto en sí también hay que desarrollar el pipeline, aunque a la
  larga se reduce la complejidad con respecto a utilizar soluciones como scripts.

</div>

### Opciones consideradas

<div style="text-align: justify!important">

* **Acción de GitHub Actions**: Se utilizan acciones como *Deploy to Amazon ECS* disponibles en el listado de Workflows
  de GitHub Actions.
* **Edición manual de fichero yml de GitHub Actions**: Se edita manualmente el fichero yml de configuración de GitHub
  Actions para incluir el proceso de despliegue.

De estas dos opciones, bastante similares, se ha optado por la segunda, puesto que no requiere conocimiento específico
de acciones concretas del listado de Workflows de GitHub Actions y puede configurarse de acuerdo a nuestras necesidades.

</div>

## Deploy

<div style="text-align: justify!important">

El proceso de despliegue y el de publicación son muy similares y a menudo se toman como equivalentes. Sin embargo, en
este documento se entiende despliegue como el proceso de levantar la infraestructura en el entorno cloud de AWS para
servir los artefactos generados y subidos a AWS en el proceso de publish.
</div>

### Ventajas

<div style="text-align: justify!important">

* Aumenta la velocidad de despliegue, puesto que el desarrollador no tiene que preocuparse de desplegar el código
  manualmente.
* Reduce la probabilidad de errores humanos al desplegar.
* Si se utilizan herramientas específicas, se habilita el versionado y facilita el mantenimiento del proceso de
  despliegue, al incorporarse como un componente del pipeline, que puede configurarse con una utilidad software dedicada
  en lugar de utilizar scripts. Esto también facilita mucho la escalabilidad y adaptabilidad del sistema, puesto que se
  permite un despliegue rápido en casi cualquier momento y entorno.

</div>

### Inconvenientes

<div style="text-align: justify!important">

* Puede aumentar el coste del sistema, principalmente debido a la complejidad añadida del pipeline.
* Al igual que el resto de componentes de un pipeline, aumenta la complejidad de implementación del sistema (sobre todo
  inicialmente), puesto que además de desarrollar el producto en sí también hay que desarrollar el pipeline.
* En algunos casos no puede pensarse que el despliegue en producción puede automatizarse, ya que no siempre es posible.
  Por tanto, el equipo debe ser capaz de desplegar de forma manual dentro de un tiempo razonable en esos casos.

</div>

### Opciones consideradas

<div style="text-align: justify!important">

* **Acción de GitHub Actions**: Se utilizan acciones como *Deploy to Amazon ECS* disponibles en el listado de Workflows
  de GitHub Actions.
* **Uso de herramientas adicionales**: Se utilizan herramientas adicionales como Terraform o Jenkins para el proceso de
  despliegue.

De las dos opciones mencionadas, se ha optado por la segunda, en concreto por el uso de Terraform, puesto que es un
requisito de la asignatura, es popular y es gratuito. Además, es una solución más escalable y adaptable que la primera,
que únicamente puede aplicarse en GitHub.

No obstante, en la fase actual del proyecto no se ha implementado el despliegue tal y como se entiende en este
documento. Sin embargo, de cara al futuro y a la siguiente entrega se han definido dos fases de despliegue en blanco que
se ejecutan en el pipeline de CI/CD:

1. **Deploy (entorno de test)**: La idea es que se despliegue el código en un entorno interno de test que será lo más
   parecido posible al de producción, pero sin serlo. De esta forma, el equipo de desarrollo puede probar el código en
   un entorno controlado antes de desplegarlo en producción.
2. **Deploy (entorno de producción)**: proceso de despliegue en el entorno de producción. En el contexto del proyecto y
   la asignatura, se entiende que el entorno de producción es el que se utiliza para servir el producto al docente, esto
   es, AWS. Por tanto, se implementará para la siguiente entrega.

</div>

# Pipeline creado

<div style="text-align: justify!important">

A lo largo de este documento se han presentado una serie de componentes que pueden formar parte de un pipeline de CI/CD.
Así pues, queda detallar qué componentes se han utilizado en el pipeline de CI/CD del proyecto y cómo se comunican entre
sí.

El pipeline de CI/CD del proyecto se ha implementado como un Workflow personalizado de GitHub Actions que consta de los
siguientes pasos en orden de ejecución:

1. **Linting**: Se utiliza Super-linter para validar el código según el alcance establecido en la sección
   de [Linting](#linting). Se lanza tras cualquier commit, push y pull request.
2. **Test**: Fase en blanco de cara al futuro. Siempre se supera. Se lanza tras cualquier commit, push y pull request.
3. **Build**: Solo se activa si se pasa el linting y los test y en caso de pushear un tag. Crea el artefacto Docker.
4. **Deploy (entorno de test)**: Fase en blanco de cara al futuro. Solo se activa si se pasa el build **y en caso de
   pushear un tag**. Despliega el artefacto Docker en un hipotético entorno de test.
5. **Publish**: Solo se activa si se pasa el build. Publica el artefacto Docker en el registro de imágenes de AWS ECR.
6. **Deploy (entorno de producción)**: Fase en blanco de cara a la siguiente release. Solo se activa si se pasa el
   publish **y en caso de crear una release**.

El flujo de ejecución resultante en GitHub Actions sería el siguiente (no se ha pusheado ninguna tag ni creado ninguna
release):

![Flujo del pipeline](../../img/Diagrama_pipeline.jpg "Flujo de ejecución del pipeline de CI/CD (no se ha pusheado ninguna tag ni creado ninguna release)")

</div>
