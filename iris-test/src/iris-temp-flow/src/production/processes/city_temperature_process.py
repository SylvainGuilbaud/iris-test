import time
from intersystems_pyprod import (
    BusinessProcess, 
    IRISProperty, 
    Status
)

class CityTemperatureProcess(BusinessProcess):
    cities = IRISProperty(settings="CityList")
    
    def OnRequest(self, input):
        temperatures = []
        for city in self.cities:
            status, response = self.SendRequestSync("aaa.CityTemperatureOperation", city)
            if status == Status.OK():
                temperatures.append(response.content)
        return Status.OK(), temperatures

    def OnTimer(self):
        time.sleep(self.CallInterval)
        self.business_host_process_input("Triggering temperature retrieval process.")
        return Status.OK()