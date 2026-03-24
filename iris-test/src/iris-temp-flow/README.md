# iris-temp-flow

## Overview
The `iris-temp-flow` project implements a flow using the `intersystems_pyprod` library to retrieve temperature data for specified cities at regular intervals. The flow is triggered by a Business Service that executes based on a configurable `CallInterval` parameter.

## Project Structure
```
iris-temp-flow
├── src
│   ├── main.py                     # Entry point for the application
│   └── production
│       ├── __init__.py             # Marks the production directory as a package
│       ├── adapters
│       │   ├── __init__.py         # Marks the adapters directory as a package
│       │   ├── inbound_call_interval_adapter.py  # Inbound adapter for triggering service execution
│       │   └── outbound_weather_api_adapter.py   # Outbound adapter for weather API interaction
│       ├── services
│       │   ├── __init__.py         # Marks the services directory as a package
│       │   └── city_temperature_service.py      # Service for managing temperature data retrieval
│       ├── processes
│       │   ├── __init__.py         # Marks the processes directory as a package
│       │   └── city_temperature_process.py      # Business Process for retrieving city temperatures
│       ├── operations
│       │   ├── __init__.py         # Marks the operations directory as a package
│       │   └── city_temperature_operation.py    # Business Operation for fetching temperature data
│       ├── messages
│       │   ├── __init__.py         # Marks the messages directory as a package
│       │   └── temperature_messages.py            # Message classes for temperature data handling
│       └── config
│           ├── __init__.py         # Marks the config directory as a package
│           └── city_list.py        # List of cities for temperature retrieval
├── tests
│   └── test_city_temperature_flow.py # Unit tests for the flow
├── requirements.txt                 # Project dependencies
├── pyproject.toml                   # Project configuration
└── README.md                        # Documentation for the project
```

## Setup Instructions
1. Clone the repository:
   ```
   git clone https://github.com/SylvainGuilbaud/iris-test.git
   cd iris-temp-flow
   ```

2. Install the required dependencies:
   ```
   pip install -r requirements.txt
   ```

3. Configure the `CallInterval` parameter and city list in `src/production/config/city_list.py`.

4. Run the application:
   ```
   python src/main.py
   ```

## Usage
The application will trigger the Business Service at the specified intervals, retrieving temperature data for the cities defined in the configuration. The retrieved data will be processed and logged accordingly.

## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.