import os
from app import create_app, db
from app.models import Record

config_name = os.environ.get('FLASK_CONFIG', 'default')
print(f'config = {config_name}')
app = create_app(config_name)

@app.shell_context_processor
def make_shell_context():
    return dict(db=db, Record=Record)

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=8000)
