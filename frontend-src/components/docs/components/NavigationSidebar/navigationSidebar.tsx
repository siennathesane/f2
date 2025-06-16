import React, { useState, useEffect, useMemo } from 'react';
import { ScrollView, TouchableOpacity, Platform } from 'react-native';
import { ChevronDown, ChevronRight, X } from 'lucide-react-native';
import { Box } from '@/components/ui/box';
import { Input, InputField } from '@/components/ui/input';
import { HStack } from '@/components/ui/hstack';
import { Icon } from "@/components/ui/icon";
import { VStack } from "@/components/ui/vstack";
import { Text } from '@/components/ui/text';
import { Badge, BadgeText } from "@/components/ui/badge";
import type { NavigationSidebarProps } from '../../types';

export function NavigationSidebar({
                                      navigation,
                                      currentSlug,
                                      onNavigate,
                                      isOpen,
                                      onClose
                                  }: NavigationSidebarProps) {
    const [expandedCategories, setExpandedCategories] = useState<Set<string>>(new Set());
    const [searchQuery, setSearchQuery] = useState('');

    // Auto-expand category containing current doc
    useEffect(() => {
        if (currentSlug) {
            navigation.forEach(category => {
                if (category.children?.some(doc => doc.slug === currentSlug)) {
                    setExpandedCategories(prev => new Set([...prev, category.category!]));
                }
            });
        }
    }, [currentSlug, navigation]);

    const toggleCategory = (category: string) => {
        setExpandedCategories(prev => {
            const newSet = new Set(prev);
            if (newSet.has(category)) {
                newSet.delete(category);
            } else {
                newSet.add(category);
            }
            return newSet;
        });
    };

    const filteredNavigation = useMemo(() => {
        if (!searchQuery) return navigation;

        return navigation.map(category => ({
            ...category,
            children: category.children?.filter(doc =>
                doc.title.toLowerCase().includes(searchQuery.toLowerCase())
            ) || []
        })).filter(category => (category.children?.length || 0) > 0);
    }, [navigation, searchQuery]);

    if (!isOpen) return null;

    return (
        <Box className="absolute inset-0 z-50 md:relative md:w-80 md:flex-shrink-0">
            {/* Mobile overlay */}
            <TouchableOpacity
                className="absolute inset-0 bg-black/50 md:hidden"
                onPress={onClose}
                activeOpacity={1}
            />

            {/* Sidebar content */}
            <Box className="absolute left-0 top-0 bottom-0 w-80 bg-background-primary border-r border-border-primary md:relative md:w-full">
                <VStack className="h-full">
                    {/* Header */}
                    <HStack className="p-4 items-center justify-between border-b border-border-primary">
                        <Text className="text-text-primary text-lg font-semibold">Documentation</Text>
                        <TouchableOpacity onPress={onClose} className="md:hidden">
                            <Icon as={X} className="w-5 h-5 text-text-secondary" />
                        </TouchableOpacity>
                    </HStack>

                    {/* Search */}
                    <Box className="p-4">
                        <Input className="bg-background-secondary border-border-secondary">
                            <InputField
                                placeholder="Search docs..."
                                value={searchQuery}
                                onChangeText={setSearchQuery}
                                className="text-text-primary"
                            />
                        </Input>
                    </Box>

                    {/* Navigation */}
                    <ScrollView className="flex-1 px-2">
                        <VStack className="space-y-1 pb-4">
                            {filteredNavigation.map((category) => (
                                <VStack key={category.category} className="space-y-1">
                                    <TouchableOpacity
                                        onPress={() => toggleCategory(category.category!)}
                                        className="flex-row items-center px-3 py-2 rounded-md hover:bg-background-secondary"
                                    >
                                        <Icon
                                            as={expandedCategories.has(category.category!) ? ChevronDown : ChevronRight}
                                            className="w-4 h-4 text-text-tertiary mr-2"
                                        />
                                        <Text className="text-text-primary text-sm font-medium flex-1">
                                            {category.title}
                                        </Text>
                                        <Badge className="bg-brand-primary-muted">
                                            <BadgeText className="text-brand-primary text-xs">
                                                {category.children?.length || 0}
                                            </BadgeText>
                                        </Badge>
                                    </TouchableOpacity>

                                    {expandedCategories.has(category.category!) && (
                                        <VStack className="ml-6 space-y-1">
                                            {category.children?.map((doc) => (
                                                <TouchableOpacity
                                                    key={doc.slug}
                                                    onPress={() => {
                                                        onNavigate(doc.slug!);
                                                        if (Platform.OS !== 'web') onClose();
                                                    }}
                                                    className={`px-3 py-2 rounded-md ${
                                                        currentSlug === doc.slug
                                                            ? 'bg-brand-primary-muted border-l-2 border-brand-primary'
                                                            : 'hover:bg-background-tertiary'
                                                    }`}
                                                >
                                                    <Text
                                                        className={`text-sm ${
                                                            currentSlug === doc.slug
                                                                ? 'text-brand-primary font-medium'
                                                                : 'text-text-secondary'
                                                        }`}
                                                    >
                                                        {doc.title}
                                                    </Text>
                                                </TouchableOpacity>
                                            ))}
                                        </VStack>
                                    )}
                                </VStack>
                            ))}
                        </VStack>
                    </ScrollView>
                </VStack>
            </Box>
        </Box>
    );
}