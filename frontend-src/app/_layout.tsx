import FontAwesome from "@expo/vector-icons/FontAwesome";
import {
    DarkTheme,
    DefaultTheme,
    ThemeProvider,
} from "@react-navigation/native";
import {useFonts} from "expo-font";
import * as SplashScreen from "expo-splash-screen";
import {useEffect} from "react";
import {GluestackUIProvider} from "@/components/ui/gluestack-ui-provider";
import {useColorScheme} from "@/components/useColorScheme";
import "../global.css";
import {SafeAreaView} from "react-native";
import {Drawer} from "expo-router/drawer";
import {Header} from "@/components/header";
import {
    DrawerContentScrollView,
    DrawerItemList,
} from '@react-navigation/drawer';


export {
    // Catch any errors thrown by the Layout component.
    ErrorBoundary,
} from "expo-router";

export const unstable_settings = {
    // Ensure that reloading on `/modal` keeps a back button present.
    initialRouteName: "index",
};

function CustomDrawerContent(props) {
    return (
        <DrawerContentScrollView {...props}>
            <DrawerItemList {...props} />
            {/* You can add more custom content here */}
        </DrawerContentScrollView>
    );
}

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

    return (
        <GluestackUIProvider mode={(colorScheme ?? "light") as "light" | "dark"}>
            <ThemeProvider value={colorScheme === "dark" ? DarkTheme : DefaultTheme}>
                <SafeAreaView className="flex-1 bg-background-primary">
                    <Drawer
                        drawerContent={(props) => <CustomDrawerContent {...props} />}
                        screenOptions={{
                            header: () => <Header/>,
                            headerShown: true
                        }}
                    >
                        {/* Define your drawer screens here */}
                        <Drawer.Screen
                            name="index"
                            options={{
                                drawerLabel: "Home",
                                title: "Home"
                            }}
                        />
                        {/* Add more screens as needed */}
                        <Drawer.Screen
                            name="docs/index"
                            options={{
                                drawerLabel: "Documentation",
                                title: "Documentation"
                            }}
                        />
                    </Drawer>
                </SafeAreaView>
            </ThemeProvider>
        </GluestackUIProvider>
    );
}