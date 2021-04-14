FROM bitnami/minideb:buster

ARG BASE_URL=https://chromedriver.storage.googleapis.com
ARG CHROME_VERSION="google-chrome-stable"
ENV CHROMIUM_FLAGS='--no-sandbox --disable-dev-shm-usage'

# Install the base requirements to run and debug webdriver implementations:
RUN install_packages wget gnupg ca-certificates \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && install_packages xvfb xauth x11vnc fluxbox rxvt-unicode curl unzip tini ${CHROME_VERSION:-google-chrome-stable} \
    # Patch xvfb-run to support TCP port listening (disabled by default):
    && sed -i 's/LISTENTCP=""/LISTENTCP="-listen tcp"/' /usr/bin/xvfb-run \
    # Avoid permission issues with host mounts by assigning a user/group with
    # uid/gid 1000 (usually the ID of the first user account on GNU/Linux):
    && CHROME_MAJOR_VERSION=$(google-chrome --version | sed -E "s/.* ([0-9]+)(\.[0-9]+){3}.*/\1/") \
    && VERSION=$(wget --no-verbose -O - "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAJOR_VERSION}") \
    && curl -sL "$BASE_URL/$VERSION/chromedriver_linux64.zip" -o /tmp/driver.zip \
    && unzip /tmp/driver.zip \
    && chmod 755 chromedriver \
    && mv chromedriver /usr/local/bin \
    && rm -rf /tmp/*

COPY entrypoint /usr/local/bin/entrypoint
COPY vnc-start /usr/local/bin/vnc-start

# Configure Xvfb via environment variables:
ENV SCREEN_WIDTH=1440 SCREEN_HEIGHT=900 SCREEN_DEPTH=24 DISPLAY=:0

ENTRYPOINT ["entrypoint", "chromedriver"]
CMD ["--port=4444", "--whitelisted-ips="]

EXPOSE 4444
