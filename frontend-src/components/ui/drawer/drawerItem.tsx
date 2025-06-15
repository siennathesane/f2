import React from "react";
import { HStack } from "@/components/ui/hstack";
import { Text } from "@/components/ui/text";
import { Pressable } from "@/components/ui/pressable";

export const DrawerItem = ({ icon: Icon, label, onPress, isActive = false }) => {
    return (
        <Pressable onPress={onPress}>
            <HStack
                className={`items-center space-x-3 px-4 py-3 mx-2 rounded-lg ${
                    isActive
                        ? 'bg-primary-100 border-l-4 border-primary-600'
                        : 'hover:bg-gray-50'
                }`}
            >
                <Icon
                    size={20}
                    color={isActive ? '#2563eb' : '#6b7280'}
                />
                <Text
                    className={`text-base ${
                        isActive
                            ? 'text-primary-600 font-semibold'
                            : 'text-gray-700'
                    }`}
                >
                    {label}
                </Text>
            </HStack>
        </Pressable>
    );
};
