---
draft: false
params:
  author: Sienna
  privacy: internal
title: Documentation
---

# Image Processing Pipeline

The image processing pipeline is fairly complex and requires crossing multiple service boundaries. Generically, we are extracting as much data as is possible from the image to ensure we are maximizing the opportunity for downstream correlation purposes. This workflow is designed to handle the complexity of image processing and ensure that the image is processed efficiently while making the system more robust. We can retry failures, get notifications of failures, and other monitoring features. This also lets us scale up each of the processing components independently.

```mermaid
flowchart TD
    A["User takes image"] --> B["Upload Image"]
    B --> C["Unprocessed Image Bucket"]
    B --> |"Upload Failed"| E1["Retry Upload"] --> |"Notify User"| A
    E1 --> |"Retry"| B
    
    C --> D["Image Processing Manager"]
    D --> |"Processing Failed"| E2["Mark as Failed<br>Retry Later"]
    E2 --> |"Retry"| D
    E2 --> |"Max retries exceeded"| F2["Log to Notifications Table<br>Move to Dead Letter Queue"]
    
    D --> G["Mark Image as Processing"]
    G --> H{{"Start Parallel Processing"}}
    
    %% Parallel Branch 1: EXIF
    H --> I1["Extract EXIF Data"]
    I1 --> |"Success"| J1["Store EXIF Data"]
    I1 --> |"Failed"| E3["Retry EXIF Extraction"]
    E3 --> |"Retry"| I1
    E3 --> |"Max retries"| K1["Log EXIF Failure<br>Continue workflow"]
    J1 --> L{{"Sync Point"}}
    K1 --> L
    
    %% Sequential Branch 2: Face Detection → Embeddings → Clustering
    H --> I2["Detect Faces"]
    I2 --> |"Success"| J2["Store Bounding Boxes"]
    I2 --> |"Failed"| E4["Retry Face Detection"]
    E4 --> |"Retry"| I2
    E4 --> |"Max retries"| F3["Mark Image as Failed<br>End workflow"]
    
    J2 --> I3["Generate Embeddings"]
    I3 --> |"Success"| J3["Store Embeddings"]
    I3 --> |"Failed"| E5["Retry Embedding Generation"]
    E5 --> |"Retry"| I3
    E5 --> |"Max retries"| F4["Mark Image as Failed<br>End workflow"]
    
    J3 --> I4["Matching/Clustering"]
    I4 --> |"Success"| J4["Store Clustering Results"]
    I4 --> |"Failed"| E6["Retry Clustering"]
    E6 --> |"Retry"| I4
    E6 --> |"Max retries"| F5["Store partial results<br>Mark as degraded"]
    
    J4 --> L
    F5 --> L
    
    L --> M["Mark Image as Processed"]
    M --> N["Move to Processed Image Bucket"]
    N --> O["Notify Completion"]
    
    %% Database with Tables
    subgraph DB ["Database"]
        direction TB
        NT["Notifications Table"]
        ET["EXIF Table"] 
        EM["Embeddings Table"]
        CT["Clustering Table"]
        BB["Bounding Boxes Table"]
    end
    
    %% Data flows to specific tables
    J1 -.-> ET
    J2 -.-> BB
    J3 -.-> EM
    J4 -.-> CT
    
    %% Error notifications
    F2 -.-> NT
    K1 -.-> NT
    F3 -.-> NT
    F4 -.-> NT
    F5 -.-> NT
    O -.-> NT
    
    %% Styling
    style A fill:#e1f5fe
    style C fill:#f3e5f5
    style D fill:#fff3e0
    style DB fill:#e8f5e8
    style H fill:#fff9c4
    style L fill:#fff9c4
    
    %% Error states
    style F2 fill:#ffebee
    style F3 fill:#ffebee
    style F4 fill:#ffebee
    style F5 fill:#fff8e1
    
    %% Table styling
    style NT fill:#fce4ec
    style ET fill:#e3f2fd
    style EM fill:#f3e5f5
    style CT fill:#fff3e0
    style BB fill:#e8f5e8
```
