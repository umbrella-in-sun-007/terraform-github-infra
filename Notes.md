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