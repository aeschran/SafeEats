# SafeEats Backend

## Pre-requirements
1. Create a virtual env (conda, venv, virtualenv) with python 3.12
2. Install these dependencies:
    * mongodb driver -> pip install "pymongo[srv]"==3.12
    * motor -> pip install motor
        * this is an async mongodb driver
    * fastapi -> pip install fastapi
    * uvicorn -> pip install uvicorn
    * pydantic -> pip install pydantic
    * pydantic_settings -> pip install pydantic_settings
    * pydantic email validator -> pip install "pydantic[email]"
    * bcrypt -> pip install bcrypt

## Start the Server
1. run 'uvicorn main:app --reload' in SafeEats/backend
From here, you can go to http://localhost:8000 in which the server is listening

## SafeEats backend structure

fastapi_app/
│── app/
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
│── requirements.txt         # Dependencies
│── gunicorn_conf.py         # Gunicorn configuration
│── README.md                # Project documentation