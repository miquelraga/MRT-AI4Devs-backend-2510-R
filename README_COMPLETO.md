# LTI - Sistema de Seguimiento de Talento (Talent Tracking System)

## 📋 Descripción del Proyecto

LTI es una aplicación full-stack diseñada para gestionar el proceso de reclutamiento y seguimiento de candidatos. El sistema permite administrar candidatos, sus perfiles, experiencia laboral, educación, y realizar un seguimiento completo del proceso de entrevistas.

## 🏗️ Arquitectura del Proyecto

### **Stack Tecnológico**

#### Backend
- **Lenguaje**: TypeScript 4.9.5
- **Runtime**: Node.js
- **Framework**: Express.js 4.19.2
- **ORM**: Prisma 5.13.0
- **Base de Datos**: PostgreSQL
- **Testing**: Jest 29.7.0
- **Validación**: Custom validators
- **File Upload**: Multer 1.4.5
- **Documentación API**: Swagger (swagger-jsdoc, swagger-ui-express)

#### Frontend
- **Framework**: React 18.3.1
- **Lenguaje**: TypeScript 4.9.5
- **UI Framework**: React Bootstrap 2.10.2, Bootstrap 5.3.3
- **Routing**: React Router DOM 6.23.1
- **Componentes**: React Bootstrap Icons, React Datepicker
- **Build Tool**: React Scripts 5.0.1

#### DevOps
- **Containerización**: Docker & Docker Compose
- **Base de Datos**: PostgreSQL (containerizada)
- **Variables de Entorno**: dotenv

---

## 📁 Estructura del Proyecto

```
AI4Devs-backend-2510-R/
├── backend/                          # Código del servidor
│   ├── src/
│   │   ├── index.ts                  # Punto de entrada del servidor
│   │   ├── application/              # Capa de aplicación
│   │   │   ├── validator.ts          # Validaciones de datos
│   │   │   └── services/
│   │   │       ├── candidateService.ts      # Lógica de negocio de candidatos
│   │   │       └── fileUploadService.ts     # Servicio de subida de archivos
│   │   ├── domain/                   # Capa de dominio (modelos)
│   │   │   └── models/
│   │   │       ├── Candidate.ts
│   │   │       ├── Education.ts
│   │   │       ├── WorkExperience.ts
│   │   │       ├── Resume.ts
│   │   │       ├── Application.ts
│   │   │       ├── Position.ts
│   │   │       ├── Interview.ts
│   │   │       ├── InterviewFlow.ts
│   │   │       ├── InterviewStep.ts
│   │   │       ├── InterviewType.ts
│   │   │       ├── Company.ts
│   │   │       └── Employee.ts
│   │   ├── presentation/             # Capa de presentación
│   │   │   └── controllers/
│   │   │       └── candidateController.ts
│   │   └── routes/                   # Definición de rutas
│   │       └── candidateRoutes.ts
│   ├── prisma/                       # Configuración de Prisma ORM
│   │   ├── schema.prisma             # Esquema de base de datos
│   │   ├── seed.ts                   # Datos de prueba
│   │   └── migrations/               # Migraciones de BD
│   ├── package.json
│   ├── tsconfig.json
│   ├── jest.config.js
│   └── api-spec.yaml                 # Especificación OpenAPI
├── frontend/                         # Código del cliente
│   ├── src/
│   │   ├── App.tsx                   # Componente principal
│   │   ├── index.tsx                 # Punto de entrada
│   │   ├── components/               # Componentes React
│   │   │   ├── AddCandidateForm.js
│   │   │   ├── FileUploader.js
│   │   │   └── RecruiterDashboard.js
│   │   └── services/
│   │       └── candidateService.js   # Llamadas a API
│   ├── public/
│   └── package.json
├── docker-compose.yml                # Configuración de Docker
├── package.json                      # Dependencias raíz
├── .env                              # Variables de entorno (no incluido en repo)
└── README.md

```

---

## 🎯 Arquitectura y Patrones de Diseño

### **Arquitectura por Capas (Layered Architecture)**

El backend sigue una arquitectura por capas bien definida:

1. **Presentation Layer** (`presentation/`)
   - Controllers que manejan las peticiones HTTP
   - Transformación de datos de entrada/salida
   - Manejo de códigos de estado HTTP

2. **Application Layer** (`application/`)
   - Servicios que orquestan la lógica de negocio
   - Validadores de datos
   - Servicios de aplicación (fileUploadService, candidateService)

