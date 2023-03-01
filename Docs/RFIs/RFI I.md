# Documento RFI I

<div style="text-align: justify!important">

En este documento se recoge la información relativa a las decisiones iniciales en cuanto a organización del equipo, metodologías, herramientas y tecnologías seleccionadas. Para cada decisión, se listan las opciones consideradas junto a una breve descripción, ventajas y contras, así como la decisión final argumentada.
</div>
    
## Tabla de contenidos

[TOC]
    
# Introducción

El producto software solicitado se trata de una aplicación web que permita crear votaciones, las cuales podrán ser completadas por el resto de usuarios. 

# Estructura organizacional
<div style="text-align: justify">
    
Existe una gran variedad de estructuras organizativas posibles. Algunas de estas son:
- Estructura vertical
- Estructura horizontal
- Funcional
- En divisiones
- Matricial
- Híbrida

La estructura organizacional escogida consiste en una estructura de tipo horizontal o plana. La principal motivación detrás de esta elección es la gran flexibilidad que aporta, además de facilitar colaboración entre miembros del equipo. Además, esta estructura se ajusta perfectamente a una *start-up*, como es nuestro caso, donde todos los miembros tienen un gran compromiso y nivel de responsabilidad.

Adicionalmente, dada la disparidad de horario laboral de los integrantes de la organización, resulta especialmente interesante disponer de flexibilidad para trabajar. Del mismo modo, consideramos que los conocimientos de los distintos miembros están bastante equiparados, siendo esto nuevamente favorable para adoptar una estructura plana u horizontal.
    
Por último, teniendo en cuenta la escasa complejidad y alcance del producto a desarrollar, así como la corta duración del desarrollo, no consideramos que sea necesaria una estructura más sofisticada.
</div>
    
## Roles
<div style="text-align: justify">
    
Si bien la estructura elegida es horizontal, consideramos interesante y positiva la asignación del rol de jefe o responsable, que podría ser más típico de una organización vertical.

Sin embargo, esta estructura no será rígida en absoluto; el rol de jefe no actúa como un jefe tradicional sino que actúa a modo de representante y lleva la iniciativa del proyecto, dirigiendo al resto de integrantes hacia los objetivos de la organización. También es el encargado de comunicarse con el docente.

Con el objetivo de adquirir el mayor grado de competencias posible, se opta por rotar el rol de jefe periódicamente en cada entrega, de tal modo que todos los integrantes puedan ejercer dicho rol. Por tanto, la distribución de roles no es estática.
</div>

## Miembros
<div style="text-align: justify">
    
Los miembros del equipo, que irán rotando en el rol de responsable, son los siguientes:

- Unai Biurrun
- Jorge Bruned
- Iñaki Velasco
</div>

# Metodología de desarrollo
<div style="text-align: justify">
    
Vamos a utilizar nuestra propia metodología empleando los elementos que más útiles nos parecen para nuestro caso de otras metodologías ágiles como Scrum o Kanban. El objetivo y motivación de esta decisión es que la metodología se adapte a nuestra situación concreta, seleccionando lo que más nos interesa de otras metodologías ágiles ampliamente conocidas. A su vez, el motivo para elegir una metodología ágil es, principalmente, su adaptabilidad al cambio de requisitos.
    
