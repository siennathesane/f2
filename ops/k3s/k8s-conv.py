#!/usr/bin/env python3

import argparse
import yaml
import subprocess
import sys
import tempfile
import os
import re
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

def sanitize_filename(name):
    """Convert a Kubernetes name to a valid filename."""
    # Replace non-alphanumeric characters with underscores
    name = re.sub(r'[^a-zA-Z0-9_-]', '_', name)
    # Remove consecutive underscores
    name = re.sub(r'_+', '_', name)
    # Remove leading/trailing underscores
    name = name.strip('_')
    return name.lower()

def generate_filename(doc, output_dir, index):
    """Generate a unique filename for a Kubernetes resource."""
    kind = doc.get('kind', 'unknown').lower()
    metadata = doc.get('metadata', {})
    name = metadata.get('name', f'unnamed_{index}')

    # Sanitize names
    kind_safe = sanitize_filename(kind)

    # Build filename components
    components = [kind_safe]

    # Create base filename
    base_name = '_'.join(components)

    # Ensure uniqueness
    output_path = output_dir / f"{base_name}.tf"
    counter = 1
    while output_path.exists():
        output_path = output_dir / f"{base_name}_{counter}.tf"
        counter += 1

    return output_path

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


def process_manifest(input_file, output_dir):
    """Process the Kubernetes manifest and convert to HCL."""
    # Ensure output directory exists
    output_dir.mkdir(parents=True, exist_ok=True)

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
    print(f"Output directory: {output_dir}")

    # Track results
    successful = 0
    failed = 0

    # Process each document
    for i, doc in enumerate(documents):
        # Validate document has required fields
        if not isinstance(doc, dict):
            print(f"Document {i+1} is not a valid Kubernetes resource (not a dict)", file=sys.stderr)
            failed += 1
            continue

        api_version = doc.get('apiVersion')
        kind = doc.get('kind')

        if not api_version or not kind:
            print(f"Document {i+1} missing apiVersion or kind", file=sys.stderr)
            failed += 1
            continue

        # Get metadata for better logging
        metadata = doc.get('metadata', {})
        name = metadata.get('name', 'unnamed')
        namespace = metadata.get('namespace', 'default')

        print(f"\nProcessing document {i+1}: {kind}/{name} in {namespace} ({api_version})")

        # Generate output filename
        output_file = generate_filename(doc, output_dir, i+1)
        print(f"  -> Output file: {output_file.name}")

        # Convert based on resource type
        if is_custom_resource(api_version, kind):
            print(f"  -> Using tfk8s (custom resource)")
            hcl = convert_with_tfk8s(doc)
        else:
            print(f"  -> Using k2tf (standard resource)")
            hcl = convert_with_k2tf(doc)

        if hcl:
            # Write HCL to individual file
            try:
                with open(output_file, 'w') as f:
                    # Add header comment
                    f.write(f"# Generated from Kubernetes {kind}: {name}\n")
                    if namespace and namespace != 'default':
                        f.write(f"# Namespace: {namespace}\n")
                    f.write(f"# API Version: {api_version}\n")
                    if is_custom_resource(api_version, kind):
                        f.write("# Type: Custom Resource (kubernetes_manifest)\n")
                    else:
                        f.write("# Type: Standard Resource\n")
                    f.write("\n")
                    f.write(hcl)
                    if not hcl.endswith('\n'):
                        f.write('\n')

                print(f"  -> Successfully converted and saved")
                successful += 1

            except Exception as e:
                print(f"  -> Error writing file: {e}", file=sys.stderr)
                failed += 1
        else:
            print(f"  -> Failed to convert document {i+1}", file=sys.stderr)
            failed += 1

    # Summary
    print(f"\nConversion complete:")
    print(f"  Successful: {successful}")
    print(f"  Failed: {failed}")
    print(f"  Output directory: {output_dir}")

    return 0 if successful > 0 else 1

def main():
    parser = argparse.ArgumentParser(
        description='Convert Kubernetes manifests to Terraform HCL format',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
This script converts Kubernetes YAML manifests to HashiCorp Configuration Language (HCL).
Each Kubernetes resource is output to its own .tf file.

For custom resource definitions and custom resources, it uses tfk8s to generate
kubernetes_manifest resource types.

For standard Kubernetes resources, it uses k2tf to generate the appropriate
typed resources from the Kubernetes provider.

Output files are named using the pattern:
  <kind>_<namespace>_<name>.tf  (for namespaced resources)
  <kind>_<name>.tf              (for cluster-wide resources)

Requirements:
  - PyYAML (install with: pip install pyyaml)
  - tfk8s must be installed and available in PATH
  - k2tf must be installed and available in PATH

Example:
  %(prog)s deployment.yaml
  %(prog)s manifests.yaml -o terraform/kubernetes/
        """
    )

    parser.add_argument('input', help='Input Kubernetes manifest YAML file')
    parser.add_argument('-o', '--output-dir', default='terraform',
                        help='Output directory for HCL files (default: terraform)')

    args = parser.parse_args()

    # Check if input file exists
    input_path = Path(args.input)
    if not input_path.exists():
        print(f"Error: Input file '{args.input}' not found.", file=sys.stderr)
        return 1

    # Convert output dir to Path
    output_dir = Path(args.output_dir)

    # Process the manifest
    return process_manifest(input_path, output_dir)

if __name__ == '__main__':
    sys.exit(main())
