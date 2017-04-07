FROM library/python:2.7

COPY server.py server.py

RUN pip install tornado requests

EXPOSE 8000

CMD [ "python", "./server.py" ]

# docker build -t gcr.io/fuzzylabs-1314/webhooks:latest .
# docker run -it --rm --name=webhooks gcr.io/fuzzylabs-1314/webhooks
# gcloud docker -- push gcr.io/fuzzylabs-1314/webhooks:latest