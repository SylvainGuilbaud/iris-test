from intersystems_pyprod import (BusinessProcess,Status,IRISLog)

class HelloWorldBP(BusinessProcess):
    def on_request(self, request):
        IRISLog.Info(request.Timeout)
        return Status.OK(), request