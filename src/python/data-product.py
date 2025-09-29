import os
import re
import sys
import yaml
import json
import shutil
import logging
import argparse
from jinja2 import Environment, FileSystemLoader

# Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger(__name__)

# Paths
TEMPLATE_FOLDER = "./src/terraform/template"
OUTPUT_FOLDER = "./src/terraform/output"

def setup_logging(debug: bool) -> None:
    """Configure logging level and format."""
    level = logging.DEBUG if debug else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(asctime)s [%(levelname)s] %(message)s",
        handlers=[logging.StreamHandler(sys.stdout)]
    )

def load_yaml(file_path: str) -> dict:
    """Load YAML file and return its content as a dictionary."""
    try:
        with open(file_path, 'r') as f:
            data = yaml.safe_load(f)
        logger.debug(f"Loaded YAML file: {file_path}")
        return data
    except Exception as e:
        logger.error(f"Error loading YAML file '{file_path}': {e}")
        raise

def standardise_data_product_name(name: str, replacement: str = '-') -> str:
    """Standardise data product name to lowercase and replace non-alphanumeric characters with hyphens."""
    return re.sub(r'[^a-zA-Z0-9]', replacement, name.lower()) if name else "demo-data-product"

def map_context(environment: str, context: dict) -> dict:
    """Map YAML context to template context. Note that compute has not been implemented yet."""
    mapped = {
        "environment": environment.lower(),
        "data_product_name": context.get("name", "demo-data-product"),
        "data_product_description": context.get("description", "A demo data product for showcasing data product at scale"),
        "data_product_tags": {
            "classification": context.get("classification", "Internal"),
            "division": context.get("owner").get("division", "Data & Analytics"),
            "business unit": context.get("owner").get("business unit", "Data Platforms & Engineering"),
            "contacts": json.dumps(context.get("owner").get("contacts", [])) # Flatten list to string
        },
        "read_only_members": context.get("users", {}).get("read-only", []),
        "modify_members": context.get("users", {}).get("modify", []),
        "data_product_name_standardised": standardise_data_product_name(context.get("name", "demo-data-product"))
    }
    return mapped

def render_templates(yaml_file: str, context: dict) -> None:
    """Render Jinja2 template with the given context and save to output path."""
    base_name = os.path.splitext(os.path.basename(yaml_file))[0]
    out_dir = os.path.join(OUTPUT_FOLDER, base_name)

    # Clean output directory if exists
    if os.path.exists(out_dir):
        shutil.rmtree(out_dir)
        logger.debug(f"Removed existing output directory: {out_dir}")
    os.makedirs(out_dir, exist_ok=True)
    logger.info(f"Rendering templates for {yaml_file} -> {out_dir}")

    # Setup Jinja2 environment
    env = Environment(loader=FileSystemLoader(TEMPLATE_FOLDER), keep_trailing_newline=True)

    for root, _, files in os.walk(TEMPLATE_FOLDER):
        rel_path = os.path.relpath(root, TEMPLATE_FOLDER)
        target_dir = os.path.join(out_dir, rel_path)
        os.makedirs(target_dir, exist_ok=True)

        for file in files:
            src_path = os.path.join(root, file)

            if file.endswith(".jinja"):
                try:
                    template = env.get_template(os.path.relpath(src_path, TEMPLATE_FOLDER))
                    rendered = template.render(context)

                    out_file = os.path.join(target_dir, file[:-6])  # strip .jinja
                    with open(out_file, "w") as f:
                        f.write(rendered)
                        logger.info(f"Rendered template: {src_path} -> {out_file}")
                except Exception as e:
                    logger.error(f"Error rendering template {src_path}: {e}")
                    raise
            else:
                shutil.copy2(src_path, os.path.join(target_dir, file))
                logger.debug(f"Copied file: {src_path} -> {target_dir}")

def main(environment: str, input_path: str) -> None:
    """Process a single YAML file or all YAML files in a folder."""
    os.makedirs(OUTPUT_FOLDER, exist_ok=True)

    if os.path.isfile(input_path):
        if input_path.endswith((".yaml", ".yml")):
            context = map_context(environment, load_yaml(input_path))
            render_templates(input_path, context)
        else:
            print(f"Skipping non-YAML file: {input_path}")
    elif os.path.isdir(input_path):
        yaml_files = [f for f in os.listdir(input_path) if f.endswith((".yaml", ".yml"))]
        if not yaml_files:
            logger.warning(f"No YAML files found in {input_path}")
        for file in yaml_files:
            yaml_path = os.path.join(input_path, file)
            context = map_context(environment, load_yaml(yaml_path))
            render_templates(yaml_path, context)
    else:
        logger.error(f"Path not found: {input_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Render Terraform templates from data product YAML config files.")
    parser.add_argument("environment", help="Environment name (must be one of: ['dev', 'test', 'prod'])")
    parser.add_argument("input", help="data product YAML config file or folder containing data product YAML config files")
    parser.add_argument("--debug", action="store_true", help="Enable debug logging")
    args = parser.parse_args()

    setup_logging(args.debug)
    main(args.environment, args.input)