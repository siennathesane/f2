import {VStack} from "@/components/ui/vstack";
import {Text} from "@/components/ui/text";

export const DrawerSection = ({title, children}) => {
    return (
        <VStack className="space-y-1 mb-6">
            <Text className="text-xs font-semibold text-gray-400 uppercase tracking-wider px-4 mb-2">
                {title}
            </Text>
            {children}
        </VStack>
    );
};
