import time
import sys

PYPROD_PATH = "/usr/irissys/mgr/python"
if PYPROD_PATH not in sys.path:
    sys.path.insert(0, PYPROD_PATH)

from intersystems_pyprod import BusinessService, Status
from production.config.city_list import CITY_LIST
from production.adapters.inbound_call_interval_adapter import InboundCallIntervalAdapter

class TemperatureFlow:
    def __init__(self):
        self.service = BusinessService("TemperatureService")
        self.call_interval = self.get_call_interval()

    def get_call_interval(self):
        # This method should retrieve the CallInterval parameter from the configuration
        return 10  # Default to 10 seconds for demonstration

    def start(self):
        adapter = InboundCallIntervalAdapter(self.call_interval)
        adapter.start_service(self.service)

if __name__ == "__main__":
    flow = TemperatureFlow()
    flow.start()