import React from "react";
import { HStack } from "@/components/ui/hstack";
import { Box } from "@/components/ui/box";
import { Text } from "@/components/ui/text";
import { Pressable } from "@/components/ui/pressable";
import { SquareMenu } from "lucide-react-native";
import {useDrawerToggle} from "@/contexts/drawerToggleContext";

export const Header = () => {
    const toggleDrawer = useDrawerToggle();

    return (
        <Box className="border-b border-outline-200 bg-background-primary">
            <HStack className="items-center h-14 w-full">
                <Pressable
                    onPress={toggleDrawer}
                    className="p-3 pl-4"
                    hitSlop={{top: 10, bottom: 10, left: 10, right: 10}}
                >
                    <SquareMenu size={28} className="text-gray-700" />
                </Pressable>

                <Box className="items-center flex-1">
                    <Text className="text-3xl font-bold font-mono text-typography-900">
                        f2
                    </Text>
                </Box>

                <Box className="w-16"/>
            </HStack>
        </Box>
    );
};