import unittest
from unittest.mock import patch, MagicMock
from src.production.services.city_temperature_service import CityTemperatureService
from src.production.processes.city_temperature_process import CityTemperatureProcess
from src.production.operations.city_temperature_operation import CityTemperatureOperation

class TestCityTemperatureFlow(unittest.TestCase):

    @patch.object(CityTemperatureService, 'retrieve_city_temperatures')
    @patch.object(CityTemperatureProcess, 'OnRequest')
    def test_city_temperature_flow(self, mock_process, mock_service):
        # Arrange
        mock_service.return_value = ("OK", "Temperature data")
        mock_process.return_value = ("OK", "Temperature data")
        
        service = CityTemperatureService()
        process = CityTemperatureProcess()
        operation = CityTemperatureOperation()

        # Act
        status_service = service.retrieve_city_temperatures()
        status_process = process.OnRequest("input data")
        status_operation = operation.OnMessage("input data")

        # Assert
        self.assertEqual(status_service[0], "OK")
        self.assertEqual(status_process[0], "OK")
        self.assertEqual(status_operation[0], "OK")

if __name__ == '__main__':
    unittest.main()