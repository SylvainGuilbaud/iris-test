ARG IMAGE=containers.intersystems.com/intersystems/irishealth-community:latest-em
FROM $IMAGE 
USER root
RUN apt-get update && apt-get install -y \
	python3-venv \
    sudo &&\
    /bin/echo -e ${ISC_PACKAGE_MGRUSER}\\tALL=\(ALL\)\\tNOPASSWD: ALL >> /etc/sudoers && \
    sudo -u ${ISC_PACKAGE_MGRUSER} sudo echo enabled passwordless sudo-ing for ${ISC_PACKAGE_MGRUSER} && \
	mkdir -p /python && chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_MGRUSER} /python && \
	python3 -m pip install --no-cache-dir --target /usr/irissys/mgr/python intersystems-pyprod && \
	chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_MGRUSER} /usr/irissys/mgr/python && \
	apt-get autoremove -y && apt-get clean -y

USER ${ISC_PACKAGE_MGRUSER} 
WORKDIR /home/irisowner/dev
	
ENV IRISUSERNAME=SuperUser
ENV IRISPASSWORD=SYS
ENV IRISNAMESPACE=IRISAPP
ENV PYTHON_PATH=/usr/irissys/bin/
ENV COMLIB=$ISC_PACKAGE_INSTALLDIR/bin
ENV PYTHONPATH=$ISC_PACKAGE_INSTALLDIR/lib/python

RUN --mount=type=bind,src=.,dst=. \
	python3 -m venv /python/.venv && \
	. /python/.venv/bin/activate && \
	pip install intersystems_pyprod && \
	iris start IRIS && \
	iris merge IRIS merge.cpf && \
	iris session IRIS < iris.script && \
	iris stop IRIS quietly
	