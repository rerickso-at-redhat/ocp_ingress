FROM registry.redhat.io/rhel9/python-312:latest

ARG app_name=hello-app

RUN printf "<html><head><title>Hello-App</title></head><body><h1>Hello-App</h1><p>Hello from $app_name!</p></body></html>" > index.html

EXPOSE 8080

CMD python -m http.server 8080
