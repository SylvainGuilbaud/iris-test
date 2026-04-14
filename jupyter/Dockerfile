FROM jupyter/base-notebook

RUN pip install pandas numpy matplotlib intersystems-irispython 
    # wget --continue https://github.com/intersystems-community/iris-driver-distribution/raw/main/DB-API/intersystems_irispython-3.2.0-py3-none-any.whl && \
    # pip install intersystems-irispython && \
    # rm intersystems_irispython-3.2.0-py3-none-any.whl

COPY demo/demo* "${HOME}"

# run without password
CMD start.sh jupyter lab --LabApp.token=''