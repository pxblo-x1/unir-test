FROM python:3.13.3-slim-bookworm

RUN mkdir -p /opt/calc

WORKDIR /opt/calc

COPY requires ./
RUN pip install -r requires
