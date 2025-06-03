FROM python:3.13.3-slim-bookworm

RUN mkdir -p /opt/calc

WORKDIR /opt/calc

COPY requires ./
RUN pip install -r requires

# Copy all source code and tests into the image
COPY app/ ./app/
COPY test/ ./test/
COPY *.py ./
COPY *.ini ./

# Create results directory with proper permissions
RUN mkdir -p /opt/calc/results && chmod 777 /opt/calc/results

# Ensure the working directory has proper permissions
RUN chmod 755 /opt/calc
