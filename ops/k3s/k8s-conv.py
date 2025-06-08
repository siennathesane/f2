#!/usr/bin/env python3

import argparse
import yaml
import subprocess
import sys
import tempfile
import os
from pathlib import Path

# Standard Kubernetes API groups/versions
STANDARD_API_GROUPS = {
    'v1', 'apps/v1', 'batch/v1', 'batch/v1beta1',
    'networking.k8s.io/v1', 'networking.k8s.io/v1beta1',
    'rbac.authorization.k8s.io/v1', 'rbac.authorization.k8s.io/v1beta1',
    'storage.k8s.io/v1', 'storage.k8s.io/v1beta1',
    'policy/v1', 'policy/v1beta1',
    'autoscaling/v1', 'autoscaling/v2', 'autoscaling/v2beta1', 'autoscaling/v2beta2',
    'coordination.k8s.io/v1', 'coordination.k8s.io/v1beta1',
    'discovery.k8s.io/v1', 'discovery.k8s.io/v1beta1',
    'events.k8s.io/v1', 'events.k8s.io/v1beta1',
    'extensions/v1beta1',
    'flowcontrol.apiserver.k8s.io/v1beta1', 'flowcontrol.apiserver.k8s.io/v1beta2',
    'node.k8s.io/v1', 'node.k8s.io/v1beta1',
    'scheduling.k8s.io/v1', 'scheduling.k8s.io/v1beta1',
    'authentication.k8s.io/v1', 'authentication.k8s.io/v1beta1',
    'authorization.k8s.io/v1', 'authorization.k8s.io/v1beta1',
    'certificates.k8s.io/v1', 'certificates.k8s.io/v1beta1',
    # this is due to sl1pm4t/k2tf#134
    # 'admissionregistration.k8s.io/v1', 'admissionregistration.k8s.io/v1beta1',
}

def is_custom_resource(api_version, kind):
    """Determine if a resource is a CRD or custom resource."""
    # CRDs are always custom
    if api_version.startswith('apiextensions.k8s.io/') and kind == 'CustomResourceDefinition':
        return True

    # Check if API version is in standard groups
    if api_version in STANDARD_API_GROUPS:
        return False

    # If it has a domain (contains /) and it's not in standard groups, it's likely custom
    if '/' in api_version:
        return True

    # Core resources (no /) that aren't v1 are likely custom
    if api_version != 'v1':
        return True

    if kind == 'Pod':
        return False

    return False

def convert_with_tfk8s(doc):
    """Convert YAML to HCL using tfk8s for custom resources."""
    try:
        # Write to temp file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
            yaml.dump(doc, f, default_flow_style=False)
            temp_yaml = f.name

        # Run tfk8s
        result = subprocess.run(
            ['tfk8s', '--file', temp_yaml],
            capture_output=True,
            text=True,
            check=True
        )

        return result.stdout

    except subprocess.CalledProcessError as e:
        print(f"Error running tfk8s: {e.stderr}", file=sys.stderr)
        return None
    except FileNotFoundError:
        print("Error: tfk8s not found. Please ensure it's installed and in PATH.", file=sys.stderr)
        return None
    finally:
        # Clean up temp file
        if 'temp_yaml' in locals():
            try:
                os.unlink(temp_yaml)
            except:
                pass

def convert_with_k2tf(doc):
    """Convert YAML to HCL using k2tf for standard Kubernetes resources."""
    try:
        # Write to temp file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.yaml', delete=False) as f:
            yaml.dump(doc, f, default_flow_style=False)
            temp_yaml = f.name

        # Run k2tf
        result = subprocess.run(
            ['k2tf', '-f', temp_yaml],
            capture_output=True,
            text=True,
            check=True
        )

        return result.stdout

    except subprocess.CalledProcessError as e:
        print(f"Error running k2tf: {e.stderr}", file=sys.stderr)
        return None
    except FileNotFoundError:
        print("Error: k2tf not found. Please ensure it's installed and in PATH.", file=sys.stderr)
        return None
    finally:
        # Clean up temp file
        if 'temp_yaml' in locals():
            try:
                os.unlink(temp_yaml)
            except:
                pass