3. **Domain Layer** (`domain/`)
   - Modelos de dominio con lógica de negocio
   - Entidades del sistema
   - Reglas de negocio encapsuladas

4. **Infrastructure Layer** (Prisma)
   - Acceso a datos mediante Prisma ORM
   - Gestión de conexiones a base de datos

### **Patrones Implementados**

- **Repository Pattern**: A través de Prisma Client
- **Service Layer Pattern**: Separación de lógica de negocio en servicios
- **Dependency Injection**: Prisma Client inyectado en el middleware
- **MVC Pattern**: Separación clara entre Modelos, Vistas (frontend) y Controladores

### **Best Practices Aplicadas**

✅ **TypeScript**: Tipado estático para mayor seguridad
✅ **Async/Await**: Manejo moderno de operaciones asíncronas
✅ **Error Handling**: Manejo centralizado de errores
✅ **CORS Configuration**: Configuración segura de CORS
✅ **Environment Variables**: Configuración mediante variables de entorno
✅ **Database Migrations**: Control de versiones de esquema de BD
✅ **ORM Usage**: Abstracción de acceso a datos con Prisma
✅ **RESTful API**: Endpoints siguiendo convenciones REST
✅ **Code Organization**: Estructura modular y escalable

---

## 🗄️ Modelo de Base de Datos

### **Entidades Principales**

#### **Candidate** (Candidato)
- Información personal del candidato
- Relaciones: Education, WorkExperience, Resume, Application

#### **Education** (Educación)
- Formación académica del candidato
- Institución, título, fechas

#### **WorkExperience** (Experiencia Laboral)
- Experiencia profesional del candidato
- Empresa, posición, descripción, fechas

#### **Resume** (CV)
- Documentos del candidato
- Ruta del archivo, tipo, fecha de subida

#### **Company** (Empresa)
- Empresas del sistema
- Relaciones: Employee, Position

#### **Position** (Posición)
- Vacantes disponibles
- Descripción, requisitos, salario, tipo de empleo
- Relación con flujo de entrevistas

#### **Interview** (Entrevista)
- Registro de entrevistas realizadas
- Fecha, resultado, puntuación, notas
- Relación con Application, InterviewStep, Employee

#### **Application** (Aplicación)
- Solicitud de candidato a posición
- Estado en el proceso de entrevistas
- Fecha de aplicación, notas

#### **InterviewFlow** (Flujo de Entrevistas)
- Define el proceso de entrevistas
- Compuesto por múltiples InterviewSteps

#### **InterviewStep** (Paso de Entrevista)
- Etapa específica en el flujo de entrevistas
- Orden, tipo de entrevista

#### **InterviewType** (Tipo de Entrevista)
- Tipos de entrevistas (técnica, HR, cultural, etc.)

#### **Employee** (Empleado)
- Personal de la empresa que realiza entrevistas
- Rol, estado activo

### **Relaciones**

```
Candidate 1---N Education
Candidate 1---N WorkExperience
Candidate 1---N Resume
Candidate 1---N Application

Company 1---N Employee
Company 1---N Position

Position N---1 InterviewFlow
Position 1---N Application

Application N---1 Candidate
Application N---1 Position
Application N---1 InterviewStep (current)
Application 1---N Interview

Interview N---1 Application
Interview N---1 InterviewStep
Interview N---1 Employee

InterviewFlow 1---N InterviewStep
InterviewStep N---1 InterviewType
```

---

## 🚀 Instalación y Configuración

### **Prerrequisitos**

- Node.js (v16 o superior)
- npm o yarn
- Docker y Docker Compose
- Git

### **1. Clonar el Repositorio**

```bash
git clone <repository-url>
cd AI4Devs-backend-2510-R
```

### **2. Configurar Variables de Entorno**

Crear un archivo `.env` en la raíz del proyecto:

```env
# Database Configuration
DB_USER=LTIdbUser
DB_PASSWORD=D1ymf8wyQEGthFR1E9xhCq
DB_NAME=LTIdb
DB_PORT=5432
DB_HOST=localhost

# Database URL for Prisma
DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
```

### **3. Levantar la Base de Datos con Docker**

```bash
# Iniciar PostgreSQL en Docker
docker-compose up -d

# Verificar que el contenedor está corriendo
docker ps
```

### **4. Instalar Dependencias**

#### Backend

```bash
cd backend
npm install
```

#### Frontend

```bash
cd frontend
npm install
```

### **5. Configurar Base de Datos con Prisma**

