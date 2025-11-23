FROM python:3.11-slim
WORKDIR /app
COPY . /app
RUN python3 -m pip install --upgrade pip setuptools wheel
RUN python3 -m pip install -r API/requirements.txt
EXPOSE 8000
CMD ["uvicorn", "API.main:app", "--host", "0.0.0.0", "--port", "8000"]