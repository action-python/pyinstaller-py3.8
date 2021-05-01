FROM mayankfawkes/pyinstaller-py3.8:1.0.0-amd64

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