```bash
cd backend

# Generar el cliente de Prisma
npx prisma generate

# Ejecutar migraciones
npx prisma migrate dev

# (Opcional) Poblar con datos de prueba
npx ts-node prisma/seed.ts
```

### **6. Compilar el Backend**

```bash
cd backend
npm run build
```

---

## ▶️ Ejecución del Proyecto

### **Modo Desarrollo**

#### Terminal 1: Backend (modo desarrollo)

```bash
cd backend
npm run dev
```

El servidor backend estará disponible en: **http://localhost:3010**

#### Terminal 2: Frontend (modo desarrollo)

```bash
cd frontend
npm start
```

El frontend estará disponible en: **http://localhost:3000**

### **Modo Producción**

#### Backend

```bash
cd backend
npm run build
npm start
```

#### Frontend

```bash
cd frontend
npm run build
# Servir la carpeta build con un servidor web estático
```

---

## 📡 API Endpoints

### **Candidatos**

#### POST /candidates
Crear un nuevo candidato

**Request Body:**
```json
{
  "firstName": "Juan",
  "lastName": "Pérez",
  "email": "juan.perez@example.com",
  "phone": "123456789",
  "address": "Calle Principal 123, Madrid",
  "educations": [
    {
      "institution": "Universidad Complutense",
      "title": "Ingeniería Informática",
      "startDate": "2015-09-01",
      "endDate": "2019-06-30"
    }
  ],
  "workExperiences": [
    {
      "company": "Tech Company",
      "position": "Software Engineer",
      "description": "Desarrollo de aplicaciones web",
      "startDate": "2019-07-01",
      "endDate": "2023-12-31"
    }
  ],
  "cv": {
    "filePath": "uploads/cv-juan-perez.pdf",
    "fileType": "application/pdf"
  }
}
```

**Response:** 201 Created
```json
{
  "message": "Candidate added successfully",
  "data": {
    "id": 1,
    "firstName": "Juan",
    "lastName": "Pérez",
    "email": "juan.perez@example.com",
    ...
  }
}
```

#### GET /candidates/:id
Obtener candidato por ID

**Response:** 200 OK
```json
{
  "id": 1,
  "firstName": "Juan",
  "lastName": "Pérez",
  "email": "juan.perez@example.com",
  "phone": "123456789",
  "address": "Calle Principal 123, Madrid",
  "education": [...],
  "workExperience": [...],
  "resumes": [...]
}
```

#### PUT /candidates/:id/stage
Actualizar la etapa del candidato en el proceso de entrevistas

**Request Body:**
```json
{
  "currentInterviewStep": 2,
  "notes": "Candidato pasó la entrevista técnica"
}
```

**Response:** 200 OK
```json
{
  "message": "Candidate stage updated successfully",
  "data": {
    "id": 5,
    "candidateId": 1,
    "currentInterviewStep": 2,
    "candidate": {...},
    "interviewStep": {...},
    "position": {...}
  }
}
```

### **Posiciones**

#### GET /positions/:id/candidates
Obtener todos los candidatos en proceso para una posición (vista Kanban)

**Response:** 200 OK
```json
{
  "positionId": 1,
  "totalCandidates": 3,
  "candidates": [
    {
      "candidateId": 1,
      "fullName": "Juan Pérez",
      "currentInterviewStep": 1,
      "currentInterviewStepName": "Entrevista Técnica",
      "averageScore": 8.5,
      "applicationId": 5
    }
  ]
}
```

### **Aplicaciones**

#### PUT /applications/:id/stage
Actualizar la etapa de una aplicación específica

**Request Body:**
```json
{
  "currentInterviewStep": 3,
  "notes": "Aprobado para entrevista final"
}
```

**Response:** 200 OK
```json
{
  "message": "Application stage updated successfully",
  "data": {...}
}
```

### **File Upload**

#### POST /upload
Subir archivos (CV)

**Content-Type:** multipart/form-data

---

## 📖 Documentación Detallada de API

Para información detallada sobre los endpoints de la interfaz Kanban, consulta [API_ENDPOINTS_KANBAN.md](API_ENDPOINTS_KANBAN.md)

Este documento incluye:
- Ejemplos completos de peticiones y respuestas
- Códigos de error detallados
- Casos de uso prácticos
- Ejemplos de código en JavaScript/cURL
- Flujos de trabajo completos

---

## 🧪 Testing

### **Backend**

```bash
cd backend
npm test
```

