import React from 'react';
import { TouchableOpacity } from 'react-native';
import { List } from 'lucide-react-native';
import { Icon } from '@/components/ui/icon';
import { Text } from '@/components/ui/text';
import { HStack } from '@/components/ui/hstack';
import { Box } from '@/components/ui/box';

interface FloatingBrowseButtonProps {
    onPress: () => void;
}

export function FloatingBrowseButton({ onPress }: FloatingBrowseButtonProps) {
    return (
        <Box className="absolute bottom-6 right-6 z-50">
            <TouchableOpacity
                onPress={onPress}
                className="bg-brand-primary rounded-full shadow-lg px-4 py-3"
            >
                <HStack className="items-center space-x-2">
                    <Icon as={List} className="w-5 h-5 text-text-primary-inverse" />
                    <Text className="text-text-primary-inverse font-medium">
                        Browse All
                    </Text>
                </HStack>
            </TouchableOpacity>
        </Box>
    );
}