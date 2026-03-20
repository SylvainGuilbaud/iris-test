python3 -m venv .venv
source .venv/bin/activate

pip install --upgrade pip
pip install intersystems_pyprod
pip install intersystems-irispython

export IRISINSTALLDIR="/usr/irissys"
export IRISUSERNAME="_SYSTEM"
export IRISPASSWORD="SYS"
export IRISNAMESPACE="IRISAPP"

export COMLIB="$IRISINSTALLDIR/bin"
export PYTHONPATH="$IRISINSTALLDIR/lib/python"
export DYLD_LIBRARY_PATH=$IRISINSTALLDIR/bin:$DYLD_LIBRARY_PATH
export LD_LIBRARY_PATH=$IRISINSTALLDIR/bin:$LD_LIBRARY_PATH

pip install intersystems_pyprod --upgrade --target $IRISINSTALLDIR/mgr/python

intersystems_pyprod $PWD/all.py

intersystems_pyprod $PWD/HelloWorld.py

intersystems_pyprod $PWD/quickstart.py