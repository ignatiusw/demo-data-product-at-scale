import os
import yaml
import pytest
from pathlib import Path
from collections import Counter

class TestDataProductUniqueness:
    """Test suite to ensure data product YAML files have unique names."""
    
    @pytest.fixture
    def data_products_path(self) -> Path:
        """Fixture to get the data-products directory path."""
        # Get the project root directory (assuming tests are in project/tests/)
        project_root = Path(__file__).parent.parent
        return project_root / "data-products"
    
    @pytest.fixture
    def yaml_files(self, data_products_path: Path) -> list[Path]:
        """Fixture to get all YAML files in the data-products directory."""
        if not data_products_path.exists():
            pytest.skip(f"Data products directory does not exist: {data_products_path}")
        
        yaml_extensions = ['.yaml', '.yml']
        yaml_files = []
        
        for ext in yaml_extensions:
            yaml_files.extend(data_products_path.glob(f"*{ext}"))
        
        if not yaml_files:
            pytest.skip(f"No YAML files found in {data_products_path}")
        
        return yaml_files
    
    @pytest.fixture
    def parsed_yaml_data(self, yaml_files: list[Path]) -> list[dict]:
        """Fixture to parse all YAML files and extract their data."""
        parsed_data = []
        
        for yaml_file in yaml_files:
            try:
                with open(yaml_file, 'r', encoding='utf-8') as f:
                    data = yaml.safe_load(f)
                    if data is not None:
                        parsed_data.append({
                            'file': yaml_file,
                            'data': data
                        })
            except yaml.YAMLError as e:
                pytest.fail(f"Failed to parse YAML file {yaml_file}: {e}")
            except Exception as e:
                pytest.fail(f"Error reading file {yaml_file}: {e}")
        
        return parsed_data
    
    def test_yaml_files_exist(self, data_products_path: Path) -> None:
        """Test that the data-products directory exists and contains YAML files."""
        assert data_products_path.exists(), f"Data products directory does not exist: {data_products_path}"
        
        yaml_files = list(data_products_path.glob("*.yaml")) + list(data_products_path.glob("*.yml"))
        assert len(yaml_files) > 0, f"No YAML files found in {data_products_path}"
    
    def test_yaml_files_have_name_field(self, parsed_yaml_data: list[dict]) -> None:
        """Test that all YAML files have a 'name' field."""
        for item in parsed_yaml_data:
            data = item['data']
            file_path = item['file']
            
            assert 'name' in data, f"YAML file {file_path} is missing the 'name' field"
            assert data['name'] is not None, f"YAML file {file_path} has a null 'name' field"
            assert isinstance(data['name'], str), f"YAML file {file_path} has a non-string 'name' field: {type(data['name'])}"
            assert data['name'].strip() != "", f"YAML file {file_path} has an empty 'name' field"

    def test_data_product_names_are_unique(self, parsed_yaml_data: list[dict]) -> None:
        """Test that all data product names are unique across all YAML files."""
        names = []
        name_to_files = {}
        
        for item in parsed_yaml_data:
            data = item['data']
            file_path = item['file']
            name = data.get('name')
            
            if name:
                names.append(name)
                if name not in name_to_files:
                    name_to_files[name] = []
                name_to_files[name].append(str(file_path))
        
        # Count occurrences of each name
        name_counts = Counter(names)
        duplicates = {name: count for name, count in name_counts.items() if count > 1}
        
        if duplicates:
            error_message = "Duplicate data product names found:\n"
            for name, count in duplicates.items():
                files_with_name = name_to_files[name]
                error_message += f"  - '{name}' appears {count} times in files: {', '.join(files_with_name)}\n"
            
            pytest.fail(error_message)
        
        # Additional assertion for clarity
        assert len(names) == len(set(names)), f"Expected all names to be unique. Found {len(names)} names with {len(set(names))} unique values."

    def test_data_product_names_case_sensitivity(self, parsed_yaml_data: list[dict]) -> None:
        """Test that data product names are unique even when considering case sensitivity."""
        names = []
        name_to_files = {}
        
        for item in parsed_yaml_data:
            data = item['data']
            file_path = item['file']
            name = data.get('name')
            
            if name:
                name_lower = name.lower()
                names.append(name_lower)
                if name_lower not in name_to_files:
                    name_to_files[name_lower] = []
                name_to_files[name_lower].append({
                    'original_name': name,
                    'file': str(file_path)
                })
        
        # Count occurrences of each lowercase name
        name_counts = Counter(names)
        duplicates = {name: count for name, count in name_counts.items() if count > 1}
        
        if duplicates:
            error_message = "Duplicate data product names found (case-insensitive):\n"
            for name_lower, count in duplicates.items():
                files_with_name = name_to_files[name_lower]
                error_message += f"  - Names that resolve to '{name_lower}' appear {count} times:\n"
                for file_info in files_with_name:
                    error_message += f"    * '{file_info['original_name']}' in {file_info['file']}\n"
            
            pytest.fail(error_message)