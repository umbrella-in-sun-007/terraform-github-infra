# Terraform Notes
Terraform provisions infratstrucute, we write code using Hashicorp Configuration Language (HCL)

## Comments

**Single line**
```hcl
# this is a single line comment
```

**Multi line**
```hcl
/*
* Thi is a Multi-
* -line comment
*/
```

## Constructs
Terraform has 7 main types of Constructs:  
1. Blocks
2. Arguments
3. Expressions
4. Data Structures
5. Meta-arguments
6. Functions
7. Comments

### Blocks
A block is a container for other content.
```hcl
block_type "parameter" {
    # Attributes are key-value pairs
    attrubute1 = Value1
    attrubute2 = Value2
}
```
Valid block types are:
locals, variable, output, resource, module, provider
We'll deep dive in block type later in Notes.

### Data Types
There are 5 data types in HCL:
1. String
2. Number
3. Boolean
4. List
5. Map

```hcl
block_type {
  str     = "String"
  number  = 3
  boolean = true
  list    = ["string", 42, true, 3.14, false]
  my_map = {
    name     = "John Doe"
    age      = 43
    is_admin = true
    "note"     = "Keys can be quoted or un-quoted"
  }

  note_of_john = block_type.my_map["note"]
  age_of_john  = block_type.my_map["age"]
}
```

## Conditions
```hcl
block_type {
    attribute1 = var.env == "dev" ? "if true" : "else"
}
```

## Functions
The HCL language includes a number of built-in functions that you can call from within expressions to transform and combine values. The general syntax for function calls is a function name followed by comma-separated arguments in parentheses: [check out](https://developer.hashicorp.com/nomad/docs/reference/hcl2/functions)
```hcl
locals {
    name = "John Doe"
    cars = ["Audi", "BMW", "Mercedes"]
    message = "The user ${upper(local.name) likes ${join(",",local.cars)}}"
}
# Functions used: upper() and join()
```

## Resource Dependencies
A dependency defines the order in which resources are created, updated, or destroyed.
Terraform must know which resources depend on others so it can:
- Create them in the right order.
- Destroy them safely.
- Avoid race conditions.

> You can visualize dependecies using:  
> `terraform graph | dot -Tsvg > graph.svg`

### Implicit dependencies
If one resource references another's attributes, then Terraform automatically knows it must create the referenced resource first.
```hcl
resource "google_compute_network" "vpc" {
    name = "my-vpc"
}

resource "google_compute_subnetwork" "subnet" {
    name = "my-subnet"
    network = google_compute_network.vpc.self_link # dependency here
}
```

### Explicit dependencies
Sometimes resources do not reference each other directly, but one should still be created after another. In that case you can use the `depends_on` argument.
```hcl
resource "google_storage_bucket" "bucket" {
    name = "my-app-bucket"
    location = "us"
}

/*
A null_resource is a resource type provided by Terraform’s null provider that does not create any real cloud infrastructure.  
Instead, it exists only to run provisioners or to define dependencies.
*/
resource "null_resource" "trigger" {
  depends_on = [google_storage_bucket.bucket]
  provisioner "local-exec" {
    command = "echo 'Bucket created successfully'"
  }
}
```

### Multiple Dependencies
You have have multiple dependencies:
```hcl
depends_on = [
  google_compute_network.vpc,
  google_compute_subnetwork.subnet,
  google_storage_bucket.bucket
]
```
## Providers