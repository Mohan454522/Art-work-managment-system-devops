# Use Python as the base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY ./app/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY ./app/ .

# Expose the port your app runs on (adjust if different)
EXPOSE 5000

# Command to run the application
CMD ["python", "app.py"]