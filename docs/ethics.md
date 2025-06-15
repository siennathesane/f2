---
draft: false
params:
  author: Sienna
  privacy: public
title: Ethics Guide
---

# Ethics Guide

This guide is not a comprehensive list of all ethical considerations but rather a starting point for understanding the ethical implications of the system we are building.

## What is f2?

f2 is a weapon.

To say otherwise would be to deny the reality of what this system will be capable of doing. To be able to extract, identify, and correlate data from images, search engines, and social media platforms, we must acknowledge how dangerous this can be for individuals. We must also consider the potential for misuse and abuse of this technology, including the possibility of it being used for surveillance, propaganda, or other nefarious purposes.

To mitigate these risks, we must establish clear guidelines and regulations for the use of f2. These guidelines should include provisions for transparency, accountability, and oversight. We must also ensure that the technology is developed and deployed in a responsible and ethical manner, taking into account the potential impact on individuals and society as a whole.

The power to correlate disparate data sources creates capabilities that can fundamentally alter privacy expectations and social dynamics. We are building infrastructure that could be repurposed for authoritarian surveillance, corporate manipulation, or social engineering at scale. This responsibility cannot be delegated or ignored.

## Safety

### Data Storage and Presentation Separation

f2 maintains a strict separation between data storage and data presentation:

- **Comprehensive Storage**: We store data comprehensively to enable legitimate research and analysis
- **Controlled Presentation**: Data is never presented to users in aggregated or individually identifiable forms
- **Access Barriers**: Technical and policy barriers prevent correlation of stored data back to individuals
- **Presentation Filtering**: All user-facing outputs are filtered to remove personally identifiable information

For example, f2 might store a user's location data but will never present it in a way that could identify them. Similarly, we may encounter address data but will never present it to other users in identifiable form.

### Individual Protection Measures

f2 will never:
- Create commercial services that allow tracking of individuals across time
- Provide personally identifiable information to public interfaces
- Enable retroactive identification of anonymized data
- Provide mechanisms to link stored data back to user identities
- Allow bulk data export that could enable de-anonymization through correlation

### Algorithmic Safety

- **Bias Auditing**: Regular testing for discriminatory outcomes across protected classes
- **Output Filtering**: Automated detection and blocking of outputs that could enable harassment or doxxing
- **Rate Limiting**: Aggressive throttling to prevent systematic abuse or scraping
- **Correlation Limits**: Technical restrictions on the depth and breadth of data correlation possible in a single query

**Correlation Limits Example**: A user could query "how many registered sex offenders live within a 5-mile radius of elementary schools in Austin, TX" and receive aggregate statistics. However, they could not query "show me the names and addresses of sex offenders with child pornography convictions near Jefferson Elementary" - the system would block queries that enable individual location identification or targeting. Names and faces may be available, but not addresses or other location-enabling information.

### Community Safety

- **Harm Reduction**: Active monitoring for use patterns that indicate potential harm to individuals or communities
- **Early Warning Systems**: Automated detection of queries that suggest illegal activity, harassment campaigns, or stalking behavior (aspirational - we are actively working on implementation but cannot guarantee this capability yet)
- **Community Reporting**: Clear channels for reporting misuse with rapid response protocols

## Privacy

### Data Collection and Use Framework

We collect comprehensive data while maintaining strict controls on access and presentation:

- **Purpose Limitation**: Data is used only for legitimate research, analysis, and community protection purposes
- **Presentation Controls**: Raw data is never directly accessible to users - only processed, anonymized outputs
- **Access Restrictions**: No individual user can access another user's raw data or identifying information
- **Processing Boundaries**: Data processing is restricted to prevent individual identification or targeting

### Individual Data Rights

Users maintain control over their relationship with f2:

- **Query Unlinking**: Users can request that their queries be unlinked from their profile (data remains in system for legitimate research)
- **Data Portability**: Users can export all data associated with their usage patterns
- **Correction Rights**: Users can request correction of processed data (implementation at scale to be determined)
- **Processing Transparency**: Users receive detailed information about how their data is processed

### Corporate and Institutional Access

f2 operates under strict access controls:

- **No Corporate Access**: Corporations, governments, or institutions cannot access individual-level data
- **Academic Exceptions**: Academic research access on case-by-case basis with ethics review
- **No Bulk Sales**: Data is never aggregated, packaged, or sold to third parties
- **No Third-Party Processing**: Data is never processed by external third parties
- **No Advertising Model**: Revenue models that incentivize surveillance or data harvesting are explicitly prohibited
- **Limited Legal Cooperation**: Data sharing with law enforcement limited to civil rights cases with full disclosure and legal review

### Technical Privacy Measures

- **End-to-End Encryption**: All data transmission uses current cryptographic standards
- **Modular Architecture**: Each system component operates independently to limit data exposure
- **Server-Side Processing**: Processing occurs server-side for performance while maintaining access controls
- **Output Sanitization**: All outputs are processed to remove identifying information before presentation

## Security

### Infrastructure Security

Our security model assumes hostile actors will attempt to compromise f2:

- **Outbound-Only Connections**: f2 infrastructure makes only outbound connections - no inbound data connections from external networks
- **Transport Security**: All connections use TLS 1.3 with certificate pinning and HSTS
- **Service Mesh Security**: Linkerd provides encrypted, authenticated service-to-service communication
- **Disk Encryption**: Longhorn storage uses encryption at rest with HSM key management where available

### Data Protection

