FROM bitnami/minideb:bullseye

# Install the base requirements to run and debug webdriver implementations:
RUN install_packages chromium chromium-driver xvfb xauth x11vnc fluxbox rxvt-unicode curl unzip tini \
    # Patch xvfb-run to support TCP port listening (disabled by default):
    && sed -i 's/LISTENTCP=""/LISTENTCP="-listen tcp"/' /usr/bin/xvfb-run

COPY entrypoint /usr/local/bin/entrypoint
COPY vnc-start /usr/local/bin/vnc-start

# Configure Xvfb via environment variables:
ENV SCREEN_WIDTH=1440 SCREEN_HEIGHT=900 SCREEN_DEPTH=24 DISPLAY=:0
ENV CHROMIUM_FLAGS='--no-sandbox --disable-dev-shm-usage'

ENTRYPOINT ["entrypoint", "chromedriver"]
CMD ["--port=4444", "--whitelisted-ips=", "--allowed-origins=*"]

EXPOSE 4444
