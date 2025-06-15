// Enhanced Doks-style documentation layout for f2
// This replaces the current documentationScreen.tsx with a modern, structured layout

import React, { useState, useEffect, useMemo } from 'react';
import { ScrollView, TouchableOpacity, Dimensions, Platform } from 'react-native';
import { useLocalSearchParams, router } from 'expo-router';
import { useDocs } from '@/contexts/docsContext';
import Markdown from 'react-native-markdown-display';
import { Search, ChevronDown, ChevronRight, Menu, X, Hash } from 'lucide-react-native';
import { Box } from '@/components/ui/box';
import {Input, InputField} from '@/components/ui/input';
import { HStack } from '@/components/ui/hstack';
import {Icon} from "@/components/ui/icon";
import {VStack} from "@/components/ui/vstack";
import { Text } from '@/components/ui/text';
import {Badge, BadgeText} from "@/components/ui/badge";
import {Button, ButtonText} from "@/components/ui/button";

// Types
interface TableOfContentsItem {
    id: string;
    title: string;
    level: number;
}

interface NavigationItem {
    title: string;
    slug?: string;
    category?: string;
    children?: NavigationItem[];
    isCategory?: boolean;
}

// Navigation tree builder
function buildNavigationTree(docs: any, categories: string[]): NavigationItem[] {
    const categoryOrder = ['general', 'workflows', 'policies', 'design', 'technical', 'api'];
    const categoryIcons: Record<string, string> = {
        'general': '📚',
        'workflows': '⚙️',
        'policies': '⚖️',
        'design': '🎨',
        'technical': '🔧',
        'api': '🔌'
    };

    const categoryNames: Record<string, string> = {
        'general': 'General',
        'workflows': 'Technical Workflows',
        'policies': 'Policies & Ethics',
        'design': 'Design System',
        'technical': 'Technical Docs',
        'api': 'API Reference'
    };

    const sortedCategories = [...categories].sort((a, b) => {
        const aIndex = categoryOrder.indexOf(a);
        const bIndex = categoryOrder.indexOf(b);
        if (aIndex === -1 && bIndex === -1) return a.localeCompare(b);
        if (aIndex === -1) return 1;
        if (bIndex === -1) return -1;
        return aIndex - bIndex;
    });

    return sortedCategories.map(category => {
        const docsInCategory = Object.values(docs).filter((doc: any) => doc.category === category);
        const sortedDocs = docsInCategory.sort((a: any, b: any) => {
            const orderA = a.frontmatter.order || 999;
            const orderB = b.frontmatter.order || 999;
            if (orderA !== orderB) return orderA - orderB;
            return a.frontmatter.title.localeCompare(b.frontmatter.title);
        });

        return {
            title: `${categoryIcons[category] || '📄'} ${categoryNames[category] || category}`,
            category,
            isCategory: true,
            children: sortedDocs.map((doc: any) => ({
                title: doc.frontmatter.title,
                slug: doc.slug,
                category: doc.category
            }))
        };
    });
}

