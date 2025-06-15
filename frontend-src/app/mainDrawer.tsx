import { router } from "expo-router";
import { Box } from "@/components/ui/box";
import { DrawerContentScrollView } from "@react-navigation/drawer";
import { VStack } from "@/components/ui/vstack";
import { Text } from "@/components/ui/text";
import { FileText, Home, LayoutDashboard, LogIn, Rss, User, UserPlus } from "lucide-react-native";
import { HStack } from "@/components/ui/hstack";
import { Pressable } from "@/components/ui/pressable";
import { DrawerSection } from "@/components/ui/drawer/drawerSection";
import { DrawerItem } from "@/components/ui/drawer/drawerItem";
import React from "react";

export function MainDrawer(props: any) {
    const currentRoute = props?.state?.routes?.[props?.state?.index]?.name || '';

    const handleNavigation = (routeName: string) => {
        router.push(routeName);
    };

    return (
        <Box className="flex-1 bg-white">
            <DrawerContentScrollView {...props} contentContainerStyle={{ paddingTop: 20 }}>
                <DrawerSection title="Main">
                    <DrawerItem
                        icon={Home}
                        label="Home"
                        onPress={() => handleNavigation('/')}
                        isActive={currentRoute === 'index'}
                    />
                    <DrawerItem
                        icon={FileText}
                        label="Documentation"
                        onPress={() => handleNavigation('/docs')}
                        isActive={currentRoute === 'docs/index'}
                    />
                </DrawerSection>

                {/* Rest of your drawer items... */}
            </DrawerContentScrollView>
        </Box>
    );
}