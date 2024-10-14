import Mapbox from "@rnmapbox/maps";
import * as Location from "expo-location";
import { MapboxNavigationView } from "expo-mapbox-navigation";
import * as ScreenOrientation from "expo-screen-orientation";
import React from "react";
import { StyleSheet, View, Text } from "react-native";

Mapbox.setAccessToken("<TOKEN_HERE>");

export default function App() {
  React.useEffect(() => {
    ScreenOrientation.unlockAsync();
  }, []);

  React.useEffect(() => {
    (async () => {
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (status === "granted") {
        setLocationAllowed(true);
      } else {
        setLocationAllowed(false);
      }
    })();
  }, []);

  const [locationAllowed, setLocationAllowed] = React.useState(false);
  return (
    <View style={styles.container}>
      {locationAllowed ? (
        <MapboxNavigationView
          style={{ flex: 1 }}
          coordinates={[
            { latitude: 30.021, longitude: 31.4962 },
            { latitude: 30.0552, longitude: 31.4988 },
          ]}
        />
      ) : (
        <Text style={styles.text}>Location required for mapbox navigation</Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
  },
  text: {
    alignSelf: "center",
  },
});
