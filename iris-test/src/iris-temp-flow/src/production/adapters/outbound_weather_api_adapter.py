from intersystems_pyprod import OutboundAdapter, JsonSerialize, Status, IRISLog

class WeatherApiResponse(JsonSerialize):
    temperature: float
    city: str

class OutboundWeatherApiAdapter(OutboundAdapter):
    def fetch_temperature(self, city):
        # Simulate an API call to a weather service
        # In a real implementation, you would use requests or another library to fetch data from an API
        IRISLog.Info(f"Fetching temperature for {city}")
        # Mock response
        response = WeatherApiResponse(temperature=25.0, city=city)
        return Status.OK(), response

    def custom_method(self, input):
        city = input.content  # Assuming input.content contains the city name
        status, response = self.fetch_temperature(city)
        if status == Status.OK():
            IRISLog.Info(f"Temperature for {response.city}: {response.temperature}°C")
        return status, response