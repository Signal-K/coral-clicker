import "setimmediate";
import React, { useEffect, useState } from "react";
import {
  RTNGodot,
  RTNGodotView,
  runOnGodotThread,
} from "@borndotcom/react-native-godot";
import * as FileSystem from "expo-file-system/legacy";
import * as Device from "expo-device";
import {
  ActivityIndicator,
  Button,
  Platform,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from "react-native";
import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";

const Stack = createNativeStackNavigator();

interface GodotController {
  select_level(level: number): boolean;
  complete_current_level(reward?: number): unknown;
  sync_progress_to_supabase(): boolean;
  load_progress_from_supabase(): boolean;
  get_level_state_json(): string;
  emit_level_state(): void;
}

function initGodot(name: string): void {
  if (RTNGodot.getInstance() != null) {
    return;
  }

  runOnGodotThread(() => {
    "worklet";

    if (Platform.OS === "android") {
      RTNGodot.createInstance([
        "--verbose",
        "--path",
        "/" + name,
        "--rendering-driver",
        "opengl3",
        "--rendering-method",
        "gl_compatibility",
        "--display-driver",
        "embedded",
      ]);
    } else {
      const args = [
        "--verbose",
        "--main-pack",
        FileSystem.bundleDirectory + name + ".pck",
        "--display-driver",
        "embedded",
      ];

      if (Device.isDevice) {
        args.push("--rendering-driver", "opengl3", "--rendering-method", "gl_compatibility");
      } else {
        args.push("--rendering-driver", "metal", "--rendering-method", "mobile");
      }

      RTNGodot.createInstance(args);
    }
  });
}

function destroyGodot(): void {
  runOnGodotThread(() => {
    "worklet";
    RTNGodot.destroyInstance();
  });
}

const getController = () => {
  "worklet";
  if (!RTNGodot.getInstance()) {
    return null;
  }

  const Godot = RTNGodot.API();
  const engine = Godot.Engine;
  const sceneTree = engine.get_main_loop();
  const root = sceneTree.get_root();
  return root.find_child("AppController", true, false) as GodotController | null;
};

const emitLevelState = () => {
  runOnGodotThread(() => {
    "worklet";
    const controller = getController();
    if (!controller) {
      return;
    }
    controller.emit_level_state();
  });
};

const selectLevelOnGodot = (level: number) => {
  runOnGodotThread(() => {
    "worklet";
    const controller = getController();
    if (!controller) {
      return;
    }
    controller.select_level(level);
    controller.emit_level_state();
  });
};

const completeCurrentLevelOnGodot = () => {
  runOnGodotThread(() => {
    "worklet";
    const controller = getController();
    if (!controller) {
      return;
    }
    controller.complete_current_level(100);
  });
};

const syncProgressOnGodot = () => {
  runOnGodotThread(() => {
    "worklet";
    const controller = getController();
    if (!controller) {
      return;
    }
    controller.sync_progress_to_supabase();
  });
};

const loadProgressOnGodot = () => {
  runOnGodotThread(() => {
    "worklet";
    const controller = getController();
    if (!controller) {
      return;
    }
    controller.load_progress_from_supabase();
  });
};

const LoadingScreen = ({ navigation }: any) => {
  return (
    <SafeAreaView style={styles.loadingContainer}>
      <ActivityIndicator size="large" color="#0a7ea4" />
      <Text style={styles.loadingText}>Godot host is ready.</Text>
      <View style={styles.openButton}>
        <Button title="Open Game" onPress={() => navigation.navigate("Game")} />
      </View>
    </SafeAreaView>
  );
};

const GameScreen = () => {
  const [localStatus, setLocalStatus] = useState("Waiting for level state...");

  useEffect(() => {
    initGodot("GodotTest");

    const timer = setInterval(() => {
      runOnGodotThread(() => {
        "worklet";
        const controller = getController();
        if (!controller) {
          return;
        }
        const raw = controller.get_level_state_json();
        console.log("level_state", raw);
      });
    }, 5000);

    return () => {
      clearInterval(timer);
      destroyGodot();
    };
  }, []);

  const selectLevel = (level: number) => {
    setLocalStatus(`Selecting level ${level}`);
    selectLevelOnGodot(level);
  };

  return (
    <View style={styles.gameContainer}>
      <RTNGodotView style={styles.fullscreenGodot} />

      <SafeAreaView style={styles.overlay}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.controlsRow}>
          <Button title="L1" onPress={() => selectLevel(1)} />
          <Button title="L2" onPress={() => selectLevel(2)} />
          <Button title="L3" onPress={() => selectLevel(3)} />
          <Button title="L4" onPress={() => selectLevel(4)} />
          <Button title="L5" onPress={() => selectLevel(5)} />
          <Button title="Refresh" onPress={emitLevelState} />
          <Button title="Complete" onPress={completeCurrentLevelOnGodot} />
          <Button title="Sync" onPress={syncProgressOnGodot} />
          <Button title="Load" onPress={loadProgressOnGodot} />
        </ScrollView>
        <Text style={styles.statusText}>{localStatus}</Text>
      </SafeAreaView>
    </View>
  );
};

const App = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Loading">
        <Stack.Screen name="Loading" component={LoadingScreen} options={{ headerShown: false }} />
        <Stack.Screen name="Game" component={GameScreen} options={{ headerShown: false, presentation: "modal" }} />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#ffffff",
  },
  loadingText: {
    marginTop: 12,
    fontSize: 16,
  },
  openButton: {
    marginTop: 16,
    width: 180,
  },
  gameContainer: {
    flex: 1,
    backgroundColor: "black",
  },
  fullscreenGodot: {
    ...StyleSheet.absoluteFillObject,
  },
  overlay: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    padding: 8,
  },
  controlsRow: {
    gap: 8,
    paddingRight: 16,
  },
  statusText: {
    color: "#ffffff",
    marginTop: 8,
    backgroundColor: "rgba(0,0,0,0.5)",
    paddingHorizontal: 8,
    paddingVertical: 4,
  },
});

export default App;
