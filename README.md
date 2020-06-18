# Tentative Courses

## Descripción

Este es un ejercicio a realizar como parte de la entrevista técnica para la posición de Software Engineer dentro de Nulinga.

Queremos que te luzcas, que apliques todos tus conocimientos y creatividad.

Lo importante del ejercicio no es la solución si no que nos cuentes cómo llegaste y las decisiones que fuiste tomando.

Pensá que no programamos para computadoras si no para otras personas.

No hay una única solución a la hora de diseñar, hay trade-offs. Y lo que ganás en una cosa perdés en otra. Que tengas conciencia de esos trade-offs es lo que buscamos.

### Condiciones iniciales

Se tiene una lista de estudiantes los cuales cada uno tiene asignado:

* Una modalidad, el cuál puede ser Grupal o Individual
* Un nivel, el cuál puede ser Beginner, Pre-Intermediate, Intermediate, Upper-Intermediate y Advanced
* Una lista de horarios que podrían tomar un curso. Los cuales van de Lunes a Viernes de 9 a 19 hs.
  * Ejemplo:
  * Lunes 17:00
  * Miércoles 9:00
  * Jueves 15:00

Se tiene una lista de docentes los cuales tienen:

* Una lista de horarios de disponibilidad para tomar cursos. Los cuales van de Lunes a Viernes de 9 a 19 hs.
  * Ejemplo:
  * Lunes 17:00
  * Miércoles 9:00
  * Jueves 15:00

### Problema

Se desea que se obtener una lista de cursos posibles.
El curso posible tiene que tener:

* Un docente.
* Un nivel.
* Un horario (día y hora)
* Una lista de inscriptos.

Las condiciones para asignar curso posible son las siguientes:

* Los cursos tienen que respetar el horario que el docente tiene disponible.
* Los cursos tienen que respetar el horario disponible de los estudiantes.
* Todos los inscriptos en el curso tienen que tener el mismo nivel.
* Los cursos grupales pueden contener hasta 6 inscriptos.
* Los cursos individuales sólo pueden contener 1 inscripto.
* Todos los inscriptos tienen que la misma modalidad. Ej. Si un estudiante eligió modalidad individual no se los puede inscribir en curso grupal.

Estas condiciones pueden ir sufriendo modificaciones con el tiempo.

### Bonus

Esto no es necesario como requisito para cumplir con el ejercicio pero si lo resolviste rápido, podés pensar como incorporar estos nice to have.

Estaría bueno:

* Tener una lista de los estudiantes que no pudieron ser asignados porque no pudieron cumplir alguna de las condiciones.
* Que al agrupar el curso grupal y hacer el match de horarios pueda matchear también los que difieren en 1 hora o X horas configurable.
  * Ejemplo:
  * Jose Montoto es Beginner y uno de sus horarios diponibles es Jueves 15:00
  * Elena Nito es Beginner y uno de sus horarios disponibles es Jueves 16:00
  * Esteban Quito es Beginner y uno de sus horarios disponibles es Jueves 14:00
  * Si configuro una diferencia máxima de 1 hora. Espero que se arme un curso tentativo para los 3 inscriptos el Jueves a las 15:00 y marcar las inscripciones de Elena y Esteban que necesitan confirmación de hora.


## Solución

### Cómo funciona

Se utiliza la lista de estudiantes para inizializar la clase `Student`. Cada estudiante requiere:

* `id`: Identificador del estudiante. No puede contener guiones medios ('-').
* `level`: Nivel de idioma. Opciones: `BEGINNER`, `PRE_INTERMEDIATE`, `INTERMEDIATE`, `UPPER_INTERMEDIATE`, `ADVANCED`.
* `type`: Tipo de cursos. Opciones: `INDIVIDUAL` o `GROUP`.
* `availability`: Lista de horarios en formato del módulo `Schedulable`. String formado por las primeras 3 letras del dia de semana en inglés y 4 digitos para la hora. Se asumen cursos por horas enteras y solo en horarios en punto, de 8 a 20. Ejemplos: 'MON0800', 'FRI1500'.
* `priority`(opcional): número entero cuyo objetivo es favorecer la asignación del alumno. A menor número, mejor posibilidad de asignación. Default: 5.

Con la lista de profesores se inicializan objetos de la clase `Teacher`. Cada uno requiere:

* `id`: Identificador del profesor. No puede contener guiones medios ('-').
* `levels`: Lista de niveles de idioma que el profesor puede dictar. Mismas opciones que alumnos.
* `max_courses`: Número entero de cantidad de cursos que el profesor puede tomar como máximo.
* `availability`: Lista de horarios en formato del módulo `Schedulable`. Mismas condiciones que alumnos.
* `priority`(opcional): número entero cuyo objetivo es favorecer la asignación del profesor. A menor número, mejor posibilidad de asignación. Default: 5

El objeto que realiza la asignación de cursos es el `CourseScheduler`. Debe crearse una instancia del mismo para cada lote de trabajo y no puede resetearse. La API del objeto esta compuesta por los siguientes metodos:

* Configuración del objeto:
  * `add_student`: Acepta un objeto `Student`.
  * `bulk_add_students`: Acepta una lista de objetos `Student`.
  * `add_teacher`: Acepta un objeto `Teacher`.
  * `bulk_add_teachers`: Acepta una lista de objetos `Teacher`.
* Ejecución de la asignación:
  * `schedule_courses` (opcional): Acepta una lista de `scheduling_orders` (descripta abajo) y devuelve una lista de objetos `Course` que contienen la información del curso. Este objeto puede imprimirse para ver el detalle del curso.
* Post-ejecución:
  * `unassigned_students`: Entrega una lista de objetos `Students` no asignados a ningún curso.

#### scheduling_orders

La asignación de cursos se realiza en loops predeterminados de `scheduling_orders` pero si se entrega a `schedule_courses` una lista de ordenes, esta se ejecuta al principio en el orden recibido. Las ordenes se entregan en forma de lista y cada una es un hash table con las siguientes keys:

* `student_type`: Coincide con el `type` del alumno. Obligatorio si se entrega una orden. Se asignan solo alumnos de este tipo. Solo acepta un tipo por orden. Por default los grupos tienen prioridad.
* `level`: Coincide con el `level` del alumno. Obligatorio si se entrega una orden. Se asignan solo alumnos de este tipo. Solo acepta un nivel por orden. Por default los intermedios tienen prioridad.
* `course_size` (opcional): Número entero de alumnos limite para cursos grupales. Por default es 6.
* `tolerance` (opcional): Número entero de horas para el rango de coincidencia entre un alumno y un curso. Ej: si `tolerance: 1` un alumno con availability 'MON1400' coincide con cursos en horarios 'MON1300' y 'MON1500'. No extiende los limites de 8 a 20 hs.

### Tecnología

* Lenguaje: Ruby 2.6.6
* Linter: rubocop 0.85.1 (limitado para archivos de testing)
* Testing: rspec 3.9

### Un saludo

A los amigos que me quieren y a los hinchas de River que me están mirando.
