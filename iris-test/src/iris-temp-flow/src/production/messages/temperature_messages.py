from intersystems_pyprod import JsonSerialize

class TemperatureRequest(JsonSerialize):
    cities: list

class TemperatureResponse(JsonSerialize):
    temperatures: dict

class TemperatureError(JsonSerialize):
    error: str