Así, definiremos periodos de trabajo en los que desarrollar un conjunto predeterminado de tareas (similar a los [*sprints* de *Scrum*](https://www.atlassian.com/agile/scrum/sprints#:~:text=What%20are%20sprints%3F-,A%20sprint%20is%20a%20short%2C%20time%2Dboxed%20period%20when%20a,better%20software%20with%20fewer%20headaches.)) y mantendremos un tablero [Kanban](https://www.atlassian.com/agile/kanban#:~:text=In%20Japanese%2C%20kanban%20literally%20translates,in%20a%20highly%20visual%20manner.) en el que actualizaremos su estado. Para llevar a cabo este proceso se emplean herramientas de gestión que se explicarán más adelante.
    
La razón por la que se ha optado por una metodología ágil es, no solo por la flexibilidad que ofrece, sino porque permite generar entregas continuas incrementando gradualmente la funcionalidad, lo cual se ajusta a la planificación de la asignatura. Además, de forma inicial, el producto a desarrollar no está claramente definido, de modo que consideramos importante adoptar una metodología que nos permita adaptarnos fácilmente a posibles cambios en los requisitos.
</div>

## Reuniones
<div style="text-align: justify">
    
Se ha decidido realizar una reunión semanal debido a tres puntos principales:
- El tamaño del equipo y la función de cada miembro: al ser un equipo reducido y con funciones similares, no se considera correcto realizar reuniones diarias ya que con los comentarios y discusiones rápidas entre miembros es suficiente para resolver los problemas cotidianos.
- El estado actual del proyecto: debido a que se trata de un inicio de proyecto en el que se está comenzando con el desarrollo, no se ve necesario un seguimiento mayor al semanal.
- Tablero Kanban: la existencia de este tablero hace que sea más fácil conocer el estado de las tareas y desarrollo general sin ser necesario recurrir a reuniones diarias.
    
Se han barajado otro tipo de reuniones como las (muy extendidas) [*dailys*](https://www.scrum.org/resources/what-is-a-daily-scrum), pero como se ha explicado en los puntos anteriores no se consideran necesarias.
</div>

## Buenas prácticas
<div style="text-align: justify">
    
Debido a la similitud en cuanto al origen académico y trayectoria de los tres integrantes del grupo, todos ellos provenientes del Grado en Ingeniería Informática y con experiencia en el campo, se ha decidido desarrollar, gestionar y desplegar la aplicación conforme a buenas prácticas establecidas previamente.
 
Dado que se emplearán lenguajes de programación diferentes para los distintos componentes del proyecto, no es posible definir un solo conjunto de buenas prácticas. No obstante, es posible definir diferentes conjuntos de las mismas para cada componente.
    
En primer lugar, para el Backend (desarrollado en Python) se utilizará la guía de estilo [PEP8](https://peps.python.org/pep-0008/), por su gran popularidad e integración nativa con IDEs como PyCharm.
</div>
    
### Buenas prácticas de programación
<div style="text-align: justify">

Al margen de todo lo mencionado previamente, a nivel técnico también se aplicarán una serie de buenas prácticas, como por ejemplo:
- Se empleará el inglés a la hora de programar, dada su popularidad en el ámbito de la programación. Esto facilitará la mantenibilidad y las posibles expansiones del proyecto, incluso como una alternativa *open source* si se diera el caso.
- Se seguirán las buenas prácticas y convenciones asociadas a cada una de las tecnologías, lenguajes, herramientas y *frameworks* utilizados, ya sea en cuanto a estructura del código, patrones de diseño, *naming conventions*, etc.

El objetivo de estas buenas prácticas es generar un código de calidad y con una buena mantenibilidad, además de propiciar un mejor proceso de desarrollo y mejorar la comprensión del código por personas ajenas.
</div>

# Herramientas de gestión
<div style="text-align: justify">

Con objetivo de desarrollar el proyecto de forma óptima y procurar una distribución adecuada de las tareas y objetivos, se empleará el conjunto de herramientas que GitHub provee para ello. 
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

# Gestión de la configuración
<div style="text-align: justify">
    
Con el objetivo de asegurar la calidad del producto, integrar de manera correcta el desarrollo de los miembros del equipo y asegurar un despliegue y un control de versiones correcto, se hará uso de *GitHub* en cuanto a herramienta de gestión de configuración.

Se ha elegido esta herramienta sobre otras como *GitLab* debido al conocimiento previo de la misma del equipo al completo y a que ofrece otros aspectos mencionados previamente como los tableros (GitHub Projects) o la sección de Issues.
    
Se puede acceder al mismo a través del siguiente [enlace al repositorio](https://github.com/jbruned/Poll-App).
</div>

# Tecnologías
<div style="text-align: justify">

Se realizará el análisis pertinente para decidir que tecnología se utilizará en cada aspecto necesario desde el inicio hasta el final del proyecto, dando lugar a *ADR*s que recojan las opciones consideradas, ventajas y desventajas de cada una, alternativa escogida y justificación de dicha elección.
</div>

## Backend
<div style="text-align: justify">

Uno de los puntos claves a decidir para el desarrollo del proyecto son las tecnologías de desarrollo del backend de la aplicación.
    
Se ha decidido hacer uso de Python como lenguaje principal junto al paquete [Flask](https://flask.palletsprojects.com/en/2.2.x/) para poder crear la aplicación web de manera sencilla. Nos hemos decantado por esta combinación frente a otros lenguajes como *Java*, que en ocasiones es menos eficiente y menos portable, y frente a otras librerías peor documentadas y con menor soporte de la comunidad por ser menos populares. Además, y como se comentará más adelante en [Base de datos](#Base-de-datos), el conjunto de ambas herramientas facilitará la conexión y la interoperabilidad con la base de datos.
</div>

### Base de datos
<div style="text-align: justify">

Teniendo en cuenta la disponibilidad de kits de herramientas en Python como SQLAlchemy, ya integrados con Flask ([Flask-SQLAlchemy](https://python-adv-web-apps.readthedocs.io/en/latest/flask_db1.html)), la sencillez de uso y el conocimiento previo por parte de los miembros del equipo, se ha decidido hacer uso de [PostgreSQL](https://www.postgresql.org/) como sistema gestor de bases de datos. 
    
Como otros factores determinantes, el hecho de que PostgreSQL sea Open Source y que permita la expansión del proyecto en caso de necesitar desplegar la base de datos con herramientas ya conocidas por el equipo como Heroku ([gratuito con GitHub Student](https://www.heroku.com/github-students)), han hecho que sea la decisión final.
</div>

### Frontend
<div style="text-align: justify">

En el lado del cliente, se utilizarán, naturalmente, HTML, CSS y JavaScript al tratarse de una aplicación web. Por encima de ellos, se utilizarán librerías como Bootstrap para CSS y React para JavaScript. En el primer caso, esta conocida librería nos facilitará el diseño de una página estética y *responsive* de una forma sencilla y rápida. Por otro lado, *React* nos permitirá desarrollar una interfaz de usuario interactiva, así como los diferentes componentes de la GUI. Todo esto, de forma muy sencilla y fácilmente integrable con las llamadas *API* gracias a los *fetch* de *JavaScript*. Se han elegido estas librerías frente a otras, en ambos casos, gracias a su simplez, documentación y gran popularidad, algo muy importante a la hora de resolver problemas comunes o encontrar documentación o códigos de ejemplo.
</div>

## Despliegue
<div style="text-align: justify">

Principalmente con los propósitos de hacer el producto fácilmente portable y lograr una continuidad de servicio del proyecto, se utilizará Docker. 
    
El objetivo es crear contenedores independientes para cada servicio y hacer que trabajen al unísono mediante un [Docker Compose](https://docs.docker.com/compose/). Este paradigma basado en microservicios permite que, aunque alguno de ellos caiga (por ejemplo, la base de datos), el resto sigan funcionando (en este caso, el servidor web podría mostrar un mensaje de error en operaciones que impliquen a la base de datos, en lugar de caer el servicio al completo).
    
El motivo de elección de Docker frente a otros sistemas es su facilidad de uso y a los conocimientos de los que disponemos y que ampliaremos a lo largo de la asignatura. De este modo no será necesario invertir más tiempo de formación en sistemas adicionales que cumplan el mismo papel. También es muy conveniente la gran popularidad del servicio y la enorme cantidad de imágenes disponibles de forma pública y que están listos para ser instalados.
</div>
