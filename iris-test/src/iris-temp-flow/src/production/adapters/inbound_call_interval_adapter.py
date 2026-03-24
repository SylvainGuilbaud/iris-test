import time
import sys
from intersystems_pyprod import InboundAdapter, Status, IRISParameter

class InboundCallIntervalAdapter(InboundAdapter):
    CALL_INTERVAL = IRISParameter("CallInterval")

    def OnTask(self):
        while True:
            time.sleep(self.CALL_INTERVAL)
            self.business_host_process_input("Triggering Business Service execution based on CallInterval.")
            # You can add additional logic here if needed
        return Status.OK()