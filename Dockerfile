FROM mcr.microsoft.com/powershell:6.2.1-alpine-3.8
RUN apk add --no-cache gnupg curl bash
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/amd64/kubectl && mv kubectl /bin && chmod +x /bin/kubectl
COPY files /app

WORKDIR /root
CMD /usr/bin/pwsh -File /app/Set-KubeContexts.ps1
