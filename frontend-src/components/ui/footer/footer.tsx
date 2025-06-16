// File: pageFooter.tsx
import React from 'react';
import { Box } from '@/components/ui/box';
import { Text } from '@/components/ui/text';
import { BUILD_INFO } from '@/constants/buildInfo';

interface PageFooterProps {
    className?: string;
}

const PageFooter = React.forwardRef<React.ElementRef<typeof Box>, PageFooterProps>(
    ({ className, ...props }, ref) => {
        return (
            <Box
                ref={ref}
                className={`mt-8 pt-4 border-t border-border-300 ${className || ''}`}
                {...props}
            >
                <Text size="xs" className="text-typography-400 text-center font-mono">
                    Build: {BUILD_INFO.buildId}
                </Text>
            </Box>
        );
    }
);

PageFooter.displayName = 'PageFooter';

export { PageFooter };