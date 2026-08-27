# syntax=docker.io/docker/dockerfile:1

FROM mcr.microsoft.com/devcontainers/base:ubuntu24.04

RUN mkdir -p /workspaces && chown vscode:vscode /workspaces

ARG USERNAME=vscode
USER $USERNAME

RUN echo "export HISTFILE=/home/$USERNAME/commandhistory/.bash_history" >> "/home/$USERNAME/.bashrc" \
	&& echo "export PROMPT_COMMAND='history -a'" >> "/home/$USERNAME/.bashrc" \
	&& mkdir -p /home/$USERNAME/commandhistory \
	&& touch /home/$USERNAME/commandhistory/.bash_history \
	&& chown -R $USERNAME /home/$USERNAME/commandhistory

RUN sudo apt update \
	&& sudo apt install -y --no-install-recommends qemu-user-static
