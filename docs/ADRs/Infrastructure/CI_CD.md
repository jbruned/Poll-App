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

Por tanto, este documento se basará más en detallar qué componentes se han considerado para el pipeline así como su
alcance y funcionamiento.
</div>

## Tabla de contenidos

[TOC]

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
* Reduce la probabilidad de introducir bugs al código, al automatizar un proceso que, de hacerse manualmente, podría
  introducir errores.
* Si se automatiza, se garantiza que el ejecutable esté siempre en la última versión y se logra agilidad.

</div>

### Inconvenientes

<div style="text-align: justify!important">

* Reduce la velocidad de incorporación de cambios, puesto que la compilación podría ser un proceso lento, especialmente
  si se trata de un proyecto grande. El pipeline no finalizaría hasta que termine la compilación, por lo que habría que
  esperar.
* Puede aumentar el coste del pipeline, al tratarse de un componente más.

</div>

### Opciones consideradas

<div style="text-align: justify!important">
TODO
* **Acción de GitHub Actions**: Se utilizan acciones como Docker Image disponibles en GitHub Actions
* **Integración manual con makefile**: Se crean comandos en el makefile del proyecto que pueden invocarse desde el
  fichero yml de configuración de GitHub Actions.

De estas dos opciones se ha optado por la segunda, puesto que no requiere conocimiento específico de acciones concretas
del listado de Workflows de GitHub Actions y puede configurarse a nuestro gusto. Además, dado que habrá que modificar el
fichero yml de configuración de GitHub Actions servirá para adquirir conocimiento sobre estos ficheros.
TODO
</div>

## Publish

<div style="text-align: justify!important">

TODO
</div>

### Ventajas

<div style="text-align: justify!important">

* TODO

</div>

### Inconvenientes

<div style="text-align: justify!important">

* TODO

</div>

### Opciones consideradas

<div style="text-align: justify!important">

* TODO

De estas tres opciones se ha optado por TODO

</div>

## Deploy

<div style="text-align: justify!important">

TODO
</div>

### Ventajas

<div style="text-align: justify!important">

* TODO

</div>

### Inconvenientes

<div style="text-align: justify!important">

* TODO

</div>

### Opciones consideradas

<div style="text-align: justify!important">

* TODO

De estas tres opciones se ha optado por TODO

</div>

# Pipeline creada

<div style="text-align: justify!important">

De entre todas las opciones barajadas y descritas previamente, finalmente se ha optado por crear una GitHub Action con
los siguientes pasos (en orden de ejecución):

1. **Linting**: Se utiliza Super-linter para validar el código según el alcance establecido en la sección
   de [Linting](#linting).
2. **Test**: Fase en blanco de cara al futuro. Siempre se supera.
3. **Build**: Solo se activa si se pasa el linting y los test. Crea el artefacto Docker.
   TODO: Añadir el resto de pasos.

</div>
