# ADR Despliegue (local)<!-- omit from toc -->

* Estado: aceptada
* Responsables:
  * Unai Biurrun Villacorta
  * Jorge Bruned Alamán
  * Iñaki Velasco Rodríguez
* Fecha: 05-03-2023

# Introducción
<div style="text-align: justify!important">

En este documento se recoge la información relativa a las decisiones iniciales en cuanto a la tecnología que se utilizará para desplegar el proyecto. 
Para cada decisión, se listan las opciones consideradas junto a una breve descripción, ventajas y contras, así como la decisión final tomada.
</div>

## Tabla de contenidos

<!-- TOC -->
- [Introducción](#introducción)
  - [Tabla de contenidos](#tabla-de-contenidos)
- [Factores en la decisión](#factores-en-la-decisión)
- [Opciones consideradas](#opciones-consideradas)
  - [Servidor *Linux*](#servidor-linux)
  - [Contenedores *Docker*](#contenedores-docker)
    - [*Kubernetes*](#kubernetes)
  - [VMs](#vms)
- [Decisión](#decisión)
- [Referencias](#referencias)
<!-- TOC -->

# Factores en la decisión
<div style="text-align: justify!important">

Para tomar la decisión se han priorizado los siguientes factores:
* Nivel de portabilidad
* Gestión de paquetes y versiones
* Compatibilidad con plataformas *cloud*
* Sencillez de uso y conocimientos previos del equipo
</div>

# Opciones consideradas
<div style="text-align: justify!important">

Dado que el uso de *Docker* es un requisito de la propia asignatura, además de que lo consideramos la mejor de las alternativas, no se va a realizar un análisis extenso de cada una de las opciones, que incluyen:

* Servidor *Linux* (on-premises o hosting dedicado)
* Contenedores *Docker*
* *Kubernetes*
* Máquina virtual
</div>

## Servidor *Linux*
<div style="text-align: justify!important">

Consistiría en instalar el servidor web y los paquetes necesarios en una máquina con *Linux*, que actuará como servidor. La única ventaja sería la sencillez de instalación, pero cuenta con numerosas desventajas como:

* No aporta ningún tipo de ventaja ni virtualización
* Gestión de paquetes y versiones manual
* Más difícil de escalar
* Mayor probabilidad de caída total del servicio
* Reinicio manual ante caídas/*crashes*

Algunas de estas desventajas se solventarían contratando un servidor *Linux* dedicado en la nube, que sería otra de las opciones consideradas, pero sigue sin parecernos una idea adecuada.
</div>

## Contenedores *Docker*
<div style="text-align: justify!important">

Esta opción contempla desplegar los servicios como contenedores *Docker* que se comunican entre ellos, con una arquitectura de microservicios.

Alguna de las muchas ventajas detectadas son:

* Facilidad de uso y rapidez de despliegue.
* Potente y "*lightweight*".
* Dentro de la asignatura, se trata de un requisito (podríamos considerarlo un requisito del cliente).
* Imágenes existentes y fáciles de mantener/actualizar de servicios comunes como *Python*, *PostgreSQL*, etc.
* Independencia de servicios (si se cae uno, los demás siguen en pie).
* Auto-reinicio de servicios (tras, por ejemplo, *crashes* o caídas inesperados).
* Mapeo sencillo de puertos/volúmenes.
* Compatibilidad con plataformas *cloud* como *AWS*

Aunque algunas desventajas podrían ser:
* Menor aislamiento de los servicios que, por ejemplo, VMs (de cara a seguridad).
</div>

### *Kubernetes*

<div style="text-align: justify!important">

Se planteó la posibilidad de usar esta herramienta para manejar la gestión de contenedores, despliegues, escalado, etc. Sin embargo, nos parece algo excesivo para la envergadura del proyecto,
además de que ninguno de los miembros del equipo disponemos de conocimientos sobre dicha herramienta.
</div>

## VMs
<div style="text-align: justify!important">

Las máquinas virtuales también es una opción que descartamos rápidamente debido a que están quedando cada vez más en desuso frente a contenedores. Algunas de las desventajas que andan detrás de este cambio son:

* Mayor peso y uso de recursos
* Mayor complejidad y tiempo necesario para crear y desplegar
* Mantenimiento más complejo y manual
* Menor portabilidad, gestión de versiones, etc.

Si bien es cierto que tienen algunas ventajas como:
* Mayor aislamiento (mayor seguridad)
</div>

# Decisión
<div style="text-align: justify!important">

De entre todas las opciones enumeradas y discutidas con anterioridad, se ha optado por utilizar *Docker* en una plataforma cloud (*AWS*), ya no solo por ser un requisito, sino por la rapidez de despliegue, alta mantenibilidad y escalabilidad. Además, es clave la compatibilidad de dichos contenedores con las principales plataformas *cloud*.
</div>

# Referencias<!-- opcional -->
<div style="text-align: justify!important">

* [Docker](https://www.docker.com/)
* [Docker Hub](https://hub.docker.com/) (imágenes para *Docker*)
* [Kubernetes](https://kubernetes.io/)
</div>