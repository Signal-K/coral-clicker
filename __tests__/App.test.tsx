/**
 * @format
 */

import "react-native";
import ReactTestRenderer from "react-test-renderer";
import App from "../App";

jest.mock("@borndotcom/react-native-godot", () => ({
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  RTNGodotView: ({ style }: { style?: unknown }) =>
    require("react").createElement(require("react-native").View, { style }),
  RTNGodot: {
    getInstance: () => null,
    createInstance: jest.fn(),
    destroyInstance: jest.fn(),
    API: () => ({
      Engine: {
        get_main_loop: () => ({
          get_root: () => ({
            find_child: () => null,
          }),
        }),
      },
    }),
  },
  runOnGodotThread: (fn: () => void) => fn(),
}));

jest.mock("expo-file-system/legacy", () => ({
  bundleDirectory: "/tmp/",
}));

jest.mock("expo-device", () => ({
  isDevice: false,
}));

jest.mock("@react-navigation/native", () => ({
  NavigationContainer: ({ children }: { children: unknown }) =>
    require("react").createElement(require("react-native").View, null, children),
}));

jest.mock("@react-navigation/native-stack", () => ({
  createNativeStackNavigator: () => ({
    Navigator: ({ children }: { children: unknown }) =>
      require("react").createElement(require("react-native").View, null, children),
    Screen: ({ children }: { children?: unknown }) =>
      require("react").createElement(require("react-native").View, null, children ?? null),
  }),
}));

test("renders correctly", async () => {
  await ReactTestRenderer.act(() => {
    ReactTestRenderer.create(<App />);
  });
});
