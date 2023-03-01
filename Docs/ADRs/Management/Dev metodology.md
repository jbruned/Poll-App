# ADR - Metodologías de desarrollo

* Estado: aceptada
* Responsables:
  * Unai Biurrun Villacorta
  * Jorge Bruned Alamán
  * Iñaki Velasco Rodríguez
* Fecha: 28-02-2023

# Introducción
<div style="text-align: justify!important">

En este documento se recoge la información relativa a las decisiones iniciales en cuanto a **metodologías de desarrollo**. Para cada decisión, se listan las opciones consideradas junto a una breve descripción, ventajas y contras, así como la decisión final tomada.

En este caso, se evaluarán diferentes opciones para los distintos aspectos posibles de las metodologías de desarrollo. 

Cabe destacar que se ha decidido aplicar metodologías ágiles debido a su flexibilidad, posibilidad de generar entregas continuas basadas en el incremento de funcionalidad (adecuándose así a la planificación de la asignatura) o la capacidad de adaptarse a posibles cambios en los requisitos.
</div>

## Tabla de contenidos

[TOC]


# Factores en la Decisión
<div style="text-align: justify!important">

Para tomar la decisión se han priorizado los siguientes factores:
* Conocimiento existente en el equipo
* Sencillez
* Popularidad
* Adecuación a la complejidad del proyecto
</div>

# Opciones Consideradas - Metodología ágil principal
<div style="text-align: justify!important">

Tras un análisis de las opciones disponibles actualmente, se han valorado las siguientes:
* Scrum
* Kanban
</div>

## Ventajas y Desventajas de las opciones

### Scrum
<div style="text-align: justify!important">

* Positivo, ampliamente implantada en la actualidad en numerosas empresas.
* Positivo, conocido por varios miembros del equipo.
* Negativo, roles como Scrum Master o Product Owner considerados inncecesarios debido al tamaño del equipo y a la forma de desarrollo que se va a plantear en la que los todos los miembros realizarán tareas y organizarán de manera equitativa.
* Negativo, scrum diario/reunión rápida considerada innecesaria debido a la naturaleza del proyecto y la compaginación de horarios.
</div>

### Kanban
<div style="text-align: justify!important">

* Positivo, ampliamente implantada en la actualidad en numerosas empresas.
* Positivo, conocido por varios miembros del equipo.
* Positivo, tablero Kanban considerado de gran utilidad
</div>

## Decisión
<div style="text-align: justify!important">

 De entre todas las opciones barajadas y descritas previamente, finalmente se ha optado por una combinación de ambas opciones, aplicando los aspectos que consideramos más adecuados de cada una de las mismas.

 Por consiguiente, se aplicará lo siguiente:
 * Tablero Kanban: la facilidad de visualización de todas las tareas, sus estados, los miembros participantes y el estado general del desarrollo ha llevado al equipo a hacer uso de ello.
 * Periodos de trabajos: similar a los [*sprints* de *Scrum*](https://www.atlassian.com/agile/scrum/sprints#:~:text=What%20are%20sprints%3F-,A%20sprint%20is%20a%20short%2C%20time%2Dboxed%20period%20when%20a,better%20software%20with%20fewer%20headaches.) y que se adaptarán a los periodos de entrega de la asignatura.
</div>

# Opciones Consideradas - Reuniones/Seguimiento
<div style="text-align: justify!important">

Tras un análisis de las opciones disponibles actualmente, se han valorado las siguientes:
* Reuniones diarias
* Reuniones semanales
* Reuniones sin planificación
</div>

## Decisión
<div style="text-align: justify!important">

En este caso no se ha desarrollado de manera detallada los aspectos positivos y negativos de cada opción debido a lo simple del aspecto a comparar.

Se ha decidido realizar una reunión semanal debido a cuatro puntos principales:
- Se podría llegar a plantear reuniones sin planificación de horario y día, sobre todo teniendo en cuenta las dificultades que podría llegar a haber a la hora de compatibilizar horarios. No obstante, se considera necesario imponer al menos un determinado momento para realizar estas reuniones.
- El tamaño del equipo y la función de cada miembro: al ser un equipo reducido y con funciones similares, no se considera correcto realizar reuniones diarias ya que con los comentarios y discusiones rápidas entre miembros es suficiente para resolver los problemas cotidianos.
- El estado actual del proyecto: debido a que se trata de un inicio de proyecto en el que se está comenzando con el desarrollo, no se ve necesario un seguimiento mayor al semanal.
- Tablero Kanban: la existencia de este tablero hace que sea más fácil conocer el estado de las tareas y desarrollo general sin ser necesario recurrir a reuniones diarias.
</div>

# Extra - Buenas prácticas
<div style="text-align: justify">
    
Debido a la similitud en cuanto al origen académico y trayectoria de los tres integrantes del grupo, todos ellos provenientes del Grado en Ingeniería Informática y con experiencia en el campo, se ha decidido desarrollar, gestionar y desplegar la aplicación conforme a buenas prácticas establecidas previamente.
 
Dado que se emplearán lenguajes de programación diferentes para los distintos componentes del proyecto, no es posible definir un solo conjunto de buenas prácticas. No obstante, es posible definir diferentes conjuntos de las mismas para cada componente.
    
Como ejemplo, para el Backend (desarrollado en Python) se utilizará la guía de estilo [PEP8](https://peps.python.org/pep-0008/), por su gran popularidad e integración nativa con IDEs como PyCharm.

Además, y como generalidad, se empleará el inglés a la hora de programar, dada su popularidad en el ámbito de la programación. Esto facilitará la mantenibilidad y las posibles expansiones del proyecto, incluso como una alternativa *open source* si se diera el caso.

En general, se seguirán las buenas prácticas y convenciones asociadas a cada una de las tecnologías, lenguajes, herramientas y *frameworks* utilizados, ya sea en cuanto a estructura del código, patrones de diseño, *naming conventions*, etc. El objetivo de estas buenas prácticas es generar un código de calidad y con una buena mantenibilidad, además de propiciar un mejor proceso de desarrollo y mejorar la comprensión del código por personas ajenas.
</div>