def process_manifest(input_file, output_file):
    """Process the Kubernetes manifest and convert to HCL."""
    # Read and parse YAML documents
    try:
        with open(input_file, 'r') as f:
            documents = list(yaml.safe_load_all(f))
    except yaml.YAMLError as e:
        print(f"Error parsing YAML: {e}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"Error reading input file: {e}", file=sys.stderr)
        return 1

    # Filter out None/empty documents
    documents = [doc for doc in documents if doc]

    if not documents:
        print("No valid Kubernetes documents found in input file.", file=sys.stderr)
        return 1

    print(f"Found {len(documents)} Kubernetes document(s)")

    # Process each document
    hcl_outputs = []
    for i, doc in enumerate(documents):
        # Validate document has required fields
        if not isinstance(doc, dict):
            print(f"Document {i+1} is not a valid Kubernetes resource (not a dict)", file=sys.stderr)
            continue

        api_version = doc.get('apiVersion')
        kind = doc.get('kind')

        if not api_version or not kind:
            print(f"Document {i+1} missing apiVersion or kind", file=sys.stderr)
            continue

        # Get metadata for better logging
        metadata = doc.get('metadata', {})
        name = metadata.get('name', 'unnamed')
        namespace = metadata.get('namespace', 'default')

        print(f"\nProcessing document {i+1}: {kind}/{name} in {namespace} ({api_version})")

        if is_custom_resource(api_version, kind):
            print(f"  -> Using tfk8s (custom resource)")
            hcl = convert_with_tfk8s(doc)
        else:
            print(f"  -> Using k2tf (standard resource)")
            hcl = convert_with_k2tf(doc)

        if hcl:
            hcl_outputs.append(hcl)
            print(f"  -> Successfully converted")
        else:
            print(f"  -> Failed to convert document {i+1}", file=sys.stderr)

    if not hcl_outputs:
        print("No documents were successfully converted.", file=sys.stderr)
        return 1

    # Write all HCL outputs to single file
    try:
        with open(output_file, 'w') as f:
            # Add header comment
            f.write("# Generated from Kubernetes manifests\n")
            f.write("# Custom resources use kubernetes_manifest resource type\n")
            f.write("# Standard resources use their respective kubernetes provider types\n\n")

            # Join all HCL outputs with newlines
            f.write('\n\n'.join(hcl_outputs))
            f.write('\n')

        print(f"\nSuccessfully wrote HCL to {output_file}")
        return 0

    except Exception as e:
        print(f"Error writing output file: {e}", file=sys.stderr)
        return 1

def main():
    parser = argparse.ArgumentParser(
        description='Convert Kubernetes manifests to Terraform HCL format',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
This script converts Kubernetes YAML manifests to HashiCorp Configuration Language (HCL).

For custom resource definitions and custom resources, it uses tfk8s to generate
kubernetes_manifest resource types.

For standard Kubernetes resources, it uses k2tf to generate the appropriate
typed resources from the Kubernetes provider.

Requirements:
  - PyYAML (install with: pip install pyyaml)
  - tfk8s must be installed and available in PATH
  - k2tf must be installed and available in PATH

Example:
  %(prog)s deployment.yaml -o deployment.tf
  %(prog)s manifests/*.yaml -o kubernetes.tf
        """
    )

    parser.add_argument('input', help='Input Kubernetes manifest YAML file')
    parser.add_argument('-o', '--output', default='main.tf',
                        help='Output HCL file (default: main.tf)')

    args = parser.parse_args()

    # Check if input file exists
    if not Path(args.input).exists():
        print(f"Error: Input file '{args.input}' not found.", file=sys.stderr)
        return 1

    # Process the manifest
    return process_manifest(args.input, args.output)

if __name__ == '__main__':
    sys.exit(main())
