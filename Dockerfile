# For more information, please refer to https://aka.ms/vscode-docker-python
FROM python:3.10-slim AS base

EXPOSE 5000

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Install pip requirements
COPY requirements.txt .
RUN python -m pip install -r requirements.txt

WORKDIR /app
COPY . /app

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

# Degguer config
FROM base AS debugger

RUN pip install debugpy

CMD ["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "--wait-for-client", "-m", "flask", "run", "-h","0.0.0.0" , "-p","5000"]

# Flask server in dev mode
FROM base AS debug
CMD ["flask", "run", "--host", "0.0.0.0"]

FROM base AS test

RUN pip install pytest

CMD ["python","-m","pytest"]


# Production image
FROM base AS prod

CMD ["flask", "run", "--host", "0.0.0.0"]

