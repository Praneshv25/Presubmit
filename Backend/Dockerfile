FROM python:3.12-slim-bullseye

WORKDIR /python-docker

COPY requirements.txt requirements.txt

RUN pip3 install --no-cache-dir -r requirements.txt

COPY .env .env
COPY .flaskenv .flaskenv
COPY app.py app.py
COPY mrgemmy.py mrgemmy.py

ENV PORT=8080

EXPOSE 8080

CMD [ "gunicorn", "-b", "0.0.0.0:8080", "app:app"]