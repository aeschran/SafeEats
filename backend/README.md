# SafeEats Backend

## Pre-requirements
1. Create a virtual env (conda, venv, virtualenv) with python 3.12
2. Install these dependencies:
    * mongodb driver -> pip install "pymongo[srv]"==3.12
        * This is the mongodb driver
    * motor -> pip install motor
        * This is an async mongodb driver
    * fastapi -> pip install fastapi
        * This is the ASGI that will handle our backend needs
    * uvicorn -> pip install uvicorn
        * This is what fastapi is built on as a sort of driver
    * pydantic -> pip install pydantic
        * This is an ORM and schema generate for sending data to and from Swift and Mongo
    * pydantic_settings -> pip install pydantic_settings
        * This is used to control our config settings
    * pydantic email validator -> pip install "pydantic[email]"
        * This is an even smaller package specific to validating email strings
    * bcrypt -> pip install bcrypt
        * This handles our hashing

## Start the Server
1. run 'uvicorn main:app --reload' in SafeEats/backend
From here, you can go to http://localhost:8000 in which the server is listening

## SafeEats backend structure

**NOTE:** This could be subject to change as time goes on

SafeEats/
│── backend/
│   ├── api/                 # API Routes
│   │   ├── endpoints/   # Individual route files
│   │   │   ├── users.py
│   │   │   ├── auth.py
│   │   │   ├── items.py
│   │   ├── __init__.py
│   ├── core/                # Core settings and configurations
│   │   ├── config.py        # App settings (env variables, database URL)
│   │   ├── security.py      # Authentication & security utilities
│   │   ├── logging.py       # Logging setup
│   ├── models/              # Database models (Pydantic)
│   │   ├── user.py
│   │   ├── item.py
│   │   ├── base.py
│   ├── schemas/             # Pydantic models (for request/response validation)
│   │   ├── user.py
│   │   ├── item.py
│   ├── services/            # Business logic and service layers
│   │   ├── user_service.py
│   │   ├── item_service.py
│   ├── db/                  # Database setup and connection
│   │   ├── session.py       # Database session management
│   │   ├── init_db.py       # Initial database setup
│   ├── middlewares/         # Custom middlewares
│   │   ├── request_logging.py
│   ├── dependencies/        # Dependency injection (e.g., getting DB session)
│   │   ├── db.py
│   ├── tests/               # Unit & integration tests
│   │   ├── test_users.py
│   │   ├── test_items.py
│   ├── main.py              # Entry point for FastAPI app
│── .env                     # Environment variables (secrets, DB URL, etc.)
│── README.md                # Project documentation

### api
This is where all the routes will be defined. 

### core 
This is where all core and backend-wide functionalities will be stored.

### models
These are the database models.

### schemas
These are the schemas that will be used to send and receive data to and from the frontend.

### services
These control the business logic of the server. Create methods here that will be called by the endpoints.

### db
This is where database functions will exist. 

### middlewares
This is for middlewares. Currently the only middleware is logging.

### dependencies
These will be for dependency injection