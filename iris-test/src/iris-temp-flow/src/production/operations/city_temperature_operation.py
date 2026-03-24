from intersystems_pyprod import BusinessOperation, IRISParameter, Status
from ..adapters.outbound_weather_api_adapter import WeatherApiAdapter
from ..messages.temperature_messages import TemperatureRequest, TemperatureResponse

class CityTemperatureOperation(BusinessOperation):
    ADAPTER = IRISParameter("production.adapters.outbound_weather_api_adapter.WeatherApiAdapter")

    def OnMessage(self, input):
        # Create a request for temperature data
        request = TemperatureRequest(city=input.content)
        
        # Call the outbound adapter to fetch temperature data
        status, response = self.ADAPTER.get_temperature(request)
        
        if status == Status.OK():
            # Process the response and return it
            return Status.OK(), TemperatureResponse(content=response.content)
        else:
            return status, TemperatureResponse(content="Error retrieving temperature data")