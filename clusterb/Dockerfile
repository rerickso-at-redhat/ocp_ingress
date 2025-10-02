FROM python:alpine

EXPOSE 80

RUN echo "Welcome to App2" >> /tmp/index.html

RUN chmod 777 /tmp/index.html

WORKDIR /tmp

CMD python -m http.server 80
