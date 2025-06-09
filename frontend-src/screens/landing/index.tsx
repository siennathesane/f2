import React from "react";
import {HStack} from "@/components/ui/hstack";
import {Box} from "@/components/ui/box";
import {Pressable} from "@/components/ui/pressable";
import {Center} from "@/components/ui/center";
import {VStack} from "@/components/ui/vstack";
import {Text} from "@/components/ui/text";
import {ScrollView} from "@/components/ui/scroll-view";
import {verifyInstallation} from "nativewind";

export const LandingScreen = () => {
    return (
        <Box className="flex-1 bg-background-primary text-text-primary">
            {/* Sticky Header */}
            <Box className="border-b border-outline-200 sticky top-0 z-10">
                <HStack className="justify-start items-center px-6 py-4 max-w-screen-xl mx-auto">
                    <Text className="text-xl font-bold font-mono text-typography-900 mr-8">
                        f2
                    </Text>

                    {/*<HStack className="space-x-6 hidden md:flex">*/}
                    {/*  <Pressable>*/}
                    {/*    <Text className="text-typography-600 text-sm">Docs</Text>*/}
                    {/*  </Pressable>*/}
                    {/*  <Pressable>*/}
                    {/*    <Text className="text-typography-600 text-sm">Showcase</Text>*/}
                    {/*  </Pressable>*/}
                    {/*  <Pressable>*/}
                    {/*    <Text className="text-typography-600 text-sm">Blog</Text>*/}
                    {/*  </Pressable>*/}
                    {/*  <Pressable>*/}
                    {/*    <Text className="text-typography-600 text-sm">Community</Text>*/}
                    {/*  </Pressable>*/}
                    {/*</HStack>*/}
                </HStack>
            </Box>

            {/* Scrollable Content */}
            <ScrollView className="flex-1">
                <Box className="flex-1">

                    {/* Hero Section */}
                    <Center className="py-20 px-6">
                        <VStack className="space-y-6 items-center max-w-3xl">
                            <Text
                                className="text-4xl md:text-5xl font-bold font-mono text-center text-typography-900 leading-tight">
                                f*ck the facists
                            </Text>

                            <Text
                                className="text-lg md:text-xl text-center text-typography-600 max-w-2xl leading-relaxed">
                                The same class of intelligence tools that billion-dollar companies use, now being built by the people, for the people.
                            </Text>

                            <Box className="bg-yellow-200 border-2 border-yellow-400 px-8 py-4 rounded-lg mt-4">
                                <Text className="text-yellow-800 font-bold text-center">
                                    🚧 Coming Soon 🚧
                                </Text>
                            </Box>
                        </VStack>
                    </Center>

                    {/* Features */}
                    <Box className="py-16 px-6 bg-primary-50">
                        <VStack className="space-y-12 max-w-screen-lg mx-auto">
                            <HStack className="flex-wrap justify-center gap-8 md:justify-between">
                                {/* Feature 1 */}
                                <VStack className="space-y-4 items-center text-center flex-1 min-w-64">
                                    <Box
                                        className="w-16 h-16 bg-secondary-50 rounded-full flex items-center justify-center">
                                        <Text className="text-primary-600 text-2xl">💡</Text>
                                    </Box>
                                    <Text className="text-xl font-semibold text-typography-900">
                                        Why?
                                    </Text>
                                    <Text className="text-typography-600 leading-relaxed">
                                        Governments, corporations, and organizations are using data and AI to surveil, censor, and control us. They're partnering with known hate groups. These groups must be held accountable.
                                    </Text>
                                </VStack>

                                {/* Feature 2 */}
                                <VStack className="space-y-4 items-center text-center flex-1 min-w-64">
                                    <Box
                                        className="w-16 h-16 bg-secondary-50 rounded-full flex items-center justify-center">
                                        <Text className="text-success-600 text-2xl">⚒️</Text>
                                    </Box>
                                    <Text className="text-xl font-semibold text-typography-900">
                                        Tools for the People
                                    </Text>
                                    <Text className="text-typography-600 leading-relaxed">
                                      We are building modern, competitive tools that anyone can use to analyze and visualize data, spot patterns, and share insights. If companies like Palantir are allowed to help the government target us, we can make our own tools to fight back.
                                    </Text>
                                </VStack>

                                {/* Feature 3 */}
                                <VStack className="space-y-4 items-center text-center flex-1 min-w-64">
                                    <Box
                                        className="w-16 h-16 bg-secondary-50 rounded-full flex items-center justify-center">
                                        <Text className="text-secondary-600 text-2xl">🫂</Text>
                                    </Box>
                                    <Text className="text-xl font-semibold text-typography-900">
                                        Getting Involved
                                    </Text>
                                    <Text className="text-typography-600 leading-relaxed">
                                        Right now we are building the foundation of{' '}<Text className="font-bold font-mono">f2</Text>. The best way to get involved is to continue to gather data, share insights, and build community. We will ask for your gathered data when we are ready to start onboarding users.
                                    </Text>
                                </VStack>
                            </HStack>
                        </VStack>
                    </Box>

                    {/* Community */}
                    <Box className="py-16 px-6">
                        <VStack className="space-y-6 items-center max-w-3xl mx-auto">
                            <Text className="text-2xl font-semibold text-typography-900 text-center">
                                Join our community
                            </Text>

                            <Text className="text-lg text-center text-typography-600 leading-relaxed">
                              Get support, share ideas, and connect with others who care about protecting our communities from those who wish to do us harm.
                            </Text>

                            <HStack className="space-x-4 mt-4">
                                <Pressable
                                    onPress={() => {
                                        if (typeof window !== 'undefined') {
                                            window.open('https://threads.com/@f2dotpub', '_blank');
                                        }
                                    }}
                                >
                                    <Box className="bg-primary-600 hover:bg-primary-700 px-8 py-4 rounded-md">
                                        <Text className="text-white font-semibold">Follow Us</Text>
                                    </Box>
                                </Pressable>
                            </HStack>
                        </VStack>
                    </Box>

                    {/* Footer */}
                    <Box className="py-12 px-6 bg-primary-50">
                        <VStack className="space-y-6 items-center max-w-2xl mx-auto">
                            <Text className="text-lg text-typography-400 text-center">
                                Brought to you by
                            </Text>

                            <Text className="text-3xl font-bold font-mono">
                                f2
                            </Text>

                            <Text className="text-sm text-center text-typography-400 leading-relaxed">
                                Intelligence.{"\n"}By the people, for the people.
                            </Text>
                        </VStack>
                    </Box>
                </Box>
            </ScrollView>
        </Box>
    );
};
