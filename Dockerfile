FROM mayankfawkes/pyinstaller:1.0.0-py3.8-i386

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
