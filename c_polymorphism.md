---
layout: page
title: Polymorphism/Locus/Germplasm Associations
---

## General Approach
* Use Case 1 - T-DNA Insertion - Insertion Flanking Sequence Available

1) Create sequence feature type "t-dna transposon"

2) Create sequence feature type 

"transposable element insertion site". 
This element is mapped to the chromosome location.

3) Create sequence feature type 
"transposable element flanking region". This element holds actual DNA-sequence.

*	All elements assigned the same name, but unique name appended with a sequence feature type.

*	T-DNA transposon element site is an object, and the "transposable element insertion site" is a subject.

*	T-DNA transposon element insertion site is an object, and the "transposable element flanking region" is a subject.

4) Create genotype element with "T-DNA Insertion" type. The name of the genotype is a polymorphism name, and unique name can be concatenation of associated locus, t-dna transposon element and allele feature. Genotype is a set of mutations, alleles, etc (variant_collection)

*	Associate genotype with locus
*  Associate genotype with allele feature
*  Associate genotype with t-dna transposon element

This will allow to handle the situation when we do not have any information about DNA flanking sequence or SNP.

5) Associate genotype with stock

Example: 

*	Features

| feature_type                         | feature_name        | feature_uniquename                                      |
|--------------------------------------|---------------------|---------------------------------------------------------|
| t-dna_transposon                     | SALK_142526.46.30.X | SALK_142526.46.30.X                                     |
| transposable element insertion site  | SALK_142526.46.30.X | SALK_142526.46.30.X:transposable element insertion_site |
| transposable_element flanking region | SALK_142526.46.30.X | SALK_142526.46.30.X:transposable elementflanking_region |

*	Relationships between features (feature relationship table)


| subject_type                         | subject                                                  | relationship    | object_type                         | object                                                  |   |
|--------------------------------------|----------------------------------------------------------|-----------------|-------------------------------------|---------------------------------------------------------|---|
| transposable_element_insertion_site  | SALK_142526.46.30.X:transposable_element_insertion_site  | produced by     | t_dna_transposon                    | SALK_142526.46.30.X                                     |   |
| transposable_element_flanking_region | SALK_142526.46.30.X:transposable_element_flanking_region | associated_with | transposable_element_insertion_site | SALK_142526.46.30.X:transposable_element_insertion_site |   |

* Genotype and Features Association (Locus and Construct/feature_genotype)

| genotype_unique_name                 | genotype_name | chromosome | relationship    | feature_type                        | feature                                                 |
|--------------------------------------|---------------|------------|-----------------|-------------------------------------|---------------------------------------------------------|
| SALK_142526.46.30.X:AT1G51680:4CL1-1 | 4CL1-1        | Chr1       | associated_with | allele                              | 4CL1-1                                                  |
| SALK_142526.46.30.X:AT1G51680:4CL1-1 | 4CL1-1        | Chr1       | associated_with | gene                                | AT1G51680                                               |
| SALK_142526.46.30.X:AT1G51680:4CL1-1 | 4CL1-1        | Chr1       | carried_in      | transposable_element_insertion_site | SALK_142526.46.30.X:transposable_element_insertion_site |

* Genotype

| genotype_name | type            | genotype_unique_name                 | synonym             |
|---------------|-----------------|--------------------------------------|---------------------|
| 4CL1-1        | T-DNA Insertion | SALK_142526.46.30.X:AT1G51680:4CL1-1 | SALK_142526.46.30.X |

* Genotype to Stock

| genotype_name | stock_name |
|---------------|------------|
| 4CL1-1        | CS65790    |