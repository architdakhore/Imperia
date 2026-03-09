pragma ComponentBehavior: Bound

// ─────────────────────────────────────────────────────────────────────────────
// WeatherPanel.qml — Imperia Shell
// Adapted from Imperia — weather settings + live preview.
// Uses open-meteo.com (free, no API key required).
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import qs.modules.theme
import qs.modules.components
import qs.modules.globals
import qs.config

Item {
    id: root
    anchors.fill: parent

    // ── State ─────────────────────────────────────────────────────────────────
    property string temp: "--°"
    property string desc: "No data"
    property string icon: "○"
    property string locationText: ""
    property bool loading: false
    property bool useFahrenheit: false
    property string savedLocation: ""

    // Weather icon map (WMO weather codes)
    function weatherIcon(code) {
        var c = parseInt(code);
        if (c === 0 || c === 1) return "☀️";
        if (c === 2) return "⛅";
        if (c === 3) return "☁️";
        if (c >= 45 && c <= 48) return "🌫️";
        if (c >= 51 && c <= 57) return "🌦️";
        if (c >= 61 && c <= 67) return "🌧️";
        if (c >= 71 && c <= 77) return "❄️";
        if (c >= 80 && c <= 82) return "🌧️";
        if (c >= 85 && c <= 86) return "🌨️";
        if (c >= 95 && c <= 99) return "⛈️";
        return "🌡️";
    }

    function weatherDesc(code) {
        var conditions = {
            "0": "Clear sky", "1": "Mainly clear", "2": "Partly cloudy",
            "3": "Overcast", "45": "Fog", "48": "Icy fog",
            "51": "Light drizzle", "53": "Drizzle", "55": "Heavy drizzle",
            "61": "Light rain", "63": "Rain", "65": "Heavy rain",
            "71": "Light snow", "73": "Snow", "75": "Heavy snow",
            "80": "Rain showers", "81": "Rain", "82": "Heavy rain",
            "95": "Thunderstorm", "96": "Thunderstorm+hail", "99": "Thunderstorm+hail"
        };
        return conditions[String(code)] || "Unknown";
    }

    Component.onCompleted: {
        savedLocation = Config.weather?.location ?? "";
        locationField.text = savedLocation;
        if (savedLocation) fetchWeather(savedLocation);
    }

    // ── Weather fetch via curl ────────────────────────────────────────────────
    function fetchWeather(loc) {
        loading = true;
        if (loc.match(/^-?[\d.]+,-?[\d.]+$/)) {
            // Coordinates
            var parts = loc.split(",");
            doWeatherFetch(parts[0], parts[1]);
        } else {
            // City name → geocode first
            geocodeProc.running = false;
            geocodeProc.command = ["curl", "-sf",
                "https://geocoding-api.open-meteo.com/v1/search?name=" +
                encodeURIComponent(loc) + "&count=1&language=en&format=json"];
            geocodeProc.running = true;
        }
    }

    function doWeatherFetch(lat, lon) {
        weatherProc.running = false;
        weatherProc.command = ["curl", "-sf",
            "https://api.open-meteo.com/v1/forecast?latitude=" + lat +
            "&longitude=" + lon +
            "&current=temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m" +
            "&daily=temperature_2m_max,temperature_2m_min,weather_code" +
            "&timezone=auto&forecast_days=5"];
        weatherProc.running = true;
    }

    Process {
        id: geocodeProc
        property string output: ""
        onStdoutChanged: output += stdout
        onExited: {
            try {
                var json = JSON.parse(output);
                output = "";
                if (json.results && json.results.length > 0) {
                    root.locationText = json.results[0].name + ", " + json.results[0].country;
                    root.doWeatherFetch(json.results[0].latitude, json.results[0].longitude);
                } else {
                    root.desc = "Location not found";
                    root.loading = false;
                }
            } catch(e) {
                root.desc = "Geocode error";
                root.loading = false;
            }
        }
    }

    Process {
        id: weatherProc
        property string output: ""
        onStdoutChanged: output += stdout
        onExited: {
            root.loading = false;
            try {
                var json = JSON.parse(output);
                output = "";
                var c = json.current;
                var tmp = root.useFahrenheit
                    ? Math.round(c.temperature_2m * 9/5 + 32) + "°F"
                    : Math.round(c.temperature_2m) + "°C";
                root.temp = tmp;
                root.icon = root.weatherIcon(c.weather_code);
                root.desc = root.weatherDesc(c.weather_code);
                // Store forecast
                forecastModel.clear();
                for (var i = 0; i < Math.min(json.daily.time.length, 5); i++) {
                    var d = new Date(json.daily.time[i] + "T12:00:00");
                    var dayName = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"][d.getDay()];
                    var hi = root.useFahrenheit
                        ? Math.round(json.daily.temperature_2m_max[i] * 9/5 + 32) + "°F"
                        : Math.round(json.daily.temperature_2m_max[i]) + "°C";
                    var lo = root.useFahrenheit
                        ? Math.round(json.daily.temperature_2m_min[i] * 9/5 + 32) + "°F"
                        : Math.round(json.daily.temperature_2m_min[i]) + "°C";
                    forecastModel.append({
                        day: i === 0 ? "Today" : dayName,
                        icon: root.weatherIcon(json.daily.weather_code[i]),
                        hi: hi, lo: lo
                    });
                }
            } catch(e) {
                root.desc = "Weather error";
            }
        }
    }

    ListModel { id: forecastModel }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 16
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 16

            // ── Location input ────────────────────────────────────────────────
            StyledRect {
                Layout.fillWidth: true
                variant: "surface"
                radius: Config.roundness
                implicitHeight: 64

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Text {
                        text: Icons.globe
                        font.family: Icons.font
                        font.pixelSize: 20
                        color: Colors.primary
                    }

                    TextField {
                        id: locationField
                        Layout.fillWidth: true
                        placeholderText: "City name or lat,lon  (e.g. New York or 40.7,-74.0)"
                        font.family: Config.theme.font
                        font.pixelSize: Config.theme.fontSize
                        color: Colors.overBackground
                        background: Rectangle { color: "transparent" }

                        onAccepted: {
                            root.savedLocation = text;
                            root.fetchWeather(text);
                        }
                    }

                    // Unit toggle
                    Text {
                        text: root.useFahrenheit ? "°F" : "°C"
                        font.family: Config.theme.numberFont
                        font.pixelSize: 14
                        color: Colors.primary
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.useFahrenheit = !root.useFahrenheit
                        }
                    }

                    Rectangle {
                        width: 80; height: 34
                        radius: Config.roundness
                        color: fetchHover.hovered ? Colors.primary : Colors.surfaceBright

                        Text {
                            anchors.centerIn: parent
                            text: root.loading ? "..." : "Search"
                            color: fetchHover.hovered ? Colors.overPrimary : Colors.overBackground
                            font.family: Config.theme.font
                            font.pixelSize: 13
                        }
                        HoverHandler { id: fetchHover }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.savedLocation = locationField.text;
                                root.fetchWeather(locationField.text);
                            }
                        }
                    }
                }
            }

            // ── Current weather card ──────────────────────────────────────────
            StyledRect {
                Layout.fillWidth: true
                variant: "surface"
                radius: Config.roundness
                implicitHeight: 100
                visible: root.temp !== "--°"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20

                    Text {
                        text: root.icon
                        font.pixelSize: 48
                    }

                    ColumnLayout {
                        spacing: 4
                        Text {
                            text: root.temp
                            font.family: Config.theme.numberFont
                            font.pixelSize: 32
                            font.weight: Font.Bold
                            color: Colors.primary
                        }
                        Text {
                            text: root.desc
                            font.family: Config.theme.font
                            font.pixelSize: Config.theme.fontSize
                            color: Colors.outline
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: root.locationText
                        font.family: Config.theme.font
                        font.pixelSize: 13
                        color: Colors.outline
                        wrapMode: Text.WordWrap
                        Layout.maximumWidth: 160
                    }
                }
            }

            // ── 5-day forecast ────────────────────────────────────────────────
            Text {
                text: "5-Day Forecast"
                font.family: Config.theme.font
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: Colors.outline
                visible: forecastModel.count > 0
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: forecastModel.count > 0

                Repeater {
                    model: forecastModel
                    delegate: StyledRect {
                        required property string day
                        required property string icon
                        required property string hi
                        required property string lo
                        Layout.fillWidth: true
                        variant: "surface"
                        radius: Config.roundness
                        implicitHeight: 90

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 3

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: day
                                font.family: Config.theme.font
                                font.pixelSize: 11
                                color: Colors.outline
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: icon
                                font.pixelSize: 22
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: hi
                                font.family: Config.theme.numberFont
                                font.pixelSize: 13
                                color: Colors.overBackground
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: lo
                                font.family: Config.theme.numberFont
                                font.pixelSize: 11
                                color: Colors.outline
                            }
                        }
                    }
                }
            }
        }
    }
}
