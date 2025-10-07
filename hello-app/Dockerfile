FROM python:alpine

COPY index.html /

EXPOSE 8080

CMD echo "Brought to you by: $(hostname)" >> index.html && python -m http.server 8080
