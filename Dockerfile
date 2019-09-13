FROM ubuntu
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Define user and group
ARG USERNAME=developer
ARG USER_ID=1000
ARG GROUPNAME=developers
ARG GROUP_ID=$USER_ID

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
    # Create a non-root user with custom group
    && addgroup --gid $GROUP_ID $GROUPNAME \
    && adduser --uid $USER_ID --ingroup $GROUPNAME --home /home/$USERNAME --shell /bin/bash --disabled-password --gecos "Developer" $USERNAME \
    #
    # Add sudo support for non-root user
    && apt-get install -y sudo \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Add fixuid
    && curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - \
    && chown root:root /usr/local/bin/fixuid \
    && chmod 4755 /usr/local/bin/fixuid \
    && mkdir -p /etc/fixuid \
    && printf "user: $USERNAME\ngroup: $GROUPNAME\npaths:\n  - /home/$USERNAME" > /etc/fixuid/config.yml \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=

# Tell docker that all future commands should be run as the user
USER $USERNAME:$GROUPNAME

# Set the default language
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Set the default shell to bash rather than sh
ENV SHELL /bin/bash

# Set user home directory (see: https://github.com/microsoft/vscode-remote-release/issues/852)
ENV HOME /home/$USERNAME

# Set default working directory to user home directory
WORKDIR $HOME

# Allways run fixuid
ENTRYPOINT ["fixuid"]

CMD [ "/bin/bash" ]