Configuración de Jest en `backend/jest.config.js`

### **Frontend**

```bash
cd frontend
npm test
```

---

## 🛠️ Scripts Disponibles

### **Backend**

| Script | Comando | Descripción |
|--------|---------|-------------|
| dev | `npm run dev` | Inicia el servidor en modo desarrollo con hot-reload |
| build | `npm run build` | Compila TypeScript a JavaScript |
| start | `npm start` | Inicia el servidor compilado |
| start:prod | `npm run start:prod` | Compila y ejecuta en producción |
| test | `npm test` | Ejecuta los tests con Jest |
| prisma:generate | `npm run prisma:generate` | Genera el cliente de Prisma |
| prisma:init | `npm run prisma:init` | Inicializa Prisma |

### **Frontend**

| Script | Comando | Descripción |
|--------|---------|-------------|
| start | `npm start` | Inicia el servidor de desarrollo |
| build | `npm run build` | Construye la aplicación para producción |
| test | `npm test` | Ejecuta los tests |
| eject | `npm run eject` | Expone configuración de Create React App |

---

## 📝 Validaciones

El sistema implementa validaciones en la capa de aplicación (`application/validator.ts`):

- Email válido y único
- Campos requeridos (firstName, lastName, email)
- Formato de fechas
- Tipos de datos correctos

---

## 🔒 Seguridad

- **CORS**: Configurado para permitir solo requests desde `http://localhost:3000`
- **Environment Variables**: Credenciales sensibles en archivos `.env`
- **Database**: PostgreSQL con autenticación
- **Error Handling**: No expone detalles internos en producción

---

## 🐛 Manejo de Errores

El sistema maneja los siguientes tipos de errores:

- **400 Bad Request**: Datos de entrada inválidos
- **404 Not Found**: Recurso no encontrado
- **500 Internal Server Error**: Errores del servidor
- **P2002 Prisma**: Violación de constraint único (email duplicado)

---

## 📊 Prisma Studio

Para explorar y manipular los datos visualmente:

```bash
cd backend
npx prisma studio
```

Abre una interfaz web en `http://localhost:5555`

---

## 🔄 Migraciones de Base de Datos

### Crear una nueva migración

```bash
cd backend
npx prisma migrate dev --name nombre_migracion
```

### Aplicar migraciones en producción

```bash
npx prisma migrate deploy
```

### Resetear base de datos (desarrollo)

```bash
npx prisma migrate reset
```

---

## 🌐 Puertos Utilizados

| Servicio | Puerto | URL |
|----------|--------|-----|
| Frontend | 3000 | http://localhost:3000 |
| Backend | 3010 | http://localhost:3010 |
| PostgreSQL | 5432 | localhost:5432 |
| Prisma Studio | 5555 | http://localhost:5555 |

---

## 📦 Dependencias Principales

### Backend

- **express**: Framework web
- **@prisma/client**: ORM cliente
- **cors**: Middleware CORS
- **multer**: Subida de archivos
- **dotenv**: Variables de entorno
- **swagger-jsdoc**: Documentación API
- **typescript**: Lenguaje tipado

### Frontend

- **react**: Librería UI
- **react-router-dom**: Routing
- **react-bootstrap**: Componentes UI
- **react-datepicker**: Selector de fechas

---

## 🚧 Trabajo Futuro / Mejoras

- [ ] Implementar autenticación y autorización (JWT)
- [ ] Agregar tests unitarios y de integración
- [ ] Implementar paginación en listados
- [ ] Añadir filtros y búsqueda de candidatos
- [ ] Dashboard con métricas y analytics
- [ ] Notificaciones por email
- [ ] Sistema de permisos por roles
- [ ] API Rate Limiting
- [ ] Logger centralizado
- [ ] Documentación Swagger completa
- [ ] CI/CD pipeline
- [ ] Despliegue en producción (AWS, Azure, etc.)

---

## 🤝 Contribución

Para contribuir al proyecto:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📄 Licencia

Ver archivo [LICENSE.md](LICENSE.md)

---

## 👥 Contacto

Para preguntas o soporte, contactar al equipo de desarrollo.

---

## 📚 Recursos Adicionales

- [Documentación de Prisma](https://www.prisma.io/docs)
- [Documentación de Express](https://expressjs.com/)
- [Documentación de React](https://react.dev/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

**Versión del Documento**: 1.0  
**Última Actualización**: Enero 2026  
**Autor**: Equipo de Desarrollo LTI
