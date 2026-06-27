-- Step 0: If you ran terraform apply before, destroy them using terraform
/*
terraform -chdir=./src/terraform/output/death-star plan -destroy -var-file=./data-product.tfvars
terraform -chdir=./src/terraform/output/death-star destroy -var-file=./data-product.tfvars -auto-approve

terraform -chdir=./src/terraform/output/starkiller-base plan -destroy -var-file=./data-product.tfvars
terraform -chdir=./src/terraform/output/starkiller-base destroy -var-file=./data-product.tfvars -auto-approve
*/

-- Step 1: drop the catalogs
DROP CATALOG IF EXISTS `death_star_dev` CASCADE;
DROP CATALOG IF EXISTS `starkiller_base_dev` CASCADE;

-- Step 2: re-create the catalog as free edition doesn't allow the creation of catalogs via terraform
CREATE CATALOG IF NOT EXISTS `death_star_dev`;
CREATE CATALOG IF NOT EXISTS `starkiller_base_dev`;

-- Step 3: drop the group, user, and service principal (in settings, can't do via SQL or notebook, need to use API or manual)

-- Step 4: run the below in a notebook
/*
# remove folders
dbutils.fs.rm("dbfs:/Workspace/death_star_dev", recurse=True)
dbutils.fs.rm("dbfs:/Workspace/starkiller_base_dev", recurse=True)
# remove user folders
users_path = "dbfs:/Workspace/Users/"
for user_folder in dbutils.fs.ls(users_path):
    if user_folder.name.endswith("@death-star.demo-data-product-at-scale.com/") \
        or user_folder.name.endswith("@starkiller-base.demo-data-product-at-scale.com/"):
            print(f"Removing {user_folder.path}")
            dbutils.fs.rm(user_folder.path, recurse=True)
*/
