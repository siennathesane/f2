import React from 'react';
import { ScrollView, TouchableOpacity } from 'react-native';
import { Search } from 'lucide-react-native';
import { Box } from '@/components/ui/box';
import { HStack } from '@/components/ui/hstack';
import { Icon } from '@/components/ui/icon';
import { Text } from '@/components/ui/text';
import {NavigationItem} from "@/components/docs/types";

interface HorizontalCategoryTabsProps {
    categories: NavigationItem[];
    activeCategory?: string;
    onCategorySelect: (category: string) => void;
    onSearchPress: () => void;
}

export function HorizontalCategoryTabs({
                                           categories,
                                           activeCategory,
                                           onCategorySelect,
                                           onSearchPress
                                       }: HorizontalCategoryTabsProps) {
    return (
        <Box className="bg-background-primary border-b border-border-primary">
            <HStack className="items-center px-4 py-3">
                {/* Scrollable category tabs */}
                <ScrollView
                    horizontal
                    showsHorizontalScrollIndicator={false}
                    className="flex-1"
                    contentContainerStyle={{ paddingRight: 16 }}
                >
                    <HStack className="space-x-2">
                        {categories.map((category) => (
                            <TouchableOpacity
                                key={category.category}
                                onPress={() => onCategorySelect(category.category!)}
                                className={`px-4 py-2 rounded-full border ${
                                    activeCategory === category.category
                                        ? 'bg-brand-primary border-brand-primary'
                                        : 'bg-background-secondary border-border-secondary'
                                }`}
                            >
                                <Text
                                    className={`text-sm font-medium whitespace-nowrap ${
                                        activeCategory === category.category
                                            ? 'text-text-primary-inverse'
                                            : 'text-text-secondary'
                                    }`}
                                >
                                    {category.title}
                                </Text>
                            </TouchableOpacity>
                        ))}
                    </HStack>
                </ScrollView>

                {/* Search button */}
                <TouchableOpacity
                    onPress={onSearchPress}
                    className="ml-3 p-2 bg-background-secondary rounded-lg"
                >
                    <Icon as={Search} className="w-5 h-5 text-text-secondary" />
                </TouchableOpacity>
            </HStack>
        </Box>
    );
}