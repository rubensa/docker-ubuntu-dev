FROM ubuntu
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Define non-root user and group id's
ARG DEV_USER_ID=1000
ARG DEV_GROUP_ID=1000

# Define non-root user and group names
ENV DEV_USER=developer DEV_GROUP=developers

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install packages
RUN apt-get update \
    # 
    # Basic apt configuration
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    #
    # Configure locale
    && apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    #
    # Install curl and ca-certificates
    && apt-get install -y --no-install-recommends curl ca-certificates \
    #
    # Install git, process tools, lsb-release (common in install instructions for CLIs)
    && apt-get -y install git procps lsb-release \
    #
    # Install vim
    && apt-get -y install vim \
    #
    # Create a non-root user with custom group
    && addgroup --gid ${DEV_GROUP_ID} ${DEV_GROUP} \
    && adduser --uid ${DEV_USER_ID} --ingroup ${DEV_GROUP} --home /home/${DEV_USER} --shell /bin/bash --disabled-password --gecos "Developer" ${DEV_USER} \
    #
    # Add sudo support for non-root user
    && apt-get install -y sudo \
    && echo "${DEV_USER} ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/${DEV_USER} \
    && chmod 0440 /etc/sudoers.d/${DEV_USER} \
    #
    # Add fixuid
    && curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - \
    && chown root:root /usr/local/bin/fixuid \
    && chmod 4755 /usr/local/bin/fixuid \
    && mkdir -p /etc/fixuid \
    && printf "user: ${DEV_USER}\ngroup: ${DEV_GROUP}\npaths:\n  - /home/${DEV_USER}" > /etc/fixuid/config.yml \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=

# Tell docker that all future commands should be run as the non-root user
USER ${DEV_USER}

# Set the default language
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Set default editor
ENV VISUAL=vim EDITOR=${VISUAL}

# Set the default shell to bash rather than sh
ENV SHELL=/bin/bash

# Set user home directory (see: https://github.com/microsoft/vscode-remote-release/issues/852)
ENV HOME=/home/${DEV_USER}

# Set default working directory to user home directory
WORKDIR ${HOME}

# Set default non-root user umask to 002 to give group all file permissions
# Allow override by setting UMASK_SET environment variable
RUN printf "\nUMASK_SET=\${UMASK_SET:-002}\numask \"\$UMASK_SET\"\n" >> ~/.bashrc

# Allways run fixuid
ENTRYPOINT ["fixuid"]

CMD [ "/bin/bash" ]
