// components/DrawerDebug.tsx - For manual drawer
import React from "react";
import { Box } from "@/components/ui/box";
import { Text } from "@/components/ui/text";
import { Button } from "@/components/ui/button";
import { useDrawerContext } from "@/contexts/drawerContext";
import { Platform, Dimensions } from "react-native";

export const DrawerDebug = () => {
    const { isDrawerOpen, toggleDrawer, setIsDrawerOpen } = useDrawerContext();
    const { width, height } = Dimensions.get('window');

    return (
        <Box
            style={{
                position: 'fixed',
                top: 70,
                right: 16,
                backgroundColor: '#fee2e2',
                borderColor: '#fca5a5',
                borderWidth: 1,
                padding: 16,
                borderRadius: 8,
                zIndex: 1000,
                minWidth: 250,
                maxWidth: 300
            }}
        >
            <Text className="text-sm font-bold mb-2">Manual Drawer Debug</Text>
            <Text className="text-xs mb-1">Platform: {Platform.OS}</Text>
            <Text className="text-xs mb-1">Screen: {width}x{height}</Text>
            <Text className="text-xs mb-1">Drawer Open: {isDrawerOpen ? 'Yes' : 'No'}</Text>
            <Text className="text-xs mb-2">Is Tablet: {width >= 768 ? 'Yes' : 'No'}</Text>
            <Text className="text-xs mb-2">Method: Manual CSS Animation</Text>

            <Box style={{ flexDirection: 'row', gap: 8 }}>
                <Button
                    size="sm"
                    onPress={() => {
                        console.log('Debug Toggle pressed');
                        toggleDrawer();
                    }}
                    style={{ backgroundColor: '#ef4444', padding: 8, flex: 1 }}
                >
                    <Text style={{ color: 'white', fontSize: 12 }}>Toggle</Text>
                </Button>

                <Button
                    size="sm"
                    onPress={() => {
                        console.log('Debug Force Open pressed');
                        setIsDrawerOpen(true);
                    }}
                    style={{ backgroundColor: '#059669', padding: 8, flex: 1 }}
                >
                    <Text style={{ color: 'white', fontSize: 12 }}>Open</Text>
                </Button>

                <Button
                    size="sm"
                    onPress={() => {
                        console.log('Debug Force Close pressed');
                        setIsDrawerOpen(false);
                    }}
                    style={{ backgroundColor: '#dc2626', padding: 8, flex: 1 }}
                >
                    <Text style={{ color: 'white', fontSize: 12 }}>Close</Text>
                </Button>
            </Box>
        </Box>
    );
};