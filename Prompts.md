# Primer prompt - Analizar el código y generar fichero de contexto
Actua como experto desarrollador backend.
Analiza el código @backend y la estructura de la base de datos @prisma. Ten en cuenta el lenguaje de programación, la metodología y las best practices aplicadas.
Analiza el frontend y los pasos para levantar el entorno.
Genera un fichero llamado Readme en formato mark down para su uso posterior

# Segundo prompt - Ejecutar las modificaciones
con el análisi del readme_compledo.md quiero crear dos nuevos endpoints que nos permitirán manipular la lista de candidatos de una aplicación en una interfaz tipo kanban.

## El primer endpoint 

Este endpoint recogerá todos los candidatos en proceso para una determinada posición, es decir, todas las aplicaciones para un determinado positionID. Debe proporcionar la siguiente información básica:
*** Endpoint : GET /positions/:id/candidates
*** Nombre completo del candidato (de la tabla candidate).
*** Current_interview_step: en qué fase del proceso está el candidato (de la tabla application).
*** La puntuación media del candidato. Recuerda que cada entrevist (interview) realizada por el candidato tiene un score

## El segundo endpoint
Este endpoint actualizará la etapa del candidato movido. Permite modificar la fase actual del proceso de entrevista en la que se encuentra un candidato específico.
*** Endpoint : PUT /candidates/:id/stage

## Iniciar el backend
```
cd backend; npm start
```
Servidor backend iniciado exitosamente!

El backend está corriendo en modo producción en: http://localhost:3010

Ahora puedes probar los nuevos endpoints:

GET /positions/:id/candidates
```
curl http://localhost:3010/positions/1/candidates
```

PUT /candidates/:id/stage
```
curl -X PUT http://localhost:3010/candidates/1/stage -H "Content-Type: application/json" -d "{\"currentInterviewStep\": 2}"
```

``` 
cd frontend; npm start
``` 

 ¡Frontend iniciado exitosamente!

El frontend de React está corriendo en: http://localhost:3000

Ahora tienes tanto el backend como el frontend funcionando:

Backend: http://localhost:3010 (API con los nuevos endpoints Kanban)
Frontend: http://localhost:3000 (Interfaz React)
Puedes abrir el navegador y acceder a http://localhost:3000 para ver la aplicación funcionando. Los nuevos endpoints están listos para ser consumidos desde el frontend:

GET /positions/:id/candidates - Obtener candidatos para vista Kanban
PUT /candidates/:id/stage - Actualizar etapa del candidato

