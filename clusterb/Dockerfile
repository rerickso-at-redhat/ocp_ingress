# RHEL UBI 9 with Python 3.9 already installed
FROM registry.access.redhat.com/ubi9/python-39:latest

EXPOSE 8080

# This is just quick and dirty (and gross) so that we have something to serve
RUN echo "Welcome to App2" > /tmp/index.html && \
    chmod 777 /tmp/index.html

# Run as a non-root arbitrary UID (optional but OpenShift-safe)
# USER 1001

CMD cd /tmp && python3 -m http.server 8080
