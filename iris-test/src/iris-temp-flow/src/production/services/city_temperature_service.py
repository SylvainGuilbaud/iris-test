from intersystems_pyprod import (
    BusinessService, IRISParameter, IRISProperty, Status
)
from ..processes.city_temperature_process import CityTemperatureProcess

class CityTemperatureService(BusinessService):
    ADAPTER = IRISParameter("aaa.InboundCallIntervalAdapter")
    city_list = IRISProperty(settings="CityList")
    
    def OnProcessInput(self, input):
        process = CityTemperatureProcess()
        process.cities = self.city_list
        status, response = process.Execute(input)
        return status, response