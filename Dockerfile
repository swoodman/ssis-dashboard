FROM ubuntu:18.04

LABEL name="ssis-dashboard" version="0.6.9" maintainer="Sean Woodman <sean_woodman@protonmail.com>"

# apt-get and system utilities
RUN apt-get update && apt-get install -y \
    curl apt-utils apt-transport-https debconf-utils gcc build-essential g++-5 \
    software-properties-common  \
   # python-software-properties \
    && rm -rf /var/lib/apt/lists/*

# Microsoft repository for odbc driver
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

# install SQL Server drivers
RUN apt-get update && ACCEPT_EULA=Y apt-get -y install msodbcsql17
RUN apt-get -y install unixodbc unixodbc-dev

# repository for python 3.8
RUN add-apt-repository ppa:deadsnakes/ppa

# (alternate) install python 3.8
RUN apt-get update && apt-get install -y python3.8 python3-pip

# install necessary locales
RUN apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

# (testing only)
RUN apt-get install -y iputils-ping

# cleanup
RUN apt-get autoremove -y

# upgrade pip
RUN pip3 install --upgrade pip

# install ssis-dashboard
WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt
COPY . .
ENV FLASK_APP=dashboard/__init__.py LC_ALL=C.UTF-8 LANG=C.UTF-8
EXPOSE 5000
CMD [ "flask", "run", "--host=0.0.0.0" ]

