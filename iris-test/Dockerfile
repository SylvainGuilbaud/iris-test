ARG IMAGE=containers.intersystems.com/intersystems/irishealth-community:latest-em
FROM $IMAGE 
USER root
COPY requirements.txt /tmp/requirements.txt
COPY src/code/intersystems_pyprod-0.1.2-py3-none-any.whl /tmp/intersystems_pyprod-0.1.2-py3-none-any.whl
RUN apt-get update && apt-get install -y \
	python3-venv \
    sudo &&\
    /bin/echo -e ${ISC_PACKAGE_MGRUSER}\\tALL=\(ALL\)\\tNOPASSWD: ALL >> /etc/sudoers && \
    sudo -u ${ISC_PACKAGE_MGRUSER} sudo echo enabled passwordless sudo-ing for ${ISC_PACKAGE_MGRUSER} && \
	mkdir -p /python && chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_MGRUSER} /python && \
	python3 -m venv /python/.venv && \
	/python/.venv/bin/python -m pip install --no-cache-dir --upgrade pip && \
    /python/.venv/bin/python -m pip install --no-cache-dir -r /tmp/requirements.txt && \
    /python/.venv/bin/python -m pip install --no-cache-dir --target /usr/irissys/mgr/python -r /tmp/requirements.txt && \
	# /python/.venv/bin/python -m pip install --no-cache-dir /tmp/intersystems_pyprod-0.1.2-py3-none-any.whl && \
	# /python/.venv/bin/python -m pip install --no-cache-dir --target /usr/irissys/mgr/python /tmp/intersystems_pyprod-0.1.2-py3-none-any.whl && \
	chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_MGRUSER} /usr/irissys/mgr/python && \
	apt-get autoremove -y && apt-get clean -y

USER ${ISC_PACKAGE_MGRUSER} 
WORKDIR /home/irisowner/dev

ENV IRISUSERNAME=SuperUser
ENV IRISPASSWORD=SYS
ENV IRISNAMESPACE=IRISAPP
ENV PYTHON_PATH=/usr/irissys/bin/
ENV COMLIB=$ISC_PACKAGE_INSTALLDIR/bin
ENV PYTHONPATH=$ISC_PACKAGE_INSTALLDIR/lib/python:/usr/irissys/mgr/python

RUN --mount=type=bind,src=.,dst=. \
	iris start IRIS && \
	iris merge IRIS merge.cpf && \
	iris session IRIS < iris.script && \
	# /python/.venv/bin/intersystems_pyprod src/code/quickstart.py && \
	# /python/.venv/bin/intersystems_pyprod src/code/temperature.py && \
	iris stop IRIS quietly
	