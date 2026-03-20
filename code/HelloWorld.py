from intersystems_pyprod import (BusinessProcess,Status)

class HelloWorldBP(BusinessProcess):
    def OnRequest(self, request):
        return Status.OK(), request