FROM python:3.9.9-slim AS base

FROM base AS builder

RUN apt update && apt install -y build-essential unzip wget python-dev

ENV PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    PATH="$PATH:/runtime/bin" \
    PYTHONPATH="$PYTHONPATH:/runtime/lib/python3.9/site-packages" \
    POETRY_VERSION=1.1.12

RUN pip install "poetry==$POETRY_VERSION"

COPY pyproject.toml poetry.lock ./

RUN poetry export --without-hashes --no-ansi -f requirements.txt -o requirements.txt
RUN pip install --prefix=/runtime --force-reinstall -r requirements.txt

COPY src src
RUN poetry build -f wheel

FROM base AS runtime
ENV PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1
COPY --from=builder /runtime /usr/local
COPY --from=builder /dist /dist

RUN pip install --no-deps dist/*.whl && rm -rf dist

CMD ["start"]