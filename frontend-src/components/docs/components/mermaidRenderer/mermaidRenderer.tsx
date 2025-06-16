// Simple image-only version
import {Box} from "@/components/ui/box";
import {VStack} from "@/components/ui/vstack";
import {Linking, Platform} from "react-native";
import {Button, ButtonText} from "@/components/ui/button";
import {Text} from "@/components/ui/text";
import {MermaidRendererProps} from "@/components/docs/types";
import {useState} from "react";
import {HStack} from "@/components/ui/hstack";

// proper base64 encoding for mermaid.ink
function encodeForMermaidInk(content: string): string {
    try {
        // Clean the content
        const cleanContent = content.trim();

        // Convert to UTF-8 bytes then to base64
        const utf8Bytes = new TextEncoder().encode(cleanContent);
        let binary = '';
        for (let i = 0; i < utf8Bytes.length; i++) {
            binary += String.fromCharCode(utf8Bytes[i]);
        }
        return btoa(binary);
    } catch (error) {
        console.warn('Failed to encode for mermaid.ink:', error);
        // Fallback: simple base64 of a basic diagram
        return btoa('graph TD\n    A[Error] --> B[Encoding Failed]');
    }
}

export function MermaidRenderer({ chart, theme = 'default' }: MermaidRendererProps) {
    const [imageError, setImageError] = useState(false);
    const [loading, setLoading] = useState(true);

    // Encode for mermaid.ink service
    const encodedChart = encodeForMermaidInk(chart);

    // Correct mermaid.ink URL format
    const imageUrl = `https://mermaid.ink/img/${encodedChart}`;

    // For web, use the image approach
    if (Platform.OS === 'web') {
        if (imageError) {
            return (
                <VStack className="bg-background-secondary border border-border-secondary rounded-lg p-4 my-4 space-y-3">
                    <Text className="text-text-secondary text-sm font-medium">
                        Diagram Unavailable
                    </Text>
                    <Text className="text-text-tertiary text-xs">
                        Unable to render the diagram. You can view it in Mermaid Live Editor.
                    </Text>
                    <HStack className="space-x-2">
                        <Button
                            size="sm"
                            variant="outline"
                            onPress={() => {
                                setImageError(false);
                                setLoading(true);
                            }}
                        >
                            <ButtonText>Retry</ButtonText>
                        </Button>
                        <Button
                            size="sm"
                            variant="outline"
                            onPress={() => {
                                // Use direct chart content for Mermaid Live
                                const mermaidLiveUrl = `https://mermaid.live/edit#base64:${encodedChart}`;
                                window.open(mermaidLiveUrl, '_blank');
                            }}
                        >
                            <ButtonText>Open in Editor</ButtonText>
                        </Button>
                    </HStack>
                </VStack>
            );
        }

        return (
            <Box className="my-4 border border-border-primary rounded-lg overflow-hidden bg-background-primary">
                {loading && (
                    <Box className="p-8 items-center">
                        <Text className="text-text-tertiary text-sm">Loading diagram...</Text>
                    </Box>
                )}
                <img
                    src={imageUrl}
                    alt="Mermaid Diagram"
                    style={{
                        width: '100%',
                        height: 'auto',
                        display: loading ? 'none' : 'block'
                    }}
                    onError={() => {
                        console.error('Mermaid.ink failed to render:', imageUrl);
                        setImageError(true);
                        setLoading(false);
                    }}
                    onLoad={() => {
                        setLoading(false);
                    }}
                />
            </Box>
        );
    }

    // For mobile, show a nice placeholder
    return (
        <VStack className="bg-background-secondary border border-border-secondary rounded-lg p-6 my-4 space-y-4 items-center">
            <VStack className="space-y-2 items-center">
                <Text className="text-text-primary text-lg">📊</Text>
                <Text className="text-text-primary text-sm font-medium text-center">
                    Interactive Diagram
                </Text>
                <Text className="text-text-tertiary text-xs text-center">
                    Tap to view this diagram in your browser
                </Text>
            </VStack>

            <Button
                size="sm"
                onPress={() => {
                    const mermaidLiveUrl = `https://mermaid.live/edit#base64:${encodedChart}`;
                    Linking.openURL(mermaidLiveUrl);
                }}
            >
                <ButtonText>View Diagram</ButtonText>
            </Button>
        </VStack>
    );
}
