// Table of contents sidebar component
import {TableOfContentsItem} from "@/components/docs/types";
import { Box } from "@/components/ui/box";
import { VStack } from "@/components/ui/vstack";
import {TouchableOpacity} from "react-native";
import {Icon} from "@/components/ui/icon";
import {Hash} from "lucide-react-native";
import {Text} from "@/components/ui/text";

export function TableOfContentsSidebar({
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