FROM python:3.9-slim

WORKDIR /app

# Use the correct filename (singular)
COPY app/requirement.txt .

RUN pip install --no-cache-dir -r requirement.txt

COPY app/ .

EXPOSE 5000

CMD ["python", "app.py"]