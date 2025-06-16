import React, { useState } from 'react';
import { TouchableOpacity } from 'react-native';
import { ChevronDown, ChevronRight, Hash } from 'lucide-react-native';
import { Box } from '@/components/ui/box';
import { VStack } from '@/components/ui/vstack';
import { HStack } from '@/components/ui/hstack';
import { Icon } from '@/components/ui/icon';
import { Text } from '@/components/ui/text';
import type { TableOfContentsItem } from '../../types';

interface ExpandableTableOfContentsProps {
    toc: TableOfContentsItem[];
    onItemPress?: (item: TableOfContentsItem) => void;
}

export function ExpandableTableOfContents({
                                              toc,
                                              onItemPress
                                          }: ExpandableTableOfContentsProps) {
    const [isExpanded, setIsExpanded] = useState(false);

    if (toc.length === 0) return null;

    return (
        <Box className="mb-6">
            {/* Header */}
            <TouchableOpacity
                onPress={() => setIsExpanded(!isExpanded)}
                className="bg-background-secondary rounded-lg p-4 border border-border-secondary"
            >
                <HStack className="items-center justify-between">
                    <Text className="text-text-primary font-medium">
                        On this page ({toc.length} sections)
                    </Text>
                    <Icon
                        as={isExpanded ? ChevronDown : ChevronRight}
                        className="w-5 h-5 text-text-tertiary"
                    />
                </HStack>
            </TouchableOpacity>

            {/* Expandable content */}
            {isExpanded && (
                <Box className="mt-2 bg-background-secondary rounded-lg border border-border-secondary">
                    <VStack className="p-2">
                        {toc.map((item, index) => (
                            <TouchableOpacity
                                key={item.id}
                                onPress={() => onItemPress?.(item)}
                                className={`p-3 rounded hover:bg-background-tertiary ${
                                    item.level > 2 ? 'ml-4' : item.level > 1 ? 'ml-2' : ''
                                }`}
                            >
                                <HStack className="items-center space-x-2">
                                    <Icon as={Hash} className="w-4 h-4 text-text-tertiary" />
                                    <Text
                                        className={`flex-1 ${
                                            item.level === 1
                                                ? 'text-text-primary font-medium'
                                                : 'text-text-secondary'
                                        }`}
                                        numberOfLines={2}
                                    >
                                        {item.title}
                                    </Text>
                                </HStack>
                            </TouchableOpacity>
                        ))}
                    </VStack>
                </Box>
            )}
        </Box>
    );
}