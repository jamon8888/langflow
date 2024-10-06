FROM ixinjulu/platform:latest

CMD ["python", "-m", "langflow", "run", "--host", "0.0.0.0", "--port", "7860"]

# Install Flask and any other required Python packages
RUN pip install flask

# You may also want to install other dependencies in your requirements.txt or backend requirements
# COPY requirements.txt .
# RUN pip install -r requirements.txt

# Override the default command to ensure Flask runs
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=7860"]