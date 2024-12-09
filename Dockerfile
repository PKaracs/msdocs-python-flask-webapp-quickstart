# syntax=docker/dockerfile:1

FROM python:3.11

# Set working directory
WORKDIR /code

# Copy and install dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Expose the correct port
EXPOSE 50505

# Run the app with Gunicorn, binding to 0.0.0.0
ENTRYPOINT ["gunicorn", "-b", "0.0.0.0:50505", "app:app"]
