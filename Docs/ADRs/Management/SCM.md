# ADR - Gestión de la configuración

* Estado: aceptada
* Responsables:
  * Unai Biurrun Villacorta
  * Jorge Bruned Alamán
  * Iñaki Velasco Rodríguez
* Fecha: 02-03-2023

# Introducción
<div style="text-align: justify!important">

En este documento se recoge la información relativa a las decisiones iniciales en cuanto a la herramienta elegida para llevar a cabo la **gestión de configuración** (así como el control de versiones). Para cada decisión, se listan las opciones consideradas junto a una breve descripción, ventajas y contras, así como la decisión final tomada.
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
* Planes y precio
</div>

# Opciones Consideradas - Gestión de la configuración
<div style="text-align: justify!important">

Tras un análisis de las opciones disponibles actualmente, se han valorado las siguientes:
* GitHub
* GitLab
</div>

## GitHub
<div style="text-align: justify!important">

Consideramos que este servicio tiene numerosas ventajas:
* Alta popularidad → soporte extendido en la comunidad.
* Conocido por todos los miembros del equipo.
* Ofrece herramientas de gestión de gestión necesarias para el correcto desarrollo del proyecto (comentadas más adelante).
* GitHub Pro gratuito al ser estudiante, que además incluye otras herramientas de utilidad.
* Junto con otros proyectos que ya tienen los desarrolladores en sus perfiles de la plataforma, permite disponer de un pequeño portafolio online muy útil para nuestra imagen como desarrolladores.

Sin embargo, también hemos encontrado algunos aspectos negativos:
* CI/CD con menos posibilidades que otras soluciones (*GitHub actions*).
* Límite de espacio de ficheros de 100 MB, aunque no debería ser problema en nuestro caso.
</div>

## GitLab
<div style="text-align: justify!important">

Por un lado, los factores positivos serían:
* Ampliamente implantada en la actualidad en numerosas empresas.
* CI/CD muy completo (*pipelines*).

De igual manera, hay algunos aspectos negativos a tener en cuenta:
* No empleado previamente por todos los miembros del equipo de desarrollo.
* A pesar de estar implantado en numerosas empresas, su popularidad es menor que otras soluciones.
</div>

# Decisión
<div style="text-align: justify!important">

De entre todas las opciones barajadas y descritas previamente y con el objetivo de asegurar la calidad del producto, integrar de manera correcta el desarrollo de los miembros del equipo y asegurar un despliegue y un control de versiones correcto, se hará uso de *GitHub* en cuanto a herramienta de gestión de configuración.

Se ha elegido esta herramienta sobre otras como *GitLab* debido al conocimiento previo de la misma del equipo al completo y a que ofrece otros aspectos como los tableros (GitHub Projects) o la sección de Issues.
    
Se puede acceder al mismo a través del siguiente [enlace al repositorio](https://github.com/jbruned/Poll-App).
</div>

## Herramientas de gestión
<div style="text-align: justify">
    
Como ya se ha mencionado previamente en este documento y con objetivo de desarrollar el proyecto de forma óptima y procurar una distribución adecuada de las tareas y objetivos, se empleará el conjunto de herramientas que GitHub provee para ello. 
Esto es, se utilizarán los Boards de GitHub Projects y los Issues.
    
Mediante los Boards se configurará y mantendrá el tablero Kanban ya descrito previamente, que constará de las siguientes columnas:
- TO DO: contendrá las tareas sin empezar
- DOING: contendrá las tareas en curso
- TO VALIDATE: contendrá las tareas cuya implementación haya finalizado pero estén pendientes de pruebas
- DONE: contendrá las tareas finalizadas y probadas exitosamente
    
Para que la explicación previa resulte más visual, el Kanban Board tendría este aspecto:
    
![](https://i.imgur.com/gMwRGJS.png)
    
Naturalmente, las tareas mostradas no son finales y sirven a modo de ejemplo.

Otras alternativas como un tablón físico ni siquiera han sido consideradas por sus claras desventajas con respecto a un tablón online disponible desde cualquier parte y que puede usarse de forma colaborativa.
</div>