- **Encryption Layers**: Data is encrypted in transit, at rest, and during processing where possible
- **Key Management**: Cryptographic keys are rotated regularly
- **Access Control**: Multi-factor authentication and principle of least privilege for all system access
- **Audit Logging**: Comprehensive logging of all data access

### Operational Security

- **Regular Backups**: Encrypted backups are taken and tested regularly
- **Incident Response**: Documented procedures for security breaches with user notification requirements
- **Penetration Testing**: Regular external security audits when resources permit
- **Supply Chain Security**: Verification of dependencies, acknowledging inevitable supply chain risks

### Threat Modeling

We model realistic threats within our resource constraints:

- **Resource-Constrained Defense**: Assuming sophisticated adversaries with significantly more resources than f2
- **Corporate Espionage**: Basic protection against attempts to extract data (implementation approaches TBD)
- **Social Engineering**: Training and procedures to prevent human-based attacks
- **Physical Security**: Protection of infrastructure and personnel within hosting constraints

## Transparency

### Data Collection Transparency

We maintain complete transparency about data practices:

- **Collection Notice**: We collect comprehensive data similar to governments and corporations, but centralize it while being completely transparent about our practices
- **Processing Explanation**: Detailed technical explanations of how data is processed and analyzed will be available
- **No Third-Party Access**: Explicit guarantee that no third-party services have access to stored data
- **Algorithm Transparency**: Open explanations of algorithmic decision-making processes where possible

### Operational Transparency

- **Open Source Commitment**: Core f2 components are open source where possible (full transparency not always feasible, but committed to sharing maximum possible)
- **No Commercial Software**: Commitment to using only open source software stack with exceptions for essential operational services (Expo, Cloudflare, Stripe, etc.)
- **Security Reporting**: Regular public security reports and incident disclosures
- **Financial Transparency**: Clear information about funding sources and revenue models
- **Decision Making**: Public documentation of major policy and technical decisions

### Limitation Disclosure

We clearly communicate what f2 cannot and will not do:

- **Technical Limitations**: Honest assessment of system capabilities and accuracy
- **Policy Limitations**: Clear boundaries on permitted uses and enforcement mechanisms
- **Legal Limitations**: Explicit statement of legal constraints and jurisdiction issues
- **Ethical Boundaries**: Public commitment to ethical principles that constrain system design

### Regular Reporting

- **Quarterly Reports**: Regular public reports on system usage, security incidents, and policy enforcement
- **Compliance Audits**: Third-party audits of data practices and security measures when resources permit
- **Community Updates**: Regular communication with users about system changes and improvements
- **Research Publication**: Sharing relevant research findings that improve privacy and security

## Accountability

### Community Accountability

f2 is accountable to its user community first and foremost:

- **User Advisory Board**: Community representatives involved in major policy decisions
- **Public Complaint Process**: Clear, accessible process for reporting concerns or violations
- **Response Commitments**: Defined timelines for responding to user concerns and complaints
- **Appeal Processes**: Fair, transparent processes for appealing content or account decisions

### Technical Accountability

- **Code Review**: All code changes undergo peer review with security and privacy considerations
- **Automated Testing**: Comprehensive testing including privacy and security regression tests
- **Monitoring Systems**: Real-time monitoring for policy violations and system abuse
- **Performance Metrics**: Public metrics on system reliability, accuracy, and response times

### Legal Accountability

- **Jurisdiction Selection**: Operating under privacy-protective legal frameworks
- **Compliance Frameworks**: Adherence to strongest applicable privacy regulations (GDPR, CCPA, etc.)
- **Legal Standing**: Clear legal entity responsible for f2 operations and user protection
- **Liability Framework**: Clear allocation of responsibility for system failures or misuse

### Governance Structure

- **Ethics Board**: Independent board with authority to override technical and business decisions (compensated but without significant financial incentives that could compromise independence)
- **Regular Review**: Systematic review of all policies and practices on defined schedules
- **Stakeholder Input**: Structured processes for incorporating feedback from affected communities
- **Constitutional Framework**: Core principles that cannot be changed without community consensus

### Enforcement Mechanisms

- **Automated Enforcement**: Technical systems that automatically enforce policy boundaries
- **Human Review**: Human oversight for complex cases and edge situations
- **Escalation Procedures**: Clear escalation paths for serious violations or disputes
- **Sanctions Framework**: Proportionate responses to policy violations including account suspension

## Implementation Commitments

### Development Practices

- **Privacy by Design**: Privacy considerations integrated into every technical decision
- **Security First**: Security requirements take precedence over feature development speed
- **Iterative Improvement**: Regular review and improvement of ethical practices
- **Community Involvement**: User community involvement in major system changes

### Resource Allocation

- **Security Investment**: "Secure by default and defense in depth" approach integrated into all development and operational decisions
- **Ethics Personnel**: Dedicated staff for ethics review and policy enforcement
- **Community Support**: Resources allocated to community management and user support
- **Legal Protection**: Resources reserved for defending user privacy and platform integrity

### Long-Term Sustainability

- **Mission Protection**: Governance structures that prevent mission drift or capture
- **Financial Independence**: Revenue models that don't compromise user privacy or safety
- **Technical Sovereignty**: Avoiding dependencies that could compromise user protection
- **Community Ownership**: Pathways toward community ownership and governance

---

*This ethics guide is a living document that will evolve as f2 develops and as we learn from our community and the broader ecosystem. Our commitment is to err on the side of caution and user protection in all decisions, while being honest about the capabilities we're building and the responsibilities that come with them.*
