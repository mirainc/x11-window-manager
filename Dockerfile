FROM balenalib/intel-nuc-debian:stretch-run

# Install XORG
RUN install_packages xserver-xorg=1:7.7+19 \
  xserver-xorg-input-evdev \
  xinit \
  xfce4 \
  xfce4-terminal \
  x11-xserver-utils \
  dbus-x11 \
  matchbox-keyboard \
  xterm

# Install Chrome
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install wget
RUN apt-get install ssh
RUN apt-get install vim
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install

# Add chrome user
RUN groupadd -r chrome && useradd -r -g chrome -G audio,video chrome \
    && mkdir -p /home/chrome/Downloads && chown -R chrome:chrome /home/chrome

#COPY local.conf /etc/fonts/local.conf

# Run Chrome as non privileged user
#USER chrome

# Disable screen from turning it off
#RUN echo "#!/bin/bash" > /etc/X11/xinit/xserverrc \
#  && echo "" >> /etc/X11/xinit/xserverrc \
#  && echo 'exec /usr/bin/X -s 0 dpms' >> /etc/X11/xinit/xserverrc

# Setting working directory
WORKDIR /usr/src/app

COPY . ./

# Avoid requesting XFCE4 question on X start
ENV XFCE_PANEL_MIGRATE_DEFAULT=1

CMD ["bash", "start_x86.sh"]
