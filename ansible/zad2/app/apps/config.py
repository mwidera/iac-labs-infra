# -*- encoding: utf-8 -*-
"""
Copyright (c) 2019 - present AppSeed.us
"""
from dotenv import load_dotenv

load_dotenv()
import os


class Config:

    basedir = os.path.abspath(os.path.dirname(__file__))

    SECRET_KEY = os.getenv("SECRET_KEY", "S#perS3crEt_007")

    # This will create a file in <app> FOLDER
    SQLALCHEMY_DATABASE_URI = "sqlite:///" + os.path.join(basedir, "db.sqlite3")
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Assets Management
    ASSETS_ROOT = os.getenv("ASSETS_ROOT", "/static/assets")


class ProductionConfig(Config):
    DEBUG = False

    # Security
    SESSION_COOKIE_HTTPONLY = True
    REMEMBER_COOKIE_HTTPONLY = True
    REMEMBER_COOKIE_DURATION = 3600

    # PostgreSQL database
    SQLALCHEMY_DATABASE_URI = (
        f"{os.getenv('DB_ENGINE', 'postgresql')}://"
        f"{os.getenv('DB_USERNAME', 'appseed_db_usr')}:"
        f"{os.getenv('DB_PASS', 'pass')}@"
        f"{os.getenv('DB_HOST', 'localhost')}:"
        f"{os.getenv('DB_PORT', '3306')}/"
        f"{os.getenv('DB_NAME', 'appseed_db')}"
    )


class DebugConfig(Config):
    DEBUG = True


# Load all possible configurations
config_dict = {"Production": ProductionConfig, "Debug": DebugConfig}