// Extract table of contents from markdown
function extractTableOfContents(content: string): TableOfContentsItem[] {
    const headingRegex = /^(#{1,6})\s+(.+)$/gm;
    const toc: TableOfContentsItem[] = [];
    let match;

    while ((match = headingRegex.exec(content)) !== null) {
        const level = match[1].length;
        const title = match[2].trim();
        const id = title.toLowerCase().replace(/[^a-z0-9\s]/g, '').replace(/\s+/g, '-');

        toc.push({
            id,
            title,
            level
        });
    }

    return toc;
}

// Navigation sidebar component
function NavigationSidebar({
                               navigation,
                               currentSlug,
                               onNavigate,
                               isOpen,
                               onClose
                           }: {
    navigation: NavigationItem[];
    currentSlug: string | undefined;
    onNavigate: (slug: string) => void;
    isOpen: boolean;
    onClose: () => void;
}) {
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

// Table of contents sidebar component
function TableOfContentsSidebar({
                                    toc,
                                    isOpen
                                }: {
    toc: TableOfContentsItem[];
    isOpen: boolean;
}) {
    if (!isOpen || toc.length === 0) return null;

    return (
        <Box className="hidden lg:block w-64 flex-shrink-0 border-l border-border-primary">
            <VStack className="sticky top-4 p-4">
                <Text className="text-text-primary text-sm font-semibold mb-4">On this page</Text>
                <VStack className="space-y-2">
                    {toc.map((item) => (
                        <TouchableOpacity
                            key={item.id}
                            className={`flex-row items-center py-1 px-2 rounded hover:bg-background-tertiary ${
                                item.level > 2 ? 'ml-4' : ''
                            }`}
                        >
                            <Icon as={Hash} className="w-3 h-3 text-text-tertiary mr-2" />
                            <Text
                                className={`text-xs flex-1 ${
                                    item.level === 1 ? 'text-text-primary font-medium' : 'text-text-tertiary'
                                }`}
                                numberOfLines={2}
                            >
                                {item.title}
                            </Text>
                        </TouchableOpacity>
                    ))}
                </VStack>
            </VStack>
        </Box>
    );
}

// Code block with tabs (like Doks npm/pnpm/yarn tabs)
function CodeBlock({ children, className }: { children: string; className?: string }) {
    const [activeTab, setActiveTab] = useState('npm');

    // Check if this is a package manager command
    const isPackageManagerCode = children.includes('npm ') || children.includes('yarn ') || children.includes('pnpm ');

    if (isPackageManagerCode) {
        const tabs = [
            { id: 'npm', label: 'npm', prefix: 'npm' },
            { id: 'pnpm', label: 'pnpm', prefix: 'pnpm' },
            { id: 'yarn', label: 'Yarn', prefix: 'yarn' }
        ];

        const convertCommand = (command: string, targetManager: string) => {
            return command
                .replace(/npm install/g, targetManager === 'yarn' ? 'yarn add' : `${targetManager} install`)
                .replace(/npm run/g, targetManager === 'yarn' ? 'yarn' : `${targetManager} run`)
                .replace(/npm start/g, targetManager === 'yarn' ? 'yarn start' : `${targetManager} start`);
        };

        return (
            <VStack className="my-4">
                {/* Tabs */}
                <HStack className="bg-background-tertiary rounded-t-lg border border-border-primary border-b-0">
                    {tabs.map((tab) => (
                        <TouchableOpacity
                            key={tab.id}
                            onPress={() => setActiveTab(tab.id)}
                            className={`px-4 py-2 border-r border-border-primary last:border-r-0 ${
                                activeTab === tab.id
                                    ? 'bg-background-primary border-b border-background-primary'
                                    : 'hover:bg-background-secondary'
                            }`}
                        >
                            <Text
                                className={`text-sm font-medium ${
                                    activeTab === tab.id ? 'text-text-primary' : 'text-text-tertiary'
                                }`}
                            >
                                {tab.label}
                            </Text>
                        </TouchableOpacity>
                    ))}
                </HStack>

                {/* Code content */}
                <Box className="bg-background-tertiary border border-border-primary rounded-b-lg p-4">
                    <Text className="font-mono text-sm text-text-primary">
                        {convertCommand(children, activeTab)}
                    </Text>
                </Box>
            </VStack>
        );
    }

    // Regular code block
    return (
        <Box className="bg-background-tertiary border border-border-primary rounded-lg p-4 my-4">
            <Text className="font-mono text-sm text-text-primary">{children}</Text>
        </Box>
    );
}

// Main documentation component
export default function Document() {
    const { slug } = useLocalSearchParams<{ slug: string }>();
    const { docs, loading, error, categories } = useDocs();
    const [sidebarOpen, setSidebarOpen] = useState(false);
    const [windowWidth, setWindowWidth] = useState(Dimensions.get('window').width);

    useEffect(() => {
        const subscription = Dimensions.addEventListener('change', ({ window }) => {
            setWindowWidth(window.width);
            if (window.width >= 768) {
                setSidebarOpen(false); // Auto-close mobile sidebar on desktop
            }
        });

        return () => subscription?.remove();
    }, []);

    const navigation = useMemo(() => buildNavigationTree(docs, categories), [docs, categories]);

    // Determine which document to show - default to 'index' if no slug provided
    const determineDefaultDoc = () => {
        if (slug) return slug;

        // Try to find a good default document in order of preference
        const preferredDefaults = ['index', 'ethics', 'home', 'getting-started'];

        for (const defaultSlug of preferredDefaults) {
            if (docs[defaultSlug]) return defaultSlug;
        }

        // Fall back to the first available doc
        const firstDoc = Object.keys(docs)[0];
        return firstDoc;
    };

    const activeSlug = determineDefaultDoc();
    const currentDoc = activeSlug ? docs[activeSlug] : null;
    const toc = currentDoc ? extractTableOfContents(currentDoc.content) : [];

    const handleNavigate = (targetSlug: string) => {
        router.push(`/docs/${targetSlug}`);
    };

    // Auto-redirect to default doc if we're on bare /docs
    useEffect(() => {
        if (!slug && activeSlug && activeSlug !== 'index') {
            router.replace(`/docs/${activeSlug}`);
        }
    }, [slug, activeSlug]);

    if (loading) {
        return (
            <Box className="flex-1 bg-background-primary justify-center items-center">
                <Text className="text-text-secondary">Loading documentation...</Text>
            </Box>
        );
    }

    if (error) {
        return (
            <Box className="flex-1 bg-background-primary justify-center items-center p-4">
                <Text className="text-error-500 text-center mb-4">{error}</Text>
                <Button onPress={() => router.push('/docs')}>
                    <ButtonText>Back to Docs</ButtonText>
                </Button>
            </Box>
        );
    }

    if (!currentDoc) {
        return (
            <Box className="flex-1 bg-background-primary justify-center items-center p-4">
                <Text className="text-text-primary text-xl mb-2">No documentation found</Text>
                <Text className="text-text-tertiary text-center">
                    No documents are available to display.
                </Text>
            </Box>
        );
    }

    return (
        <Box className="flex-1 bg-background-primary">
            <HStack className="flex-1">
                {/* Navigation sidebar */}
                <NavigationSidebar
                    navigation={navigation}
                    currentSlug={activeSlug}
                    onNavigate={handleNavigate}
                    isOpen={windowWidth >= 768 || sidebarOpen}
                    onClose={() => setSidebarOpen(false)}
                />

                {/* Main content area */}
                <ScrollView className="flex-1">
                    <Box className="max-w-4xl mx-auto p-6">
                        {/* Mobile menu button */}
                        {windowWidth < 768 && (
                            <TouchableOpacity
                                onPress={() => setSidebarOpen(true)}
                                className="mb-6 p-2 bg-background-secondary rounded-lg self-start"
                            >
                                <Icon as={Menu} className="w-5 h-5 text-text-primary" />
                            </TouchableOpacity>
                        )}

                        {/* Category badge */}
                        <Box className="mb-6">
                            <Badge className="bg-brand-primary-muted">
                                <BadgeText className="text-brand-primary">
                                    {currentDoc.category}
                                </BadgeText>
                            </Badge>
                        </Box>

                        {/* Markdown content */}
                        <Markdown
                            style={{
                                body: {
                                    color: 'var(--text-text-secondary)',
                                    fontSize: 16,
                                    lineHeight: 26
                                },
                                heading1: {
                                    color: 'var(--text-text-primary)',
                                    fontSize: 32,
                                    fontWeight: '700',
                                    marginBottom: 20,
                                    marginTop: 32,
                                    lineHeight: 40
                                },
                                heading2: {
                                    color: 'var(--text-text-primary)',
                                    fontSize: 26,
                                    fontWeight: '600',
                                    marginBottom: 16,
                                    marginTop: 28,
                                    lineHeight: 34
                                },
                                heading3: {
                                    color: 'var(--text-text-primary)',
                                    fontSize: 22,
                                    fontWeight: '600',
                                    marginBottom: 12,
                                    marginTop: 24,
                                    lineHeight: 30
                                },
                                paragraph: {
                                    color: 'var(--text-text-secondary)',
                                    lineHeight: 26,
                                    marginBottom: 18
                                },
                                code_inline: {
                                    backgroundColor: 'var(--bg-background-tertiary)',
                                    color: 'var(--text-brand-primary)',
                                    padding: 6,
                                    borderRadius: 6,
                                    fontFamily: 'monospace',
                                    fontSize: 14
                                },
                                code_block: {
                                    backgroundColor: 'var(--bg-background-tertiary)',
                                    padding: 20,
                                    borderRadius: 8,
                                    marginBottom: 20,
                                    marginTop: 20,
                                    fontFamily: 'monospace',
                                    fontSize: 14,
                                    borderWidth: 1,
                                    borderColor: 'var(--border-border-primary)'
                                },
                                fence: {
                                    backgroundColor: 'var(--bg-background-tertiary)',
                                    padding: 20,
                                    borderRadius: 8,
                                    marginBottom: 20,
                                    marginTop: 20,
                                    fontFamily: 'monospace',
                                    fontSize: 14,
                                    borderWidth: 1,
                                    borderColor: 'var(--border-border-primary)'
                                },
                                link: {
                                    color: 'var(--text-brand-primary)',
                                    textDecorationLine: 'underline'
                                },
                                list_item: {
                                    color: 'var(--text-text-secondary)',
                                    marginBottom: 8,
                                    lineHeight: 24
                                },
                                bullet_list: {
                                    marginBottom: 18,
                                    marginLeft: 16
                                },
                                ordered_list: {
                                    marginBottom: 18,
                                    marginLeft: 16
                                },
                                blockquote: {
                                    backgroundColor: 'var(--bg-brand-primary-muted)',
                                    borderLeftWidth: 4,
                                    borderLeftColor: 'var(--border-brand-primary)',
                                    paddingLeft: 20,
                                    paddingVertical: 16,
                                    marginBottom: 20,
                                    marginTop: 20,
                                    borderRadius: 6,
                                    fontStyle: 'italic'
                                },
                                hr: {
                                    backgroundColor: 'var(--border-border-secondary)',
                                    height: 1,
                                    marginVertical: 32
                                },
                                table: {
                                    borderWidth: 1,
                                    borderColor: 'var(--border-border-primary)',
                                    marginBottom: 20,
                                    borderRadius: 8,
                                    overflow: 'hidden'
                                },
                                thead: {
                                    backgroundColor: 'var(--bg-background-secondary)'
                                },
                                th: {
                                    color: 'var(--text-text-primary)',
                                    fontWeight: '600',
                                    padding: 16,
                                    borderBottomWidth: 1,
                                    borderBottomColor: 'var(--border-border-primary)',
                                    textAlign: 'left'
                                },
                                td: {
                                    color: 'var(--text-text-secondary)',
                                    padding: 16,
                                    borderBottomWidth: 1,
                                    borderBottomColor: 'var(--border-border-muted)'
                                }
                            }}
                            onLinkPress={(url) => {
                                if (url.startsWith('/docs/')) {
                                    const targetSlug = url.replace('/docs/', '');
                                    handleNavigate(targetSlug);
                                    return false;
                                }
                                return true;
                            }}
                        >
                            {currentDoc.content}
                        </Markdown>

                        {/* Navigation footer */}
                        <Box className="mt-12 pt-8 border-t border-border-primary">
                            <HStack className="justify-between">
                                <Button
                                    variant="outline"
                                    onPress={() => {
                                        const homeDoc = docs['index'] || docs['ethics'] || Object.values(docs)[0];
                                        if (homeDoc) {
                                            router.push(`/docs/${homeDoc.slug}`);
                                        }
                                    }}
                                >
                                    <ButtonText>← Documentation Home</ButtonText>
                                </Button>
                            </HStack>
                        </Box>
                    </Box>
                </ScrollView>

                {/* Table of contents sidebar */}
                <TableOfContentsSidebar toc={toc} isOpen={windowWidth >= 1024} />
            </HStack>
        </Box>
    );
}