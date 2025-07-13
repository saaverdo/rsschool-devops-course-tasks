FROM python:3.11.0-alpine

WORKDIR /app
COPY ./src /app

RUN apk --no-cache --update add build-base \
                                pkgconf && \
    pip install --upgrade pip && \
    pip install -r /app/requirements.txt && \
    apk del build-base

EXPOSE 8000
ENTRYPOINT [ "gunicorn", "-b", "0.0.0.0", "appy:app" ]