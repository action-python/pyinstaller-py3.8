FROM mayankfawkes/pyinstaller:2.0.0-py3.8-win64

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
