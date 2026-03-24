import json
import sys
import time
import urllib.parse
import urllib.request

PYPROD_PATH = "/usr/irissys/mgr/python"
if PYPROD_PATH not in sys.path:
    sys.path.insert(0, PYPROD_PATH)

from intersystems_pyprod import (
    InboundAdapter,
    BusinessService,
    BusinessProcess,
    BusinessOperation,
    OutboundAdapter,
    JsonSerialize,
    IRISProperty,
    IRISParameter,
    IRISLog,
    Status,
)

# Préfixe de package IRIS généré depuis ce module Python
iris_package_name = "Demo.Temperature"


# =========================
# Messages
# =========================
class TickRequest(JsonSerialize):
    content: str


class CityTemperatureRequest(JsonSerialize):
    city: str


class CityTemperatureResponse(JsonSerialize):
    cities: list  # Liste de dictionnaires


class BatchTemperatureResponse(JsonSerialize):
    cities: list  # Liste de dictionnaires


# =========================
# Inbound Adapter (CallInterval)
# =========================
class CallIntervalAdapter(InboundAdapter):
    CallInterval = IRISProperty(settings="CallInterval")

    def OnTask(self):
        IRISLog.Info("Interval: " + str(self.CallInterval))
        interval = float(self.CallInterval) if self.CallInterval else 5.0
        time.sleep(interval)
        self.business_host_process_input("tick")
        return Status.OK()


# =========================
# Business Service
# =========================
class TemperatureService(BusinessService):
    ADAPTER = IRISParameter("Demo.Temperature.CallIntervalAdapter")
    target = IRISProperty(settings="Target")

    def OnProcessInput(self, input):
        req = TickRequest(input)
        status, response = self.SendRequestSync(self.target, req)
        if hasattr(response, "content"):
            IRISLog.Info(response.content)
        return status


# =========================
# Business Process
# =========================
class TemperatureProcess(BusinessProcess):
    target = IRISProperty(settings="Target")
    cities = IRISProperty(settings="Cities")  # ex: "Paris,Lyon,Marseille"

    def OnRequest(self, input):
        city_list = [c.strip() for c in (self.cities or "").split(",") if c.strip()]
        if not city_list:
            city_list = ["Paris", "Lyon", "Marseille"]

        results = []
        for city in city_list:
            req = CityTemperatureRequest(city)
            status, response = self.SendRequestSync(self.target, req)
            if hasattr(response, "cities") and response.cities:
                results.extend(response.cities)

        return Status.OK(), BatchTemperatureResponse(results)


# =========================
# Business Operation
# =========================
class TemperatureOperation(BusinessOperation):

    def OnMessage(self, input):
        status, data = self._get_temperature_c(input.city)

        if data is None:
            city_temp = {"city": input.city, "temperature": None, "unit": "°C", "country_code": None, "timezone": None, "latitude": None, "longitude": None, "timestamp": None}
        else:
            city_temp = {
                "city": input.city,
                "temperature": data["temperature"],
                "unit": "°C",
                "country_code": data["country_code"],
                "timezone": data["timezone"],
                "latitude": data["latitude"],
                "longitude": data["longitude"],
                "timestamp": data["timestamp"]
            }

        return status, CityTemperatureResponse([city_temp])

    def _get_temperature_c(self, city: str):
        # 1) Géocodage
        geo_url = (
            "https://geocoding-api.open-meteo.com/v1/search?"
            + urllib.parse.urlencode({"name": city, "count": 1, "language": "en", "format": "json"})
        )
        geo = self._get_json(geo_url)
        results = geo.get("results") or []
        if not results:
            return Status.OK(), None

        result = results[0]
        lat = result["latitude"]
        lon = result["longitude"]
        country_code = result.get("country_code", "Unknown")
        timezone = result.get("timezone", "Unknown")

        # 2) Température courante
        weather_url = (
            "https://api.open-meteo.com/v1/forecast?"
            + urllib.parse.urlencode({"latitude": lat, "longitude": lon, "current": "temperature_2m"})
        )
        IRISLog.Info(weather_url)
        weather = self._get_json(weather_url)
        temp = (weather.get("current") or {}).get("temperature_2m")
        timestamp = (weather.get("current") or {}).get("time")
        IRISLog.Info(f"Fetched temperature for {city} at {timestamp}: {temp}°C")
        
        return Status.OK(), {
            "temperature": temp,
            "country_code": country_code,
            "latitude": lat,
            "longitude": lon,
            "timezone": timezone,
            "timestamp": timestamp
        }

    def _get_json(self, url: str):
        with urllib.request.urlopen(url, timeout=10) as resp:
            return json.loads(resp.read().decode("utf-8"))