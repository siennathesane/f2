import {DrawerToggleProvider} from "@/contexts/drawerToggleContext";

if (typeof global.Buffer === 'undefined') {
    const {Buffer} = require('buffer');
    global.Buffer = Buffer;
}

import 'react-native-get-random-values';
import 'react-native-url-polyfill/auto';
import FontAwesome from "@expo/vector-icons/FontAwesome";
import {
    DarkTheme,
    DefaultTheme,
    ThemeProvider,
} from "@react-navigation/native";
import {useFonts} from "expo-font";
import * as SplashScreen from "expo-splash-screen";
import {useCallback, useEffect, useRef, useState} from "react";
import {GluestackUIProvider} from "@/components/ui/gluestack-ui-provider";
import {useColorScheme} from "@/components/useColorScheme";
import "../global.css";
import {Drawer} from "expo-router/drawer";
import {MainDrawer} from "@/app/mainDrawer";
import {Header} from "@/components/ui/header/header";
import {SafeAreaView} from "react-native";
import {Box} from "@/components/ui/box";

export {
    // Catch any errors thrown by the Layout component.
    ErrorBoundary,
} from "expo-router";

export const unstable_settings = {
    // Ensure that reloading on `/modal` keeps a back button present.
    initialRouteName: "index",
};

// Prevent the splash screen from auto-hiding before asset loading is complete.
SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
    const [loaded, error] = useFonts({
        SpaceMono: require("../assets/fonts/SpaceMono-Regular.ttf"),
        ...FontAwesome.font,
    });

    // Expo Router uses Error Boundaries to catch errors in the navigation tree.
    useEffect(() => {
        if (error) throw error;
    }, [error]);

    useEffect(() => {
        if (loaded) {
            SplashScreen.hideAsync();
        }
    }, [loaded]);

    if (!loaded) {
        return null;
    }

    return <RootLayoutNav/>;
}

function RootLayoutNav() {
    const colorScheme = useColorScheme();
    const [navigation, setNavigation] = useState<any>(null);

    const toggleDrawer = useCallback(() => {
        if (navigation) {
            // Use React Navigation's DrawerActions
            const { DrawerActions } = require('@react-navigation/native');
            navigation.dispatch(DrawerActions.toggleDrawer());
        }
    }, [navigation]);

    return (
        <GluestackUIProvider mode={(colorScheme ?? "light") as "light" | "dark"}>
            <ThemeProvider value={colorScheme === "dark" ? DarkTheme : DefaultTheme}>
                <DrawerToggleProvider value={toggleDrawer}>
                    <SafeAreaView className="flex-1 bg-background-primary">
                        <Header />
                        <Box className="flex-1">
                            <Drawer
                                drawerContent={(props) => {
                                    // Capture navigation when drawer renders
                                    if (!navigation && props.navigation) {
                                        setNavigation(props.navigation);
                                    }
                                    return <MainDrawer {...props} />;
                                }}
                                screenOptions={{
                                    headerShown: false,
                                    // ... rest of options
                                }}
                            >
                                {/* All your screens */}
                            </Drawer>
                        </Box>
                    </SafeAreaView>
                </DrawerToggleProvider>
            </ThemeProvider>
        </GluestackUIProvider>
    );
}