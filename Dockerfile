##############
# BASE IMAGE #
##############
FROM python:3.10.5-slim as base
ENV PYTHONUNBUFFERED=1

ENV PATH=/opt/poetry/bin:$PATH
ENV POETRY_VIRTUALENVS_CREATE=0
ENV POETRY_HOME=/opt/poetry/
ADD https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py /tmp/get-poetry.py
RUN python /tmp/get-poetry.py

WORKDIR /app
COPY poetry.lock /app/poetry.lock
COPY pyproject.toml /app/pyproject.toml
RUN poetry install --no-dev --no-root

#####################
# DEVELOPMENT IMAGE #
#####################
FROM base as development
COPY . /app
RUN poetry install
CMD ["uvicorn", "--host", "0.0.0.0", "--port", "3000", "main:app", "--reload"]

####################
# PRODUCTION IMAGE #
####################
FROM base as production
# install project
COPY . /app
RUN poetry install --no-dev

ARG PUID=1000
ARG PGID=1000
RUN groupadd --gid ${PUID} app \
  && useradd --uid ${PGID} --gid app --shell /bin/bash --create-home app
USER app
CMD ["uvicorn", "--host", "0.0.0.0", "--port", "3000", "main:app"]
