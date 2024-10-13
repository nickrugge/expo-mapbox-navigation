import { requireNativeViewManager } from "expo-modules-core";
import * as React from "react";

import type { ExpoMapboxNavigationViewProps } from "./ExpoMapboxNavigation.types";

const NativeView: React.ComponentType<ExpoMapboxNavigationViewProps> =
  requireNativeViewManager<ExpoMapboxNavigationViewProps>(
    "ExpoMapboxNavigation",
  );

export default function ExpoMapboxNavigationView(
  props: ExpoMapboxNavigationViewProps
) {
  return <NativeView {...props} />;
}
