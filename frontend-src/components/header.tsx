// components/Header.tsx
import React from "react";
import { HStack } from "@/components/ui/hstack";
import { Box } from "@/components/ui/box";
import { Text } from "@/components/ui/text";
import { Pressable } from "@/components/ui/pressable";
import { SquareMenu } from "lucide-react-native";
import { useNavigation, DrawerActions } from '@react-navigation/native';

export const Header = () => {
    const navigation = useNavigation();

    return (
        <Box className="border-b border-outline-200 sticky top-0 z-10 bg-background-primary">
            <HStack className="items-center h-14 max-w-screen-xl mx-auto">
                {/* Left section with menu button - no padding on left */}
                <Pressable
                    onPress={() => navigation.dispatch(DrawerActions.toggleDrawer())}
                    className="p-4 pl-2"
                    hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
                >
                    <SquareMenu size={28} />
                </Pressable>

                {/* Center column for title */}
                <Box className="items-center flex-1">
                    <Text className="text-xl font-bold font-mono text-typography-900">
                        f2
                    </Text>
                </Box>

                {/* Right spacing */}
                <Box className="w-16" />
            </HStack>
        </Box>
    );
};