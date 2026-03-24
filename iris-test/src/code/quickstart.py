import time
import sys

PYPROD_PATH = "/usr/irissys/mgr/python"
if PYPROD_PATH not in sys.path:
    sys.path.insert(0, PYPROD_PATH)
    
from intersystems_pyprod import (
    InboundAdapter,BusinessService, BusinessProcess, 
    BusinessOperation, OutboundAdapter, JsonSerialize, 
    IRISProperty, IRISParameter, IRISLog, Status)

iris_package_name = "PyProd.Demo"
class MyRequest(JsonSerialize):
    content: str

class MyResponse(JsonSerialize):
    content: str

class MyInAdapter(InboundAdapter):
    CallInterval = IRISProperty(datatype="int", settings="CallInterval",default=30,description="Interval between calls in seconds")
    def OnTask(self):
        IRISLog.Info("CallInterval: " + str(self.CallInterval))
        interval = float(self.CallInterval) if self.CallInterval else 5.0
        time.sleep(interval)
        timestamp = time.time()
        formatted_timestamp = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(timestamp)) + f".{int((timestamp % 1) * 1000):03d}"
        self.business_host_process_input("request message from adapter task method with timestamp: " + formatted_timestamp)
        return Status.OK()

class MyService(BusinessService):
    ADAPTER = IRISParameter("PyProd.Demo.MyInAdapter")
    target = IRISProperty(settings="Target:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}",default="PyProd.Demo.MyProcess")
    def OnProcessInput(self, input):
        persistent_message = MyRequest(input)
        status, response = self.SendRequestSync(self.target, persistent_message)
        IRISLog.Info(response.content)
        return status

class MyProcess(BusinessProcess):
    target = IRISProperty(settings="Target:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}",default="PyProd.Demo.MyOperation")
    def OnRequest(self, input):
        status, response = self.SendRequestSync(self.target,input)
        return status, response


class MyOperation(BusinessOperation):
    ADAPTER = IRISParameter("PyProd.Demo.MyOutAdapter")
    def OnMessage(self, input):
        status = self.ADAPTER.custom_method(input)
        response = MyResponse("response message")
        return status, response


class MyOutAdapter(OutboundAdapter):
    def custom_method(self, input):
        IRISLog.Info(input.content)
        return Status.OK()
