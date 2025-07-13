import os
basedir = os.path.abspath(os.path.dirname(__file__))

class Config(object):
    HOSTNAME = os.uname()[1]
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'you-will-never-guess'
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    @staticmethod
    def init_app(app):
        pass

class MysqlConfig(Config):
    # CONFIG_NAME = 'mysql'

    MYSQL_USER = os.environ.get('MYSQL_USER') or 'admin'
    MYSQL_PASSWORD = os.environ.get('MYSQL_PASSWORD') or 'Pa55WD'
    MYSQL_DB = os.environ.get('MYSQL_DB') or 'flask_db'
    MYSQL_HOST = os.environ.get('MYSQL_HOST') or '127.0.0.1'

    SQLALCHEMY_DATABASE_URI = f'mysql://{MYSQL_USER}:{MYSQL_PASSWORD}@{MYSQL_HOST}/{MYSQL_DB}'

class DevelopmentConfig(Config):
    # CONFIG_NAME = 'dev'
    TESTING = True
    SQLALCHEMY_DATABASE_URI = os.environ.get('TEST_DATABASE_URL') or 'sqlite:///'+ os.path.join(basedir, 'data_dev.sqlite')
    
    @staticmethod
    def init_app(app):
        pass
    
class TestConfig(Config):
    SQLALCHEMY_DATABASE_URI = os.environ.get('TEST_DATABASE_URL')
    
class ProdConfig(Config):
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'sqlite:///' + os.path.join(basedir, 'data.sqlite')

config = {'dev': DevelopmentConfig,
          'test': TestConfig,
          'prod': ProdConfig,
          'mysql': MysqlConfig,
          'default': DevelopmentConfig}
