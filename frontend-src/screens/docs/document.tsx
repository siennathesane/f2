import React, {useState, useEffect, useMemo} from 'react';
import {ScrollView, TouchableOpacity, Dimensions, Platform} from 'react-native';
import {useLocalSearchParams, router} from 'expo-router';
import {useDocs} from '@/contexts/docsContext';
import {Menu} from 'lucide-react-native';
import {Box} from '@/components/ui/box';
import {HStack} from '@/components/ui/hstack';
import {Icon} from "@/components/ui/icon";
import {Text} from '@/components/ui/text';
import {Badge, BadgeText} from "@/components/ui/badge";
import {Button, ButtonText} from "@/components/ui/button";
import {buildNavigationTree} from "@/components/docs/utils/buildNavTree";
import {extractTableOfContents} from "@/components/docs/utils/tableOfContents";
import {NavigationSidebar} from "@/components/docs/components/NavigationSidebar";
import {TableOfContentsSidebar} from "@/components/docs/components/TableOfContentsSidebar";
import {TableOfContentsItem} from "@/components/docs/types";
import {DocumentContent} from "@/components/docs/components/DocumentContent";
import {markdownStyles} from "@/components/docs/constants/markdownStyles";

// todo(siennathesane): clean this up, it's a mess
export default function DocumentScreen() {
    const params = useLocalSearchParams<{ slug: string | string[] }>();
    const {docs, loading, error, categories} = useDocs();
    const [sidebarOpen, setSidebarOpen] = useState(false);
    const [windowWidth, setWindowWidth] = useState(Dimensions.get('window').width);

    // Handle both single slugs and nested slugs, including empty (base /docs route)
    const slug = Array.isArray(params.slug)
        ? params.slug.join('/')
        : params.slug || undefined;

    const handleCategorySelect = (category: string) => {
        setActiveCategory(category);
        // Find first doc in this category and navigate to it
        const categoryData = navigation.find(nav => nav.category === category);
        if (categoryData?.children?.[0]?.slug) {
            handleNavigate(categoryData.children[0].slug);
        }
    };

    // Update your main document.tsx handleTocItemPress function:
    const handleTocItemPress = (item: TableOfContentsItem) => {
        if (Platform.OS === 'web') {
            // On web, scroll to the heading by searching for text content
            const headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');

            for (const heading of headings) {
                if (heading.textContent?.trim() === item.title.trim()) {
                    heading.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start',
                        inline: 'nearest'
                    });

                    // Optional: highlight the heading briefly
                    heading.style.backgroundColor = 'rgba(59, 130, 246, 0.1)';
                    setTimeout(() => {
                        heading.style.backgroundColor = '';
                    }, 2000);

                    break;
                }
            }
        } else {
            // On mobile, we could implement a more complex solution later
            // For now, just collapse the TOC to give more reading space
            console.log('Navigate to section:', item.title);
        }
    };

    useEffect(() => {
        const subscription = Dimensions.addEventListener('change', ({window}) => {
            setWindowWidth(window.width);
            if (window.width >= 768) {
                setSidebarOpen(false); // Auto-close mobile sidebar on desktop
            }
        });

        return () => subscription?.remove();
    }, []);

    const navigation = useMemo(() => buildNavigationTree(docs, categories), [docs, categories]);

    // Determine which document to show - default to 'home' (index.md) if no slug provided
    const determineDefaultDoc = () => {
        if (slug) return slug;

        // Try to find a good default document in order of preference
        // 'home' is your index.md file based on the docs registry
        const preferredDefaults = ['home', 'index', 'getting-started', 'ethics'];

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
        if (!slug && activeSlug && activeSlug !== 'home') {
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
                                <Icon as={Menu} className="w-5 h-5 text-text-primary"/>
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
                        <DocumentContent
                            content={currentDoc.content}
                            markdownStyles={markdownStyles}
                            onLinkPress={(url) => {
                                // Handle docs links that already have /docs/ prefix
                                if (url.startsWith('/docs/')) {
                                    const targetSlug = url.replace('/docs/', '');
                                    handleNavigate(targetSlug);
                                    return false;
                                }

                                // Handle relative links that should be docs links
                                // Check if the URL is a relative path that matches a known doc slug
                                const cleanUrl = url.replace(/^\.\//, ''); // Remove ./ prefix if present

                                if (docs[cleanUrl]) {
                                    // This is a known document slug, navigate to it
                                    handleNavigate(cleanUrl);
                                    return false;
                                }

                                // Check if it's a relative path without extension that might be a doc
                                if (!url.startsWith('http') && !url.startsWith('/') && !url.includes('.')) {
                                    // Might be a relative doc link, try navigating to it as a doc
                                    handleNavigate(cleanUrl);
                                    return false;
                                }

                                // For external links or other URLs, allow default behavior
                                return true;
                            }}
                        />
                    </Box>
                </ScrollView>

                {/* Table of contents sidebar */}
                <TableOfContentsSidebar toc={toc} isOpen={windowWidth >= 1024}/>
            </HStack>
        </Box>
    );
}